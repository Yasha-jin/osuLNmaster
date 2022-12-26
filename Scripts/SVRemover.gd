extends Object
class_name SVRemover

func Remove(osuFile:Object):
	# Remove SV
	for index in range(osuFile.TimingPointsContainer.size() - 1, 0, -1):
		if osuFile.TimingPointsContainer[index].uninherited == 0:
			osuFile.TimingPointsContainer[index].free()
			osuFile.TimingPointsContainer.remove(index)
	
	# Get the duration of all bpm point
	var LastHitObjectTime = osuFile.HitobjectsContainer[-1].endTime if osuFile.HitobjectsContainer[-1].endTime != 0 else osuFile.HitobjectsContainer[-1].time
	
	var DurationIndex = []
	for index in range(0, osuFile.TimingPointsContainer.size()):
		var NextTPtime
		if index + 1 < osuFile.TimingPointsContainer.size():
			NextTPtime = osuFile.TimingPointsContainer[index + 1].time
		else:
			NextTPtime = LastHitObjectTime
		
		DurationIndex.append(NextTPtime - osuFile.TimingPointsContainer[index].time)
	
	# Get the biggest duration
	var BiggestIndex = [0, 0] # [index, duration]
	for index in range(0, DurationIndex.size()):
		if BiggestIndex[1] < DurationIndex[index]:
			BiggestIndex = [index, DurationIndex[index]]
	
	var NormalizedSV = []
	var BaseBeatLength = osuFile.TimingPointsContainer[BiggestIndex[0]].beatLength
	for index in range(0, osuFile.TimingPointsContainer.size()):
		var timingpoint = OsuTimingPoint.new()

		# Clamp stupid bpm
		osuFile.TimingPointsContainer[index].beatLength = str(clamp(float(osuFile.TimingPointsContainer[index].beatLength), float(BaseBeatLength) / 100, float(BaseBeatLength) * 10))

		for key in osuFile.TimingPointsContainer[index].get_property_list():
			if key.usage == 8192:
				timingpoint.set(key.name, osuFile.TimingPointsContainer[index].get(key.name))
		
		timingpoint.uninherited = 0
		var normalization = float(BaseBeatLength) / float(osuFile.TimingPointsContainer[index].beatLength) * 100
		timingpoint.beatLength = clamp(-normalization, -10000, -10)

		NormalizedSV.append(timingpoint)
	
	var indexoffset = 0
	for index in range(0, osuFile.TimingPointsContainer.size()):
		osuFile.TimingPointsContainer.insert(indexoffset + 1, NormalizedSV[index]) 
		indexoffset += 2

	return osuFile.TimingPointsContainer
