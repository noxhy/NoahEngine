extends Node
class_name ZipTools


## path used to create dummy files for resource serialization
static var TEMP_PATH: String = 'user://temp-resource.res'

static func write_snd_to_zip(zip: ZIPPacker, file_name: String, snd_path: String):
	
	if snd_path.begins_with('uid'):
		snd_path = ResourceUID.uid_to_path(snd_path)
	
	var file:FileAccess = FileAccess.open(snd_path, FileAccess.READ)
	if not file:
		printerr("failed to open file for path: ", snd_path)
		return 
	
	zip.start_file(file_name)
	zip.write_file(file.get_buffer(file.get_length()))
	zip.close_file()
	
	file.close()
	
	print('Successfully written to zip')
	


static func write_resource_to_zip(zip: ZIPPacker, file_name: String, resource: Resource):
	if file_name.get_extension().is_empty():
		file_name = file_name + '.res'

	ResourceSaver.save(resource, TEMP_PATH)
	
	zip.start_file(file_name)
	zip.write_file(FileAccess.get_file_as_bytes(TEMP_PATH))
	zip.close_file()
	
	DirAccess.remove_absolute(TEMP_PATH)
	
	print('Successfully written to zip')
