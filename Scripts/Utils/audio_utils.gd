class_name AudioUtils extends RefCounted

static func _play_sound_effect(node: Node, sound_effect: AudioStream, volume: float = 0.0) -> void:
	if not sound_effect or not node:
		return
	var player = AudioStreamPlayer.new()
	node.get_tree().root.add_child(player)
	player.stream = sound_effect
	player.volume_db = volume
	player.play()
	player.finished.connect(player.queue_free)
