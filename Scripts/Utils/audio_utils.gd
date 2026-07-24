class_name AudioUtils extends RefCounted

static func _play_sound_effect(node: Node, sound_effect: AudioStream) -> void:
	if not sound_effect or not node:
		return
	var player = AudioStreamPlayer.new()
	node.get_tree().root.add_child(player)
	player.stream = sound_effect
	player.play()
	player.finished.connect(player.queue_free)
