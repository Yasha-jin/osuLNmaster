extends Control

var osuParser = OsuParser.new()
var converter = Converter.new()
var toosuformat = Formatter.new()
var svRemover = SVRemover.new()
var settingsSaver = SettingsSaver.new()

var FilePath:Array = []
var ConverterArgs:Dictionary = {
	"Beatgap": "4",
	"BeatgapUseCustom": false,
	"BeatgapInMS": false,
	"CustomBeatgap": "16",
	"MinimumLength": "4",
	"MinimumLengthUseCustom": false,
	"MinimumLengthInMS": false,
	"CustomMinimumLength": "16",
	"OverrideOD": false,
	"OD": "8.0",
	"OverrideHP": false,
	"HP": "8.0",
	"OverrideLN": true,
	"OverrideSV": false
}

func _ready() -> void:
	set_process(false)
	set_physics_process(false)
	
	$VBoxContainer/Buttons/Version.text = Version.version_tag
	
	$VBoxContainer/Parameters/Gaps/HButtonList.connect("SelectedButtonChanged", self, "UpdateConverterArgs", ["Beatgap"])
	$VBoxContainer/Parameters/MinLength/HButtonList.connect("SelectedButtonChanged", self, "UpdateConverterArgs", ["MinimumLength"])
	
	$VBoxContainer/Parameters/Gaps/HButtonList/SpinBox.connect("value_changed", self, "UpdateConverterArgs", ["CustomBeatgap"])
	$VBoxContainer/Parameters/MinLength/HButtonList/SpinBox.connect("value_changed", self, "UpdateConverterArgs", ["CustomMinimumLength"])
	
	$VBoxContainer/Parameters/Overrides/VBoxContainer/VBoxContainer/OD/OD.connect("toggled", self, "UpdateConverterOverride", ["OD"])
	$VBoxContainer/Parameters/Overrides/VBoxContainer/VBoxContainer2/HP/HP.connect("toggled", self, "UpdateConverterOverride", ["HP"])
	$VBoxContainer/Parameters/Overrides/LN.connect("toggled", self, "UpdateConverterOverride", ["LN"])
	$VBoxContainer/Parameters/Overrides/NSV.connect("toggled", self, "UpdateConverterOverride", ["SV"])
	
	$VBoxContainer/Parameters/Overrides/VBoxContainer/VBoxContainer/SpinBox.connect("value_changed", self, "UpdateConverterArgs", ["OD"])
	$VBoxContainer/Parameters/Overrides/VBoxContainer/VBoxContainer2/SpinBox.connect("value_changed", self, "UpdateConverterArgs", ["HP"])
	
	var file = File.new()
	if file.file_exists("user://Settings.ini"):
		var settings:Dictionary = settingsSaver.ReadSettings()
		ConverterArgs = settings
		UpdateInterface()
	else:
		settingsSaver.SaveSettings(ConverterArgs)
	
	get_tree().connect("files_dropped", self, "Handle_dropped_files")
	Version.connect("update_available", self, "UpdateVersionLabel")

func UpdateConverterArgs(args, key):
	if "C-" in str(args):
		if key == "Beatgap":
			ConverterArgs.BeatgapUseCustom = true
			ConverterArgs.BeatgapInMS = "ms" in args
		elif key == "MinimumLength":
			ConverterArgs.MinimumLengthUseCustom = true
			ConverterArgs.MinimumLengthInMS = "ms" in args
	else:
		if key == "Beatgap":
			ConverterArgs.BeatgapUseCustom = false
			ConverterArgs.BeatgapInMS = false
		elif key == "MinimumLength":
			ConverterArgs.MinimumLengthUseCustom = false
			ConverterArgs.MinimumLengthInMS = false
		
		ConverterArgs[key] = str(args)
	settingsSaver.SaveSettings(ConverterArgs)

func UpdateConverterOverride(args, key):
	ConverterArgs["Override" + key] = args
	settingsSaver.SaveSettings(ConverterArgs)

func Handle_dropped_files(files: PoolStringArray, _screen: int) -> void:
	FilePath.clear()
	for file in files:
		if ".osu" in file:
			FilePath.append(file)
		else:
			OS.alert(file + " isn't a .osu file.")
			continue
	$VBoxContainer/Generals/filepath.text = str(FilePath.size()) + " maps ready to convert."

func ConversionProcess() -> void:
	var DirToForceUpdate:Array = []
	for filepath in FilePath:
		var osuFile = osuParser.ParseBeatmap(filepath)
		
		if !(osuFile is Osu):
			continue

		if osuFile.HitobjectsContainer.size() != 0:
			osuFile.HitobjectsContainer = converter.Convert(ConverterArgs, osuFile)
		else:
			OS.alert("An error occured while parsing, the beatmap may be invalid.")
			osuFile.free()
			return
		
		if ConverterArgs.OverrideSV:
			osuFile.TimingPointsContainer = svRemover.Remove(osuFile)

		if ConverterArgs.OverrideOD:
			osuFile.OverallDifficulty = float(ConverterArgs.OD)
		
		if ConverterArgs.OverrideHP:
			osuFile.HPDrainRate = float(ConverterArgs.HP)
		
		var Diffname = DiffnameFormatting()
		
		var text = toosuformat.Format(Diffname, osuFile)
		var baseDir = filepath.get_base_dir()
		if !(baseDir in DirToForceUpdate):
			DirToForceUpdate.append(baseDir)

		var file = File.new()
		var file_name:String = osuFile.Artist + " - " + osuFile.Title + " (" + osuFile.Creator + ") [" + osuFile.Version
		file_name += Diffname + "].osu"
		
		# In case the filename end up invalid due to the osu entry
		if !file_name.is_valid_filename():
			var regex = RegEx.new()
			regex.compile("[\\\\/:*?\"<>|]")
			file_name = regex.sub(file_name, "", true)
		
		file.open(baseDir + "/" + file_name, File.WRITE)
		file.store_string(text)
		file.close()
		
		# Memory managements stuff
		osuFile.free()
	
	# Force osu to reload the folders on linux.
	# Wine Osu doesn't detect change in map folder but does in
	# Song Folder (at least from personal experience)
	# so we'll make it detect it.
	if OS.get_name() == "X11":
		var dir = Directory.new()
		for d in DirToForceUpdate:
			dir.open(d)
			dir.rename(d, d + "up")
			dir.rename(d + "up", d)
	DirToForceUpdate.clear()

func DiffnameFormatting():
	var Format = " ("
	var od = float(ConverterArgs.OD)
	var hp = float(ConverterArgs.HP)

	var NSV = "NSV " if ConverterArgs.OverrideSV else ""
	var OD = "OD" + str(float(od)) + " " if ConverterArgs.OverrideOD else ""
	var HP = "HP" + str(float(hp)) + " " if ConverterArgs.OverrideHP else ""
	var FLN = "FLN" if ConverterArgs.OverrideLN else "INV"
	
	var BG = " BG"
	if ConverterArgs.BeatgapUseCustom == true:
		BG += ConverterArgs.CustomBeatgap
		if ConverterArgs.BeatgapInMS:
			BG += "ms"
	else:
		BG += ConverterArgs.Beatgap
	
	var ML = " ML"
	if ConverterArgs.MinimumLengthUseCustom == true:
		ML += ConverterArgs.CustomMinimumLength
		if ConverterArgs.MinimumLengthInMS:
			ML += "ms"
	else:
		ML += ConverterArgs.MinimumLength
	
	Format += NSV + OD + HP + FLN + BG + ML
	
	Format += ")"
	
	return Format

func _on_Github_pressed():
	OS.shell_open("https://github.com/Yasha-jin/osuLNmaster")

func UpdateVersionLabel():
	$VBoxContainer/Buttons/Version.text += " (New update available on github !)"

func ClearQueue():
	FilePath.clear()
	$VBoxContainer/Generals/filepath.text = str(FilePath.size()) + " maps ready to convert."

func UpdateInterface():
	# Beatgap
	$VBoxContainer/Parameters/Gaps/HButtonList/Button3.pressed = false
	if ConverterArgs.BeatgapInMS:
		$VBoxContainer/Parameters/Gaps/HButtonList/MS.pressed = true
	elif ConverterArgs.BeatgapUseCustom:
		$VBoxContainer/Parameters/Gaps/HButtonList/Beat.pressed = true
	else:
		for child in $VBoxContainer/Parameters/Gaps/HButtonList.get_children():
			if child.get_class() == "Button":
				if child.text == ConverterArgs.Beatgap:
					child.pressed = true
				else:
					child.pressed = false
	$VBoxContainer/Parameters/Gaps/HButtonList/SpinBox.value = int(ConverterArgs.CustomBeatgap)
	
	# Min length
	$VBoxContainer/Parameters/MinLength/HButtonList/Button3.pressed = false
	if ConverterArgs.MinimumLengthInMS:
		$VBoxContainer/Parameters/MinLength/HButtonList/MS.pressed = true
	elif ConverterArgs.MinimumLengthUseCustom:
		$VBoxContainer/Parameters/MinLength/HButtonList/Beat.pressed = true
	else:
		for child in $VBoxContainer/Parameters/MinLength/HButtonList.get_children():
			if child.get_class() == "Button":
				if child.text == ConverterArgs.Beatgap:
					child.pressed = true
				else:
					child.pressed = false
	$VBoxContainer/Parameters/MinLength/HButtonList/SpinBox.value = int(ConverterArgs.CustomMinimumLength)
	
	# Overrides
	$VBoxContainer/Parameters/Overrides/VBoxContainer/VBoxContainer/OD/OD.pressed = ConverterArgs.OverrideOD
	$VBoxContainer/Parameters/Overrides/VBoxContainer/VBoxContainer/SpinBox.value = float(ConverterArgs.OD)
	
	$VBoxContainer/Parameters/Overrides/VBoxContainer/VBoxContainer2/HP/HP.pressed = ConverterArgs.OverrideHP
	$VBoxContainer/Parameters/Overrides/VBoxContainer/VBoxContainer2/SpinBox.value = float(ConverterArgs.HP)
	
	$VBoxContainer/Parameters/Overrides/LN.pressed = ConverterArgs.OverrideLN
	$VBoxContainer/Parameters/Overrides/NSV.pressed = ConverterArgs.OverrideSV
