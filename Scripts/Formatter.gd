extends Object
class_name Formatter

func Format(DiffnameFormatting:String, osuFile:Osu):
	var file:String = ""
	
	var section:String = "[General]"
	for key in osuFile.get_property_list():
		if key.usage == 8192 && osuFile.get(key.name) != null:
			if key.name == "Format":
				file += str(osuFile.get(key.name)) + "\n\n" + "[General]" + "\n"
				continue
			elif key.name == "Bookmarks" || key.name == "DistanceSpacing":
				if section != "[Editor]":
					section = "[Editor]"
					file += "\n[Editor]\n"
			elif key.name == "Title":
				section = "[Metadata]"
				file += "\n[Metadata]\n"
			elif key.name == "HPDrainRate":
				section = "[Difficulty]"
				file += "\n[Difficulty]\n"
			elif key.name == "Events":
				section = "[Events]"
				file += "\n[Events]\n" + str(osuFile.get(key.name))
				continue
			elif key.name == "Version":
				file += key.name + ":" + str(osuFile.get(key.name)) + DiffnameFormatting + "\n"
				continue
			elif key.name == "BeatmapID":
				file += key.name + ":-1\n"
				continue
			
			# for whatever reason the keys of the general and editor
			# section have a space before the value.
			var space = ""
			if section == "[General]" or section == "[Editor]":
				space = " "
			
			if typeof(osuFile.get(key.name)) != TYPE_ARRAY && key.name != "Colours":
				file += key.name + ":" + space + str(osuFile.get(key.name)) + "\n"
	
	file += "[TimingPoints]\n"
	for timingpoint in osuFile.TimingPointsContainer:
		var time = str(timingpoint.time)
		var beatLength = str(timingpoint.beatLength)
		var meter = str(timingpoint.meter)
		var sampleSet = str(timingpoint.sampleSet)
		var sampleIndex = str(timingpoint.sampleIndex)
		var volume = str(timingpoint.volume)
		var uninherited = str(timingpoint.uninherited)
		var effects = str(timingpoint.effects)
		
		file += time + "," + beatLength + "," + meter + "," + sampleSet + "," + sampleIndex + "," + volume + "," + uninherited + "," + effects + "\n"
	
	file += "\n"
	
	if osuFile.Colours != "":
		file += "\n[Colours]\n" + str(osuFile.get("Colours"))
	else:
		file += "\n"
	
	# dunno why but there is 2 empty line before the hitobject
	# section instead of 1.
	file += "[HitObjects]\n"
	for hitobject in osuFile.HitobjectsContainer:
		var x = str(hitobject.x)
		var y = str(hitobject.y)
		var time = str(hitobject.time)
		var type = str(hitobject.type)
		var hitSound = str(hitobject.hitSound)
		
		file += x + "," + y + "," + time + "," + type + "," + hitSound + ","
		
		if hitobject.endTime != 0:
			file += str(hitobject.endTime) + ":"
		
		var hitSample = str(hitobject.hitSample)
		
		file += hitSample + "\n"
	
	return file
