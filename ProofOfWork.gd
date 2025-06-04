extends BlockChain

@export var rewardAmount : float = 1.0
var validatorRankings = {}

func UniqueBehavior(validator : BasicNode):
	validator.currentWallet += rewardAmount


func ChooseValidator():
	var randomSelect = []
	for i in range(len(nodeList)):
		for j in range(nodeList[i].powerRanking):
			randomSelect.append(i)
	var validator = nodeList[randomSelect[randi_range(0, len(nodeList) - 1)]]
	if validator in validatorRankings.keys():
		validatorRankings[validator] += 1
	else:
		validatorRankings[validator] = 1
	if randf() > 0.5:
		print("Validator " + validator.nodeName + " bought a new GPU!")
		validator.showLabel = false
		validator.powerRanking += 1
		validator.nodeLabel.text = str(validator.powerRanking)
	else:
		print("Validator " + validator.nodeName + " had " + str(validator.currentWallet))
		validator.currentWallet += rewardAmount
		print("Validator " + validator.nodeName + " has " + str(validator.currentWallet))
	print(validator.name + " has likelihood of: " + str(validator.powerRanking))
	return validator
