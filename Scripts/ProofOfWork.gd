extends BlockChain

@export var GPUCost : float = 1.0

# Define reward for being the validator
func UniqueBehavior(validator : BasicNode):
	validator.currentWallet += rewardAmount


# Effectively, to start, put every node into the pool at an equal playing field,
#	when one node wins a validation, give them a reward. If the node chooses to
#	spend that reward on a new "GPU" (read: permanent ticket for the lottery), then
#	add an extra ticket for that node for every GPU
func ChooseValidator():
	var randomSelect = []
	for i in range(len(nodeList)):
		for j in range(nodeList[i].powerRanking):
			randomSelect.append(i)
	var validator = nodeList[randomSelect[randi_range(0, len(nodeList) - 1)]]
	print("Validator " + validator.nodeName + " had " + str(validator.currentWallet))
	validator.currentWallet += rewardAmount
	print("Validator " + validator.nodeName + " has " + str(validator.currentWallet))
	return validator


func IdiosyncraticNodeDecisions():
	for node in nodeList:
		# Small likelihood to reinvest winnings
		if randf() < node.likelihoodOfBuyingGPU && node.currentWallet > GPUCost && node.currentWallet > node.minimumHoldingAmount:
			node.powerRanking += 1
			node.currentWallet -= GPUCost
			print(node.nodeName + " bought a new GPU!")
			print("	" + node.nodeName + " has likelihood of: " + str(node.powerRanking))
		# More likely to buy a gpu the more they have to keep ensuring lead and because they're making more from controlling the chain
		if randf() < node.likelihoodOfSpendingFromOutside + (node.powerRanking * 0.01):
			node.powerRanking += 1
			node.currentWallet -= GPUCost
			print(node.nodeName + " bought a new GPU with their own outside funds!")
			print("	" + node.nodeName + " has likelihood of: " + str(node.powerRanking))
