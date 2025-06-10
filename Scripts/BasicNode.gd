extends Node2D

class_name BasicNode

@export var spriteList : Array[CompressedTexture2D]
@export var sprite : Sprite2D
@export var neighbors : Array[BasicNode]
@export var nodeLabel : Label
@export var powerLabel : Label
@export var communityLabel : Label
@export var currentHops : int
@export var likelihoodOfBuyingGPU : float = 0.5
@export var likelihoodOfSpendingFromOutside : float = 0.01
@export var minimumHoldingAmount : float = 10.0
@export var likelihoodOfAddingFunds : float = 0.01
@export var howRichIsThisGuy : float = 1.0
var simulationDelay : float
enum NodeState {IDLE, SPREADINGTRANSACTION, TRANSACTING, VALIDATING, ADDINGTOCHAIN}
enum LabelState {WALLET, POWERRANKING, COMMUNITY}
var parentChain : BlockChain
var currentState = NodeState.IDLE
var nodeName : String = "Basic"
var nodeID : int = 0
var currentBlockChain : Array = []
var currentBroadcasts : Dictionary = {}
var currentWallet = 1.0
var lines : Array[Line2D] = []
var originalLineColor : Color = Color(0, 0, 0)
var hasValidated = false
var isValidator = false
var powerRanking = 1
var showLabel = true
var nodeDebugLog = []
var lastHundredDays = []
var updatedToday = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	nodeLabel.text = "Name: " + nodeName + "\nWallet: " + str(snappedf(currentWallet, 0.01))
	powerLabel.text = str(powerRanking)


"""================================
Debug, Setup, and Utility
================================"""

func PrintState():
	print(nodeName + " with ID " + str(nodeID) + " is in state: " + NodeState.find_key(currentState))


func PrintCurrentBlockChain():
	for block in currentBlockChain:
		print("From " + nodeName + ":" + str(nodeID) + ":\t" + block)


func ConnectToNeighbors(lineColor : Color):
	for neighbor in neighbors:
		if self not in neighbor.neighbors:
			neighbor.neighbors.append(self)
		var line = Line2D.new()
		get_parent().add_child(line)
		line.position -= get_parent().position
		line.z_index = -1
		line.add_point(Vector2(neighbor.global_position.x, neighbor.global_position.y))
		line.add_point(Vector2(global_position.x, global_position.y))
		line.default_color = lineColor
		originalLineColor = lineColor
		lines.append(line)
		parentChain.lineList.append(line)
		neighbor.lines.append(line)


func PrintFullBlockChain():
	var returnStr = ""
	for line in currentBlockChain:
		returnStr += str(line)
		returnStr += "\n	|\n	|\n	|\n"
		#print(line)
		#print("	|")
		#print("	|")
		#print("	|")
	returnStr += "Waiting for next block - [ ]"
	return returnStr


"""================================
Self-Action Management
================================"""

func StartTransaction(buyer : BasicNode, seller : BasicNode, amount : float, numHops : int):
	ManageState(NodeState.TRANSACTING)
	var transactionString = buyer.nodeName + " buys from "\
		+ seller.nodeName + " for a total of "\
		+ str(amount) 
	var hashable = [buyer, seller].hash()
	currentBroadcasts[hashable] = transactionString
	BroadcastTransaction(hashable, buyer, seller, transactionString, numHops)
	if !updatedToday:
		lastHundredDays.append(Vector2(0,0))
		updatedToday = true
	lastHundredDays[-1].x += 1
	lastHundredDays[-1].y += amount


func CreateNewBlock():
	ManageState(NodeState.VALIDATING)
	var newBlock : Array[String] = []
	for key in currentBroadcasts.keys():
		newBlock.append(currentBroadcasts[key])
	return newBlock


func ChangeLines(newColor : Color):
	for line in lines:
		line.default_color = newColor

"""================================
Communication Management
================================"""

func CompareChainWithOtherNode(otherNode : BasicNode):
	if currentBlockChain.hash() == otherNode.currentBlockChain.hash():
		return true
	else:
		return false


func BroadcastTransaction(hashable : int, buyer : BasicNode, seller : BasicNode, transaction : String, numHops : int):
	if numHops > 0:
		for neighbor in neighbors:
			#print(nodeName + " is broadcasting a transaction to " + neighbor.name)
			if neighbor != buyer and neighbor != seller:
				#print("	" + neighbor.name + str(neighbor.nodeID) + " has received the transaction")
				neighbor.ReceiveTransaction(hashable, buyer, seller, transaction, numHops - 1)
				if simulationDelay > 0:
					await get_tree().create_timer(simulationDelay).timeout
		ChangeLines(Color(1, 1, 0))


func ReceiveTransaction(hashable : int, buyer : BasicNode, seller : BasicNode,  transaction : String, numHops : int):
	if !(hashable in currentBroadcasts.keys()):
		currentBroadcasts[hashable] = transaction
		BroadcastTransaction(hashable, buyer, seller, transaction, numHops)


func ClearTransaction(hashable : int):
	if hashable in currentBroadcasts.keys():
		currentBroadcasts.erase(hashable)


func ValidateBlock(newBlock, keysToClear, numHops : int):
	if !hasValidated or isValidator:
		if !isValidator:
			ManageState(NodeState.ADDINGTOCHAIN)
		if !(newBlock in currentBlockChain):
			currentBlockChain.append(newBlock)
		for key in keysToClear:
			ClearTransaction(key)
		ChangeLines(Color(0, 1, 0))
		BroadcastValidate(newBlock, keysToClear, numHops)


func BroadcastValidate(newBlock, keysToClear, numHops : int):
	if numHops > 0:
		for neighbor in neighbors:
			#print(nodeName + " is broadcasting a validation to " + neighbor.name)
			neighbor.ValidateBlock(newBlock, keysToClear, numHops - 1)
			if simulationDelay > 0:
				await get_tree().create_timer(simulationDelay).timeout


"""================================
State Machine
================================"""

func ManageState(newState : NodeState):
	match newState:
		NodeState.IDLE:
			ChangeLines(originalLineColor)
			hasValidated = false
			isValidator = false
			if !updatedToday:
				lastHundredDays.append(Vector2(0,0))
				if len(lastHundredDays) > 100:
					lastHundredDays.remove_at(0)
			sprite.texture = spriteList[0]
			currentState = NodeState.IDLE
		NodeState.SPREADINGTRANSACTION:
			currentState = NodeState.SPREADINGTRANSACTION
		NodeState.TRANSACTING:
			sprite.texture = spriteList[1]
			currentState = NodeState.TRANSACTING
		NodeState.VALIDATING:
			isValidator = true
			sprite.texture = spriteList[2]
			currentState = NodeState.VALIDATING
		NodeState.ADDINGTOCHAIN:
			hasValidated = true
			sprite.texture = spriteList[3]
			currentState = NodeState.ADDINGTOCHAIN


func ManageLabelState(newState : LabelState):
	match newState:
		LabelState.WALLET:
			nodeLabel.visible = true
			powerLabel.visible = false
			communityLabel.visible = false
		LabelState.POWERRANKING:
			nodeLabel.visible = false
			powerLabel.visible = true
			communityLabel.visible = false
		LabelState.COMMUNITY:
			nodeLabel.visible = false
			powerLabel.visible = false
			communityLabel.visible = true
