extends Object
class_name OsumaniaHitObject

var x:int = 256
var y:int = 192
var lane:int = 1 # Not part of the osu format, used for hint. clamp(floor(x * columnCount / 512), 0, columnCount - 1)
var time:int = 0
var type:int = 0
var hitSound:int = 0
var endTime:int = 0
var hitSample:String = "0:0:0:0:"
