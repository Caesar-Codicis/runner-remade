extends Node3D

const LeftWallScenePath = "res://wall_left_simple.tscn"
const RightWallScenePath = "res://wall_right_simple.tscn"
var leftWallScene: PackedScene
var rightWallScene: PackedScene

var nextLeftWallPositionZ = -6.0
var nextRightWallPositionZ = -8.0
var simpleWallCount = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	leftWallScene = load(LeftWallScenePath)
	rightWallScene = load(RightWallScenePath)

func StartGenerating():
	for i in range(1250):
		GenerateSimpleWalls(i)

func GenerateSimpleWalls(n):
	## simple left wall
	
	if leftWallScene != null:
		var leftWall = leftWallScene.instantiate() as MeshInstance3D
		var leftWallY = GetRandomY()
		var positionZ = randf_range(3.5,3.5+(5.25-3.5)*(1/(n+1)))
		if simpleWallCount == 1:
			leftWallY = 1.0
			positionZ = 4.5
		
		var CurrentScale = leftWall.scale
		CurrentScale.y = randf_range(1.5, 5)
		CurrentScale.z = positionZ - 2.0
		leftWall.scale = CurrentScale
		leftWall.position = Vector3(-0.75, leftWallY, nextLeftWallPositionZ)
		leftWall.name = "Wall_Left_Simple%d" % simpleWallCount
		add_child(leftWall)
		
		nextLeftWallPositionZ -= positionZ
	
	## simple right wall
	
	if rightWallScene != null:
		var rightWall = rightWallScene.instantiate() as MeshInstance3D
		var positionZ = randf_range(3.5,3.5+(5.25-3.5)*(1/(n+1)))
		var rightWallY = GetRandomY()
		rightWall.position = Vector3(0.75, rightWallY, nextRightWallPositionZ)
		var CurrentScale = rightWall.scale
		CurrentScale.y = randf_range(1.5,5)
		CurrentScale.z = positionZ - 2.0
		rightWall.scale = CurrentScale
		rightWall.name = "Wall_Right_Simple%d" % simpleWallCount
		add_child(rightWall)
		
		nextRightWallPositionZ -= positionZ
		
	simpleWallCount += 1

func GetRandomY():
	return randf_range(1.0,1.25)
