extends BlockChain

@export var holdingThresholdEntry : LineEdit
var holdingThreshold : float = 1.0
@export var FVThresholdEntry : LineEdit
var FVThreshold : float = 1.0
@export var FImportanceEntry : LineEdit
var FImportance : float = 1.0
@export var VImportanceEntry : LineEdit
var VImportance : float = 1.0
@export var holdingForgivenessEntry : LineEdit
var holdingForgiveness : int = 5
@export var FVForgivenessEntry : LineEdit
var FVForgiveness : int = 5
@export var FVFrontierEntry : LineEdit
var FVFrontier : int = 30
var holdingThresholdDictionary = {}
var FVThresholdDictionary = {}


func _process(delta : float) -> void:
	super(delta)
	if waitingForInput && !stillRunning:
		if holdingThresholdEntry.text.is_valid_float():
			holdingThreshold = float(holdingThresholdEntry.text)
		if FVThresholdEntry.text.is_valid_float():
			FVThreshold = float(FVThresholdEntry.text)
		if FImportanceEntry.text.is_valid_float():
			FImportance = float(FImportanceEntry.text)
		if VImportanceEntry.text.is_valid_float():
			VImportance = float(VImportanceEntry.text)
		if holdingForgivenessEntry.text.is_valid_int():
			holdingForgiveness = int(holdingForgivenessEntry.text)
		if FVForgivenessEntry.text.is_valid_int():
			FVForgiveness = int(FVForgivenessEntry.text)
		if FVFrontierEntry.text.is_valid_int():
			FVFrontier = int(FVFrontierEntry.text)


func IsInCommunity(nodeInQuestion : BasicNode):
	if nodeInQuestion in holdingThresholdDictionary.keys() and nodeInQuestion in FVThresholdDictionary.keys():
		if holdingThresholdDictionary[nodeInQuestion] > 0 && FVThresholdDictionary[nodeInQuestion] > 0:
			return true
		else:
			return false
	else:
		return false


func UpdateThresholdDictionaries(nodeInQuestion : BasicNode):
	if nodeInQuestion.currentWallet > holdingThreshold:
		holdingThresholdDictionary[nodeInQuestion] = holdingForgiveness
	else:
		if nodeInQuestion in holdingThresholdDictionary.keys():
			holdingThresholdDictionary[nodeInQuestion] -= 1
		else:
			holdingThresholdDictionary[nodeInQuestion] = 0
	
	var frequencySum = 0
	var volumeSum = 0
	if len(nodeInQuestion.lastHundredDays) >= FVFrontier:
		for i in range(FVFrontier):
			frequencySum += nodeInQuestion.lastHundredDays[-i].x
			volumeSum += nodeInQuestion.lastHundredDays[-i].y
	else:
		for i in range(len(nodeInQuestion.lastHundredDays)):
			frequencySum += nodeInQuestion.lastHundredDays[-i].x
			volumeSum += nodeInQuestion.lastHundredDays[-i].y
	
	if (frequencySum * FImportance) * (volumeSum * VImportance) > FVThreshold:
		FVThresholdDictionary[nodeInQuestion] = FVForgiveness
	else:
		if nodeInQuestion in FVThresholdDictionary.keys():
			FVThresholdDictionary[nodeInQuestion] -= 1
		else:
			FVThresholdDictionary[nodeInQuestion] = 0


# Define reward for being the validator
func UniqueValidatorBehavior(validator : BasicNode):
	for node in nodeList:
		if IsInCommunity(node):
			node.currentWallet += (rewardAmount / len(nodeList))


# Need to distribute reward among all nodes relative to their ownership
func ChooseValidator():
	var randomSelect = []
	for i in range(len(nodeList)):
		if IsInCommunity(nodeList[i]):
			randomSelect.append(nodeList[i])
	var validator = randomSelect[randi_range(0, len(randomSelect) - 1)]
	return validator


func IdiosyncraticNodeDecisions():
	for node in nodeList:
		UpdateThresholdDictionaries(node)
		if IsInCommunity(node):
			node.communityLabel.text = "YES"
		else:
			node.communityLabel.text = "NO"


func RunSimulation():
	waitingForInput = false
	simulating = true
	stillRunning = true
	
	if !hasBeenStarted:
		for i in range(initialAmount):
			AddNodeToSystem()
			await get_tree().create_timer(spawnDifference).timeout
		numHops = 10 + floori(sqrt(len(nodeList)))
		# Starting nodes are assumed to be part of community, need initial validators
		for node in nodeList:
			holdingThresholdDictionary[node] = holdingForgiveness
			FVThresholdDictionary[node] = FVForgiveness
		await get_tree().create_timer(1).timeout
		hasBeenStarted = true
		
	while(simulating):
		for i in range(randi_range(1,ceili(sqrt(len(nodeList))))):
			StartTransaction()
			await get_tree().create_timer(simulationStepTime).timeout
		StartValidation()
		await get_tree().create_timer(simulationStepTime).timeout
		IdiosyncraticNodeDecisions()
		PrepareChainForNextStep()
		await get_tree().create_timer(simulationStepTime).timeout
	stillRunning = false


func ShowCommunity():
	for node in nodeList:
		node.ManageLabelState(BasicNode.LabelState.COMMUNITY)
