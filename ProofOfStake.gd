extends BlockChain

@export var rewardAmount : float = 1.0
@export var GPUCost : float = 1.0

# Define reward for being the validator
func UniqueBehavior(validator : BasicNode):
	var totalCoin = 0
	for node in nodeList:
		totalCoin += ceilf(node.currentWallet)
	for node in nodeList:
		node.currentWallet += (node.currentWallet / totalCoin) * rewardAmount


# Need to distribute reward among all nodes relative to their ownership
func ChooseValidator():
	var randomSelect = []
	for i in range(len(nodeList)):
		for j in range(floori(nodeList[i].currentWallet)):
			randomSelect.append(i)
	var validator = nodeList[randomSelect[randi_range(0, len(nodeList) - 1)]]
	return validator


func IdiosynchraticNodeDecisions():
	pass
