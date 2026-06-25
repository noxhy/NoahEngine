extends Node
class_name ZipTools


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
	
