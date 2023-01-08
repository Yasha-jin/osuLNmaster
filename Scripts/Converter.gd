extends Object
class_name Converter

# To avoid 1-2ms difference in LN length making some
# hitobjects a LN and other not, when they should be
# accordng to adjacent hibobjects.
const Leniency:int = 2

func Convert(ConverterArgs:Dictionary, osuFile:Object):
	var SVIndex:int = -1

	var bpm:float
	var Beatgap:int = int(ConverterArgs.CustomBeatgap) if ConverterArgs.BeatgapUseCustom else int(ConverterArgs.Beatgap)
	var MinimumLength:int = int(ConverterArgs.CustomMinimumLength) if ConverterArgs.MinimumLengthUseCustom else int(ConverterArgs.MinimumLength)
	var beatLength:float
	var minLength:float
	
	# SV doesn't matter toward LN length, so we'll only go over BPM
	var BeatLengthContainer:Array = []
	for obj in osuFile.TimingPointsContainer:
		if obj.uninherited == 1:
			BeatLengthContainer.append(obj)
	
	for index in range(0, osuFile.HitobjectsContainer.size()):
		if SVIndex + 1 < BeatLengthContainer.size():
			if osuFile.HitobjectsContainer[index].time >= BeatLengthContainer[SVIndex + 1].time || SVIndex == -1:
				SVIndex += 1
				
				bpm = 60000.0 / float(BeatLengthContainer[SVIndex].beatLength)
				beatLength = ConverterArgs.CustomBeatgap if ConverterArgs.BeatgapInMS else 60000.0 / bpm / Beatgap
				minLength = ConverterArgs.CustomMinimumLength if ConverterArgs.MinimumLengthInMS else 60000.0 / bpm / MinimumLength
		
		# Skip the hitobject if override is off and if it a LN
		if ConverterArgs.OverrideLN == false && osuFile.HitobjectsContainer[index].endTime != 0:
			continue
		
		# Seek out the next hitobject in the lane
		var nextHitobject = null
		for nextIndex in range(index + 1, osuFile.HitobjectsContainer.size()):
			if osuFile.HitobjectsContainer[nextIndex].lane == osuFile.HitobjectsContainer[index].lane:
				nextHitobject = osuFile.HitobjectsContainer[nextIndex]
				break
		
		# don't change the LN size if there is no hitobject after
		if nextHitobject == null:
			continue
		
		var NewEndTime = nextHitobject.time - round(beatLength)
		
		# if the LN is smaller than the minimum length, skip it
		# Also set the type/endTime in case it was a LN
		if NewEndTime - osuFile.HitobjectsContainer[index].time < round(minLength) - Leniency:
			osuFile.HitobjectsContainer[index].type = 1
			osuFile.HitobjectsContainer[index].endTime = 0
			continue
		
		osuFile.HitobjectsContainer[index].type = 128
		osuFile.HitobjectsContainer[index].endTime = NewEndTime
	
	return osuFile.HitobjectsContainer
