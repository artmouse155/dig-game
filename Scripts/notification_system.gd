extends Node2D

const NOTIFICATION_TIME : float = 5
const NOTIFICATION_ANIM_TIME : float = 1
const NOTIFICATION_MOVE_UP_ANIM_TIME : float = .5
const NOTIFICATION_Y_SEPARATION : int = 200
const NOTIFICATION_X_INIT_OFFSET : int = -700
const NOTIFICATION_X_FINAL_OFFSET : int = 0

@export var packed_notification : PackedScene

var pending_notifications : Array[Node] = []
var active_notifications : Array[Node] = []

var queue_loop_active = false

func add_recipe_found_notification(obj : DrillerComponentObject):
	var temp_notification = packed_notification.instantiate()
	add_child(temp_notification)
	temp_notification.position.x = NOTIFICATION_X_INIT_OFFSET
	add_notification_to_queue(temp_notification)
	temp_notification.recipe_found_setup(obj)

func add_achievement_notification(achievement : Achievement):
	var temp_notification = packed_notification.instantiate()
	add_child(temp_notification)
	temp_notification.position.x = NOTIFICATION_X_INIT_OFFSET
	add_notification_to_queue(temp_notification)
	temp_notification.achievement_setup(achievement)

func add_notification_to_queue(n : Node):
	pending_notifications.append(n)
	if (len(pending_notifications) == 1) and (not queue_loop_active):
		move_notification_from_queue_to_active()

func move_notification_from_queue_to_active():
	if (len(pending_notifications) > 0):
		queue_loop_active = true
		var move_tweener = create_tween()
		if (len(active_notifications) > 0):
			move_tweener.tween_callback(move_up_active_notifications)
			move_tweener.tween_interval(NOTIFICATION_MOVE_UP_ANIM_TIME)
		move_tweener.tween_callback(next_notification)
		move_tweener.tween_interval(NOTIFICATION_ANIM_TIME)
		move_tweener.tween_callback(move_notification_from_queue_to_active)#.set_delay(NOTIFICATION_ANIM_TIME)
	else:
		queue_loop_active = false

func move_up_active_notifications():
	for i in range(len(active_notifications)):
		#extra_delay = NOTIFICATION_ANIM_TIME
		move_up_notification(active_notifications[i])

func next_notification():
	
	#var extra_delay = 0
	
	#for i in range(len(active_notifications)):
	#	extra_delay = NOTIFICATION_ANIM_TIME
	#	move_up_notification(active_notifications[i])
	var n = pending_notifications.pop_at(0)
	active_notifications.append(n)
	var x_tween = create_tween()
	n.position.x = NOTIFICATION_X_INIT_OFFSET
	x_tween.tween_property(n, "position:x", NOTIFICATION_X_FINAL_OFFSET, NOTIFICATION_ANIM_TIME).set_trans(Tween.TRANS_QUINT).set_delay(0)
	#x_tween.tween_callback(x_tween.kill)
	x_tween.tween_property(n, "position:x", NOTIFICATION_X_INIT_OFFSET, NOTIFICATION_ANIM_TIME).set_trans(Tween.TRANS_QUINT).set_delay(NOTIFICATION_TIME)
	x_tween.tween_callback(remove_notification.bind(n))

func move_up_notification(n : Node):
	var y_tween = create_tween()
	y_tween.tween_property(n, "position:y", n.position.y - NOTIFICATION_Y_SEPARATION, NOTIFICATION_ANIM_TIME).set_trans(Tween.TRANS_SINE)

func remove_notification(n : Node):
	active_notifications.erase(n)
	n.queue_free()
	
