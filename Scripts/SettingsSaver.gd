extends Object
class_name SettingsSaver

func SaveSettings(Settings: Dictionary) -> void:
	var file = ConfigFile.new()
	
	for setting in Settings:
		file.set_value("Settings", setting, Settings[setting])
	
	file.save("user://Settings.ini")

func ReadSettings() -> Dictionary:
	var file = ConfigFile.new()
	
	var err = file.load("user://Settings.ini")
	
	if err != OK:
		return {}
	
	var Settings: Dictionary = {}
	for section in file.get_sections():
		for setting in file.get_section_keys(section):
			Settings[setting] = file.get_value(section, setting)
	return Settings
