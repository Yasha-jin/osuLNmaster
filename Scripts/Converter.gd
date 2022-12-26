extends Object
class_name Converter

func Convert(ConverterArgs:Dictionary, osuFile:Object):
	var SVIndex:int = -1
	var lastuninheritedIndex:int = SVIndex
	var isLast:bool = false

	var bpm
	var Beatgap
	var MinimumLength
	var beatLength
	var minLength
	for index in range(0, osuFile.HitobjectsContainer.size()):
		if SVIndex + 1 < osuFile.TimingPointsContainer.size() && isLast == false:
			if osuFile.HitobjectsContainer[index].time >= osuFile.TimingPointsContainer[SVIndex + 1].time || SVIndex == -1:
				SVIndex += 1
				while osuFile.TimingPointsContainer[SVIndex].uninherited == 0 && SVIndex + 1 < osuFile.TimingPointsContainer.size():
					SVIndex += 1
				
				if osuFile.TimingPointsContainer[SVIndex].uninherited == 0:
					SVIndex = lastuninheritedIndex
					isLast = true
				
				bpm = 60000.0 / float(osuFile.TimingPointsContainer[SVIndex].beatLength)
				Beatgap = ConverterArgs.CustomBeatgap if ConverterArgs.BeatgapUseCustom else ConverterArgs.Beatgap
				MinimumLength = ConverterArgs.CustomMinimumLength if ConverterArgs.MinimumLengthUseCustom else ConverterArgs.MinimumLength
				beatLength = ConverterArgs.CustomBeatgap if ConverterArgs.BeatgapInMS else 60000.0 / bpm / int(Beatgap)
				minLength = ConverterArgs.CustomMinimumLength if ConverterArgs.MinimumLengthInMS else 60000.0 / bpm / int(MinimumLength)
				
				lastuninheritedIndex = SVIndex
		
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
		
		var NewEndTime = nextHitobject.time - round(float(beatLength))
		
		# if the LN is smaller than the minimum length, skip it
		if NewEndTime - osuFile.HitobjectsContainer[index].time < round(float(minLength)):
			continue
		
		osuFile.HitobjectsContainer[index].type = 128
		osuFile.HitobjectsContainer[index].endTime = NewEndTime
	
	return osuFile.HitobjectsContainer
