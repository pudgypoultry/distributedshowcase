extends Node2D

class_name BlockChain

@export var basicNode : PackedScene
@export var nodeList : Array[BasicNode] = []
@export var lineList : Array[Line2D] = []
@export var spawnDistanceMultiplier = 115
@export var simulationDelay : float = 0.01
@export var initialAmount : int = 4
var theBlockChain : Array = []
var currentSpawnPosition : Vector2 = Vector2(0, 0)
var spawnDifference : float = 0.01
var currentTransactors : Array[BasicNode] = []
var numHops : int = 10


"""================================
Debug, Setup, and Utility
================================"""

func _ready() -> void:
	for i in range(initialAmount):
		AddNodeToSystem()
		await get_tree().create_timer(spawnDifference).timeout
	numHops = 10 + floori(sqrt(len(nodeList)))

func NumberSpiral(x, y):
	#print("Input: ", "(", str(x), ",", str(y), ")")
	var n = len(nodeList) + 1
	var k = ceil(((sqrt(n) - 1.0) / 2.0))
	var t = 2 * k + 1
	var m = pow(t, 2)
	var ret : Vector2
	t = t - 1
	
	if n >= m - t:
		ret = Vector2(k - (m - n), -k)
		#print("Output 1: ", "(", ret.x, ",", ret.y, ")")
		return ret
	else:
		m = m - t
	
	if n >= m - t:
		ret = Vector2(-k, -k + (m - n))
		#print("Output 2: ", "(", ret.x, ",", ret.y, ")")
		return ret
	else:
		m = m - t
	
	if n >= m - t:
		ret = Vector2(-k + (m - n), k)
		#print("Output 3: ", "(", ret.x, ",", ret.y, ")")
		return ret
	else:
		ret = Vector2(k, k - (m - n - t))
		#print("Output 4: ", "(", ret.x, ",", ret.y, ")")
		return ret


"""================================
Simulation Management
================================"""


func AddToChain(newBlock : String):
	theBlockChain.append(newBlock)


func AddNodeToSystem():
	var totalNodes = len(nodeList)
	var sqrtOfTotal = floori(sqrt(totalNodes))
	var copyNodeList = nodeList.duplicate()
	var newNode : BasicNode = basicNode.instantiate()
	var currentHue = randf()
	var nodeLineColor : Color = Color(currentHue, currentHue, currentHue, 1.0)
	add_child(newNode)
	newNode.parentChain = self
	newNode.simulationDelay = simulationDelay
	nodeList.append(newNode)
	newNode.position = spawnDistanceMultiplier * currentSpawnPosition
	currentSpawnPosition = NumberSpiral(currentSpawnPosition.x, currentSpawnPosition.y)
	newNode.nodeID = totalNodes + 1
	newNode.nodeName = "Node" + str(newNode.nodeID)
	newNode.currentWallet = randf_range(0, 10)
	newNode.currentBlockChain = theBlockChain
	if totalNodes > 0:
		for i in range(randi_range(1, sqrtOfTotal)):
			var neighborIndex = randi_range(0, totalNodes - i - 1)
			newNode.neighbors.append(copyNodeList[neighborIndex])
			copyNodeList.remove_at(neighborIndex)
			newNode.ConnectToNeighbors(nodeLineColor)


func StartTransaction():
	for line in lineList:
		line.default_color = Color(0,0,0)
	print("=========================================")
	var node1 = randi_range(0, len(nodeList) - 1)
	var node2 = randi_range(0, len(nodeList) - 1)
	while node1 == node2:
		node2 = randi_range(0, len(nodeList) - 1)
	var buyer = nodeList[node1]
	var seller = nodeList[node2]
	currentTransactors.append(buyer)
	currentTransactors.append(seller)
	var amount = randf_range(0.1, buyer.currentWallet)
	buyer.StartTransaction(buyer, seller, amount, numHops)
	seller.StartTransaction(buyer, seller, amount, numHops)


func StartValidation():
	print("=========================================")
	var validatingNode = ChooseValidator()
	var blockToAdd = validatingNode.CreateNewBlock()
	theBlockChain.append(blockToAdd)
	var keysToClear = []
	for key in validatingNode.currentBroadcasts.keys():
		keysToClear.append(key)
	validatingNode.ValidateBlock(blockToAdd, keysToClear, numHops)
	UniqueValidatorBehavior(validatingNode)


func PrepareChainForNextStep():
	print("=========================================")
	print("Preparing for next series of inputs")
	for currentNode in nodeList:
		currentNode.ManageState(BasicNode.NodeState.IDLE)


func CheckEquality():
	var isCorrect = true
	var first : BasicNode = nodeList[0]
	var failure : int
	print("=========================================")
	for i in range(len(nodeList)):
		if !first.CompareChainWithOtherNode(nodeList[i]):
			isCorrect = false
			failure = i
			break
	if isCorrect:
		print(first.currentBlockChain)
	else:
		print("First node was not the same as node: " + str(failure))


func UniqueValidatorBehavior(validator : BasicNode):
	pass


# Simple simulation is uniform random selection from list of nodes that aren't transacting
func ChooseValidator():
	var whichNode = randi_range(0, len(nodeList) - 1)
	while nodeList[whichNode] in currentTransactors:
		whichNode = randi_range(0, len(nodeList) - 1)
	currentTransactors = []
	return nodeList[whichNode]
