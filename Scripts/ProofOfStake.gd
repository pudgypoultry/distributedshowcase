extends BlockChain


# Define reward for being the validator
func UniqueValidatorBehavior(validator : BasicNode):
	var totalCoin = 0
	for node in nodeList:
		totalCoin += ceilf(node.currentWallet)
	var i = true
	for node in nodeList:
		if i:
			print("	" + node.nodeName + " had " + str(node.currentWallet) + " coins")
		node.currentWallet += (node.currentWallet / totalCoin) * rewardAmount
		if i:
			print("	" + node.nodeName + " has " + str(node.currentWallet) + " coins")
			i = false
		node.powerRanking = floori(node.currentWallet)


# Need to distribute reward among all nodes relative to their ownership
func ChooseValidator():
	var randomSelect = []
	for i in range(len(nodeList)):
		for j in range(floori(nodeList[i].currentWallet)):
			randomSelect.append(i)
	var validator = nodeList[randomSelect[randi_range(0, len(nodeList) - 1)]]
	return validator


func IdiosyncraticNodeDecisions():
	pass
