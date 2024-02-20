extends Object
class_name OsuParser

const section_name := ["[General]", "[Editor]", "[Metadata]", "[Difficulty]", "[Events]", "[TimingPoints]", "[Colours]", "[HitObjects]"]

func ParseBeatmap(filepath: String):
	var beatmap := File.new()
	var doFileExists = beatmap.file_exists(filepath)
	
	if !doFileExists:
		return null
	
	beatmap.open(filepath, File.READ)
	
	var osu = Osu.new()
	
	var section := ""
	while not beatmap.eof_reached():
		var line = beatmap.get_line()
		
		if line.strip_edges() in section_name:
			section = line.strip_edges()
			continue
		
		if "osu file format" in line:
			osu.Format = str(line)
			continue
		
		if section == "[Events]":
			osu.Events += line + "\n"
		
		if section == "[Colours]":
			osu.Colours += line + "\n"
		
		elif section == "[TimingPoints]":
			if "," in line:
				var values = line.split(",")
				
				var timingpoint:Object = OsuTimingPoint.new()
				timingpoint.time = int(values[0])
				timingpoint.beatLength = values[1]
				timingpoint.meter = int(values[2])
				timingpoint.sampleSet = int(values[3])
				timingpoint.sampleIndex = int(values[4])
				timingpoint.volume = int(values[5])
				timingpoint.uninherited = int(values[6])
				timingpoint.effects = int(values[7])
				
				osu.TimingPointsContainer.append(timingpoint)
		
		elif section == "[HitObjects]":
			if "," in line:
				var values = line.split(",")
				var LNvalues = values[5].split(":", true, 1)
				
				var hitobject:Object = OsumaniaHitObject.new()
				hitobject.x = int(values[0])
				hitobject.y = int(values[1])
				hitobject.lane = clamp(floor(int(values[0]) * int(osu.CircleSize) / 512), 0, int(osu.CircleSize) - 1)
				hitobject.time = int(values[2])
				hitobject.type = int(values[3])
				hitobject.hitSound = int(values[4])
				if values[3] == "128":
					hitobject.endTime = int(LNvalues[0])
					hitobject.hitSample = str(LNvalues[1])
				else:
					hitobject.hitSample = str(values[5])
				
				osu.HitobjectsContainer.append(hitobject)

		else:
			if section in section_name:
				if ":" in line:
					var key = (line.substr(0, line.find(":"))).strip_edges()
					var value = line.split(":")[1].strip_edges()
					
					if key in osu: osu.set(key, str(value))
	
	beatmap.close()
	
	osu.TimingPointsContainer.sort_custom(self, "TimeSorter")
	osu.HitobjectsContainer.sort_custom(self, "TimeSorter")
	
	return osu

func TimeSorter(a, b):
	return a.time < b.time
