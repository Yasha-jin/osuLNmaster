extends Object
class_name Osu

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

# Colours
var Colours:String = ""

var HitobjectsContainer:Array = []
var TimingPointsContainer:Array = []

func _notification(what):
	if what == Object.NOTIFICATION_PREDELETE:
		for obj in HitobjectsContainer:
			obj.free()
		for obj in TimingPointsContainer:
			obj.free()
