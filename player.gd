extends CharacterBody3D

## CHECK ALL STATEMENTS WITH "self.velocity" and test with just "velocity"
const PLAYERSPEED = 2.5
const GRAVITY = -9.8
const JUMPVELOCITY = 1.15
const INITIALZ = -3.75
const HORIZONTALJUMPSPEED = 4.0
const MAXFORWARDVELOCITY = 2.5

var isOnLeftWall = false
var isOnRightWall = false
var isTouchingWall = false
var hasReachedWall = false
var jumpedOnFirstWall = false

var lastPointerState = 0
var startedRunning = false
var isRunningAutomatically = true
var jumping = false

var wallStickPosition = Vector3.ZERO
var lastWallExitPosition = Vector3.ZERO
var currentWall: Node3D

func StartRunning():
	startedRunning = true

func _physics_process(delta):
	var playerVelocity = Vector3.ZERO
	playerVelocity = velocity
	
	if not startedRunning:
		return
	
	if isRunningAutomatically:
		playerVelocity.z = -3.0
		playerVelocity.y += GRAVITY * delta
		velocity = playerVelocity
		
		move_and_slide()
		
		if global_position.z <= INITIALZ:
			print("We should stop running")
			isRunningAutomatically = false
	else:
		HandleWallStickOrJump(delta)
	
	
	if not isOnLeftWall and not isOnRightWall:
		if not jumping:
			playerVelocity.y += GRAVITY * delta
			playerVelocity.z = -(PLAYERSPEED - 0.5)
	
	if not jumping:
		self.velocity = playerVelocity
	else:
		if global_position.y > 1.5 or global_position.y < 0.1:
			jumping = false
	
	move_and_slide()

func HandleWallStickOrJump(delta):
	if isTouchOrMousePressed():
		if not isTouchingWall:
			print("Checking for wall")
			CheckForNearbyWall()
	
	if isTouchingWall and currentWall != null:
		if IsPointerLeftOrRight() != lastPointerState:
			lastWallExitPosition = global_position
			ApplyJump()
			print("Player hopped off?")
			ResetWallState()
		else:
			if not hasReachedWall:
				var directionToWall = (wallStickPosition - global_position).normalized()
				var PlayerVelocity = directionToWall * (PLAYERSPEED + 1.5)
				## apply gravity?
				self.velocity = PlayerVelocity
				self.velocity.y = GRAVITY * delta
				
				PlayerVelocity = PlayerVelocity
				
				move_and_slide()
				
				if global_position.distance_to(wallStickPosition) <= 0.11:
					## snap to pos
					global_position = wallStickPosition
					
					## reset vel
					PlayerVelocity = Vector3.ZERO
					
					hasReachedWall = true
					print("hasReachedWall")
			else:
				print("we reached wall")
				
				var newPosition = global_position
				
				newPosition.z -= PLAYERSPEED * delta
				
				var verticalMovement = GetVerticalMovement()
				newPosition.y = lerp(global_position.y, verticalMovement, 0.35)
				
				global_position = newPosition
				## self.velocity.y += GRAVITY * delta
				
				if global_position.z <= currentWall.global_position.z - currentWall.scale.z * 0.9:
					ApplyJump()
					print("reached end of the wall")
					ResetWallState()

func GetDistanceToNextWall():
	var nextWallZPosition = GetNextWallZPosition()
	var distance = nextWallZPosition - global_position.z
	return abs(distance)

func GetTimeInAir():
	var timeInAir = (2 * JUMPVELOCITY) / -GRAVITY
	return timeInAir

func CalculateRequiredForwardVelocity(distance, timeInAir):
	return distance / timeInAir

func GetNextWallZPosition():
	
	var spaceState = get_world_3d().direct_space_state
	
	var rayDirection = Vector3(0, 0, -1)
	
	if isOnLeftWall:
		## cast ray forward and to the right
		rayDirection = Vector3(1, 0, -1).normalized()
	elif isOnRightWall:
		## cast ray forward and to the left
		rayDirection = Vector3(-1, 0, -1).normalized()
	else:
		## if not on any wall cast ray directly forward
		rayDirection = Vector3(0, 0, -1)
	
	var rayLength = 1.2
	var rayOrigin = global_position + Vector3(0, 0, -0.75)
	var rayEnd = rayOrigin + rayDirection * rayLength
	var rayQuery = PhysicsRayQueryParameters3D.new()
	rayQuery.from = rayOrigin
	rayQuery.to = rayEnd
	rayQuery.exclude = [get_rid()]
	
	var result = spaceState.intersect_ray(rayQuery)
	
	if result.size() > 0:
		var collider = result["collider"] as Node3D
		if collider and collider.name.begins_with("Wall"):
			return collider.global_position.z
	
	return -6.0

func ApplyJump():
	print("Jumping")
	jumping = true
	var jumpVelocity = self.velocity ## Check this statement in partular, unclear what is meant by capital Velocity
	
	## Apply upward velocity
	jumpVelocity.y = JUMPVELOCITY
	
	## Apply horizontal velocity based on wall side
	if isOnLeftWall:
		## Jump towards right
		jumpVelocity.x = HORIZONTALJUMPSPEED
	elif isOnRightWall:
		## Jump towards left
		jumpVelocity.x = -HORIZONTALJUMPSPEED
	else:
		jumpVelocity.x = 0.0
	
	## calculate the distance to the next wall
	var distanceToNextWall = GetDistanceToNextWall()
	print("Distance to next wall: ", distanceToNextWall)
	
	## calculate time in air
	var timeInAir = GetTimeInAir()
	print("Time in air: ", timeInAir)
	
	## calculate the required forward velocity
	var requiredForwardVelocity = CalculateRequiredForwardVelocity(distanceToNextWall, timeInAir)
	print("Required forward velocity: ", requiredForwardVelocity)
	
	## limit forward velocity
	var minForwardVelocity = 2.0
	requiredForwardVelocity = clamp(requiredForwardVelocity, minForwardVelocity, MAXFORWARDVELOCITY)
	
	## set the forward z velo
	jumpVelocity.z = -requiredForwardVelocity
	
	self.velocity = jumpVelocity

func GetVerticalMovement():
	var verticalMovement = global_position.y
	var wallBottom = GetWallBottomBound()
	var wallTop = GetWallTopBound()
	
	var pointerPosition = Vector2.ZERO
	var inputDetected = false
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		pointerPosition = get_viewport().get_mouse_position()
		inputDetected = true
	## this should handle android input
	elif OS.get_name() in ["Android", "iOS"] and Input.is_action_pressed("ui_touch"): ## def look into this, this is dubious af
		pointerPosition = get_viewport().get_mouse_position()
		inputDetected = true
	
	if inputDetected:
		var screenHeight = get_viewport().get_visible_rect().size.y
		var normalizedY = 1.0 - (pointerPosition.y / screenHeight)
		
		var sensitivity = 1.0
		verticalMovement = lerp(wallBottom, wallTop, pow(normalizedY, sensitivity))
	
	return clamp(verticalMovement, wallBottom, wallTop)

func GetWallBottomBound():
	return currentWall.global_position.y - (currentWall.scale.y * 0.275)

func GetWallTopBound():
	return currentWall.global_position.y + (currentWall.scale.y * 0.275)

func ResetWallState():
	isTouchingWall = false
	currentWall = null
	isOnLeftWall = false
	isOnRightWall = false
	hasReachedWall = false
	lastPointerState = 0
	print("reset wall state, ready to find another wall")

func JumpToWall(targetPosition: Vector3):
	wallStickPosition = targetPosition
	## Bad, kept for reference
	#var tween = get_tree().create_tween()
	#var jumpTime = 0.1
	#
	#
	### Tween from current position to target position
	 #
	#tween.tween_property(self,"global_position",targetPosition,jumpTime)
	#tween.set_trans(Tween.TransitionType.TRANS_SINE)
	#tween.set_ease(Tween.EaseType.EASE_IN_OUT)
	#tween.play()

func isTouchOrMousePressed():
	return Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) # or Input.is_action_just_pressed("ui_touch") ## also dubious

func IsPointerLeftOrRight():
	var pointerPosition = Vector2.ZERO
	var inputDetected = false
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		pointerPosition = get_viewport().get_mouse_position()
		inputDetected = true
	elif OS.get_name() in ["Android", "iOS"] and Input.is_action_pressed("ui_touch"):
		pointerPosition = get_viewport().get_mouse_position()
		inputDetected = true
	
	
	if inputDetected:
		var screenWidth = get_viewport().get_visible_rect().size.x
		if pointerPosition.x < screenWidth / 2:
			return 1 ## left
		else:
			return 2 ## right
	
	return 0

func CheckForNearbyWall():
	var spaceState = get_world_3d().direct_space_state
	
	var rayLength = 1.6 ## may need to be tweaked
	
	## Awful but most likely needed
	if jumpedOnFirstWall:
		rayLength = 1.0
	
	var rayOrigin = global_position + Vector3(0, 0, 0)
	var leftDirection = Vector3(-1, 0, -1).normalized() ## Left-forward
	var rightDirection = Vector3(1, 0, -1).normalized() ## Right-forward
	
	var leftRayTo = rayOrigin + leftDirection * rayLength
	var rightRayTo = rayOrigin + rightDirection * rayLength
	
	var leftRayQuery = PhysicsRayQueryParameters3D.new()
	leftRayQuery.from = rayOrigin
	leftRayQuery.to = leftRayTo
	leftRayQuery.exclude = [get_rid()]
	
	var rightRayQuery = PhysicsRayQueryParameters3D.new()
	rightRayQuery.from = rayOrigin
	rightRayQuery.to = rightRayTo
	rightRayQuery.exclude = [get_rid()]
	
	var leftResult = spaceState.intersect_ray(leftRayQuery)
	var rightResult = spaceState.intersect_ray(rightRayQuery)
	
	var foundWall = false
	if leftResult.size() > 0 or rightResult.size() > 0:
		print("Raycast hit a wall")
		
		if leftResult.size() > 0:
			var colliderParent = leftResult["collider"].get_parent() as Node3D
			if colliderParent != null and colliderParent.name.begins_with("Wall_Left_Simple"):
				if IsPointerLeftOrRight() == 1:
					if not jumpedOnFirstWall:
						jumpedOnFirstWall = true
					jumping = false
					lastPointerState = 1
					AttachToWall(colliderParent, true)
					foundWall = true
		
		if rightResult.size() > 0:
			var colliderParent = rightResult["collider"].get_parent() as Node3D
			if colliderParent != null and colliderParent.name.begins_with("Wall_Right_Simple"):
				if IsPointerLeftOrRight() == 2:
					if not jumpedOnFirstWall:
						jumpedOnFirstWall = true
					jumping = false
					lastPointerState = 1
					AttachToWall(colliderParent, true)
					foundWall = true
	
	if not foundWall:
		if IsPointerLeftOrRight() == 1 or IsPointerLeftOrRight() == 2:
			FallIntoVoid()

func FallIntoVoid():
	if currentWall == null:
		return
	
	print("FREEFALLIN")
	
	## ApplyJump() maybe add back
	
	ResetWallState()

func AttachToWall(wall: Node3D, isLeftWall: bool):
	## figure out print later
	
	currentWall = wall
	isTouchingWall = true
	isOnLeftWall = isLeftWall
	isOnRightWall = not isLeftWall
	jumping = false
	
	var clampedY = clamp(global_position.y, GetWallBottomBound(), GetWallTopBound())
	
	var wallHalfWidth = wall.scale.x * 0.5
	var playerHalfWidth = self.scale.x * 0.5
	
	## Adjust X to place the player outside the wall
	var targetXPosition = 0.0
	
	if isLeftWall:
		targetXPosition = wall.global_position.x + wallHalfWidth + playerHalfWidth + 0.1
	else:
		targetXPosition = wall.global_position.x - wallHalfWidth - playerHalfWidth - 0.1
	
	var targetPosition = Vector3(targetXPosition, clampedY, global_position.z)
	
	JumpToWall(targetPosition)
	hasReachedWall = false
