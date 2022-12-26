extends Object
class_name OsuFile

var Format:String = "osu file format v14"

# General
var AudioFilename
var AudioLeadIn
var PreviewTime
var Countdown
var SampleSet
var StackLeniency
var Mode
var LetterboxInBreaks
var SpecialStyle
var WidescreenStoryboard

# Editor
var Bookmarks
var DistanceSpacing
var BeatDivisor
var GridSize
var TimelineZoom

# Metadata
var Title
var TitleUnicode
var Artist
var ArtistUnicode
var Creator
var Version
var Source
var Tags
var BeatmapID
var BeatmapSetID

# Difficulty
var HPDrainRate
var CircleSize
var OverallDifficulty
var ApproachRate
var SliderMultiplier
var SliderTickRate

# Events
var Events:String = ""

var HitobjectsContainer:Array = []
var TimingPointsContainer:Array = []

func ParseBeatmap(filepath: String):
	var beatmap := File.new()
	beatmap.open(filepath, File.READ)
	
	var section := ""
	var section_name := ["[General]", "[Editor]", "[Metadata]", "[Difficulty]", "[Events]", "[TimingPoints]", "[HitObjects]"]
	
	while not beatmap.eof_reached():
		var line = beatmap.get_line()
		
		if line.strip_edges() in section_name:
			section = line.strip_edges()
			continue
		
		if "osu file format" in line:
			Format = str(line)
			continue
		
		if section == "[Events]":
			Events += line + "\n"
		
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
				
				TimingPointsContainer.append(timingpoint)
		
		elif section == "[HitObjects]":
			if "," in line:
				var values = line.split(",")
				var LNvalues = values[5].split(":", true, 1)
				
				var hitobject:Object = OsumaniaHitObject.new()
				hitobject.x = int(values[0])
				hitobject.y = int(values[1])
				hitobject.lane = clamp(floor(int(values[0]) * int(CircleSize) / 512), 0, int(CircleSize) - 1)
				hitobject.time = int(values[2])
				hitobject.type = int(values[3])
				hitobject.hitSound = int(values[4])
				if values[3] == "128":
					hitobject.endTime = int(LNvalues[0])
					hitobject.hitSample = str(LNvalues[1])
				else:
					hitobject.hitSample = str(values[5])
				
				HitobjectsContainer.append(hitobject)

		else:
			if section in section_name:
				if ":" in line:
					var key = (line.substr(0, line.find(":"))).strip_edges()
					var value = line.split(":")[1].strip_edges()
					
					if key in self: set(key, str(value))
	
	beatmap.close()
