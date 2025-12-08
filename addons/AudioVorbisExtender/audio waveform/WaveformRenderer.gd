class_name WaveformRenderer
extends WaveFormMesh

const DEFAULT_COLOR = Color.WHITE
const DEFAULT_DURATION = 5.0
const DEFAULT_WIDTH = 100.0
const DEFAULT_HEIGHT = 100.0

var line_width = -1.0
var draw_bg = false
var bg_color = null

var keepData = false #be warned keeping the waveform data can cause very large memory spikes,
#so be sure to clear it at some point if you enable this


var waveformdata:WaveformData = null
var showRenderTime = false

var width = null 
#width is assumed to be the length of the song in pixels by default

var height = DEFAULT_HEIGHT 
#on the other hand height CAN be assigned

var amplitude = 200.0



var duration = null

var anti_aliasing = false
var minWaveformSize = 0.5


var orientation := WaveformOrientation.HORIZONTAL



var time = 0

enum WaveformOrientation {VERTICAL, HORIZONTAL}


var color = DEFAULT_COLOR
var texture:Texture2D = null

#debug option for making blank waveforms
var useDummy = false

#create accepts a path to an ogg a waveform color
func create(InitialData, this_color:Color = DEFAULT_COLOR,background_color = null,visible_duration = null):
	match InitialData:
		WaveformData:
			waveformdata = InitialData
		_:
			if typeof(InitialData) == TYPE_STRING:
				waveformdata = WaveformDataParser.interpretSound(InitialData)
				if waveformdata == null:
					return
			else:
				push_error("Initial Waveform input must be Waveform data or a path to the sound!!")
				return


	if visible_duration == null:
		#something something pixel something something, basically 130 
		#allows me to actually see the whole waveform
		visible_duration = waveformdata.songLength * 130
	
	
	duration = visible_duration
	
	
	if width == null: 
		width = DEFAULT_WIDTH
	if height == null:
		height = DEFAULT_HEIGHT
	
	
	color = this_color
	
	if background_color != null:
		#assume that the bg SHOULD be drawn
		draw_bg = true
		if typeof(background_color) == TYPE_COLOR:
			bg_color = background_color
		elif typeof(background_color) == TYPE_OBJECT:
			if background_color is Texture2D:
				texture = background_color
				bg_color = DEFAULT_COLOR
		else:
			print("%s is not a valid texture or color!" %[this_color])
	else:
		if bg_color == null:
			draw_bg = false
	
	drawWaveform()
	orient()





func setOrientation(value:String):
	match value:
		"HORIZONTAL":
			orientation = WaveformOrientation.HORIZONTAL
		"VERTICAL":
			orientation = WaveformOrientation.VERTICAL
		_:
			push_error("INVALID ORIENTATION !!")

func drawWaveform():
	clear()
	
	var startRenderTime = 0
	if waveformdata == null:
		push_error("no waveform found at all, try using create()")
		return
	
	if waveformdata.data.is_empty():
		push_error("waveform data is empty, re-gen the waveform data!!")
		return
		
		
	var waveformCenterPos = int(height / 2)
	
	
	if showRenderTime:
		startRenderTime = Time.get_ticks_msec()
	
	buildLength(waveformCenterPos)
	build()
	
	
	if not keepData:
		waveformdata.clear_data()
		waveformdata = null
		push_warning("data rendered, clearing waveform data!")
		return
	
	
	#this MIGHT work to show render time?, chat can i get some help
	if showRenderTime:
		await get_tree().process_frame
		var endRenderTime = Time.get_ticks_msec()
		var elapsed = endRenderTime - startRenderTime
		print("elapsed render time from %s : %s" %[self.name,elapsed])

func buildLength(waveformCenterPos):
	var startIndex = waveformdata.secondsToIndex(time)
	var Index = waveformdata.secondsToIndex(duration)
	
	var pixelsPerIndex = float(width) / (Index)
	var indexesPerPixel = 1 / pixelsPerIndex
	
	var this_channel = waveformdata.channel(0)
	
	for pixel in range(0,width):
		var sampleMax = 0
		var sampleMin = 0
		
		var rangeStart = int(pixel * indexesPerPixel + startIndex)
		var rangeEnd = int((pixel + 1) * indexesPerPixel + startIndex)
		if not useDummy:
			#these two functions are the primary cost heavy ones, theyre why i cant rerender it live
			#print(this_channel.maxSampleRangeMap(rangeStart,rangeEnd)," ",this_channel.minSampleRangeMap(rangeStart,rangeEnd))
			sampleMax = min(this_channel.maxSampleRangeMap(rangeStart,rangeEnd) * amplitude,1.0)
			sampleMin = max(this_channel.minSampleRangeMap(rangeStart,rangeEnd) * amplitude,-1.0)
			
		
		
		
		var sampleMaxSize = 0
		var sampleMinSize = 0
		if sampleMax + sampleMin != 0:
			sampleMaxSize = sampleMax * height / 2
			if sampleMaxSize < minWaveformSize: sampleMaxSize = minWaveformSize

			sampleMinSize = sampleMin * height / 2
			if sampleMinSize > -minWaveformSize: sampleMinSize = -minWaveformSize
		var vertexTopY = int(waveformCenterPos - sampleMaxSize)
		var vertexBottomY = int(waveformCenterPos - sampleMinSize)
		build_line(vertexTopY,vertexBottomY,pixel)
	return










func _draw():
	if draw_bg:
		if texture != null:
			draw_texture_rect(texture,Rect2(0,0,width,height),true,bg_color)
		else:
			draw_rect(Rect2(0,0,width,height),bg_color)
	
	if vertices.is_empty():
		return
	draw_polyline(vertices, color,line_width,anti_aliasing)



var is_dirty = false


#queuing redraw is actually cheap so i can just always do that incase any options change
func _process(_delta):
	queue_redraw()
	if is_dirty:
		drawWaveform()
		is_dirty = false


func orient():
	match orientation:
		WaveformOrientation.VERTICAL:
			rotation = deg_to_rad(90)
		WaveformOrientation.HORIZONTAL:
			rotation = deg_to_rad(0)


func _exit_tree():
	#just in case theres some mis-management with waveform data
	if waveformdata:
		waveformdata.clear_data()
		waveformdata = null
		push_warning("waveform rendererer is exiting the tree, clearing waveform data")


class WaveFormMesh:
	extends Node2D
	var vertices = []
	
	func build_line(y, yy, x,to = vertices):
		var line = [Vector2(x, y),Vector2(x, yy)]
		to.append_array(line)
	
	func clear():
		vertices.clear()
	
	func build():
		vertices = PackedVector2Array(vertices)
