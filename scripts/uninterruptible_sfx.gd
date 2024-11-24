extends AudioStreamPlayer


func start(resource: Resource) -> void:
  stream = resource
  seek(0)
  play()
