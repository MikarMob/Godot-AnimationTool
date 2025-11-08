@tool

extends AnimationPlayer

class_name AnimationTool_Aseprite

@export_category("需读取文件夹路径")
##用于确定当需读取文件夹的路径
@export var File_Path : String

@export_category("动画已储存文件")
##用于储存已读取的json文件
var AnimArr : Array[Dictionary]
var FramesArr : Array[Dictionary]
##用于保存重要帧信息
var AnimFrames :Dictionary
var Setting :bool

@export var SettingArr : Array[Dictionary]

##用于确定文件前缀（获取键）meta ： Aseprite 文件， frameTags ： Aseprite 动画文件储存位置 ， size ： 图片大小
var meta = "meta"
var frames = "frames"

var frameTags = "frameTags"
var size : Vector2

var key_name = "name"
var key_fps = "fps"
var key_speed_scale = "speed_scale"
var ket_from = "from"
var key_to = "to"
var key_cycle = true
var AnimDicKeyName : String
var FlipSet : Vector2i
var Rect2D : Rect2

@export_category("精灵组")
##加入精灵组
@export var SpriteGroup  : Array[NodePath]

#读取函数===========================================================================================
##用于读取文件数据
func FileGet():
	AnimFrames.clear()
	AnimArr.clear()
	SettingArr.clear()
	Rect2D = Rect2(0,0,0,0)
	
	var Dir = DirAccess.open(File_Path)
	if Dir :
		Dir.list_dir_begin()
		var DirName = Dir.get_next()
		
		while DirName != "":
			if Dir.current_is_dir():
				print("已找到文件夹" + DirName)
			
			else:
				print("已找到文件")
				var File = File_Path + DirName
				if FileAccess.file_exists(File):
					var FileOpen = FileAccess.open(File , FileAccess.READ)
					var FileJsonRead = JSON.parse_string(FileOpen.get_as_text())
					AnimArr.assign(FileJsonRead.get("meta").get("frameTags")) 
					for i in AnimArr:
						i["cycle"] = key_cycle
						size = Vector2(FileJsonRead.get("meta").get("size").get("w") , FileJsonRead.get("meta").get("size").get("h"))
						var _rest_size : Vector2
						FramesArr.assign(FileJsonRead.get("frames"))
						var _index = i["from"]
						if Rect2D == Rect2(0,0,0,0):
							Rect2D.position = Vector2(0,0)
							Rect2D.end =Vector2(FileJsonRead.get("meta").get("size").get("w"),FileJsonRead.get("meta").get("size").get("h"))
						i["FlipSet"] = Vector2(FramesArr[_index].get("sourceSize").get("w"),FramesArr[_index].get("sourceSize").get("h"))
						i["region_rect"] = size
						i["speed_scale"] = FileJsonRead.get("meta").get("scale") as float
						var _Filpset = i["FlipSet"]
						i["hframes"] = size.x / _Filpset.x
						i["vframes"] = size.y / _Filpset.y
						i["fps"] = 1 / FramesArr[i["from"]].get("duration") * 1000 as int
						SettingArr.append(i)
			DirName =Dir.get_next()
	
	else:
		print("找不到文件路径")

@export_category("动画相关设置")
##输入动画组名，自定义,指示器： LibName + TypeName = AnimName 用于动画分组
@export var LibName = ""
##输入类型名，自定义,指示器： LibName + TypeName = AnimName 用于动画分组
@export var TypeName = ""



var AnimTrack  : Array

##动画设置代指
var from :int 
var to :int 
var AnimName : String
var Size : Vector2
var region_rect : Rect2
var hframes : int
var vframes : int 
var anim_speed_scale : float
var fps : int
var animspeed : float
var animlib : String
var cycle : bool

#用于创建动画=========================================================================================
##用于创建动画
func AnimSetting():
	for sprite in SpriteGroup :
		if sprite != null:
			var _Sprite2D := get_node(sprite) as Sprite2D
			_Sprite2D.region_rect = Rect2D
	animlib = LibName + "_" + TypeName
	for i in SettingArr:
		if i != null:
			from = i["from"]
			
			to = i["to"]
			AnimName = i["name"]
			Size = Vector2(i["region_rect"].x,i["region_rect"].y)
			hframes = i["hframes"]
			vframes = i["vframes"]
			fps = i["fps"] as int
			cycle = i["cycle"]
			var _scale = i["speed_scale"] as float
			anim_speed_scale = _scale
			
			
			animspeed = 1.0 / fps / anim_speed_scale
			region_rect = Rect2(Vector2(0,0) , Size)
			
			var AnimName_All = animlib + "/"+ AnimName
			
			
			for sprite in SpriteGroup:
				if sprite != null :
					var Sprite_2D  := get_node(sprite) as Sprite2D
					var anim = Animation
					
					#有动画时
					if has_animation(AnimName_All):
						anim = get_animation(AnimName_All)
						anim.length = (to - from + 1) * animspeed
						
						#查找并设置frame轨道==========================================================
						if anim.find_track(str(owner.get_path_to(Sprite_2D)) + ":frame" , Animation.TYPE_VALUE) == -1:
							
							
							var frametrack = anim.add_track(Animation.TYPE_VALUE,-1)
							FrameCreate(anim , frametrack , animspeed , Sprite_2D)
						
						else:
							
							var frametrack = anim.find_track(str(owner.get_path_to(Sprite_2D)) + ":frame" , Animation.TYPE_VALUE)
							
							FrameCreate(anim , frametrack , animspeed , Sprite_2D)
						
						#查找并设置hframes轨道========================================================
						if anim.find_track(str(owner.get_path_to(Sprite_2D)) + ":hframes" , Animation.TYPE_VALUE) == -1:
							
							
							var hframestrack = anim.add_track(Animation.TYPE_VALUE,-1)
							HframesCreate(anim , hframestrack  , Sprite_2D )
						
						else:
							
							var hframestrack = anim.find_track(str(owner.get_path_to(Sprite_2D)) + ":hframes" , Animation.TYPE_VALUE)
							
							HframesCreate(anim , hframestrack  , Sprite_2D)
						
						#查找并设置vframes轨道========================================================
						if anim.find_track(str(owner.get_path_to(Sprite_2D)) + ":vframes" , Animation.TYPE_VALUE) == -1:
							
							
							var vframestrack = anim.add_track(Animation.TYPE_VALUE,-1)
							VframesCreate(anim , vframestrack , Sprite_2D )
						
						else:
							
							var vframestrack = anim.find_track(str(owner.get_path_to(Sprite_2D)) + ":vframes" , Animation.TYPE_VALUE)
							
							VframesCreate(anim , vframestrack , Sprite_2D )
						
						#查找并设置region_rect轨道========================================================
						if anim.find_track(str(owner.get_path_to(Sprite_2D)) + ":region_rect" , Animation.TYPE_VALUE) == -1:
							
							
							var region_rect_track = anim.add_track(Animation.TYPE_VALUE,-1)
							Region_Rect_Create(anim , region_rect_track , Sprite_2D )
						
						else:
							
							var region_rect_track = anim.find_track(str(owner.get_path_to(Sprite_2D)) + ":region_rect" , Animation.TYPE_VALUE)
							
							Region_Rect_Create(anim , region_rect_track , Sprite_2D )
						
						
						
					#无动画时
					if ! has_animation(AnimName_All):
						
						anim = Animation.new()
						anim.length = (to - from + 1) * animspeed
						
						
						#设置frame轨道===========================================
						var frametrack = anim.add_track(Animation.TYPE_VALUE)
						FrameCreate(anim , frametrack , animspeed , Sprite_2D)
						
						#设置hframes轨道=========================================
						var hframestrack = anim.add_track(Animation.TYPE_VALUE)
						HframesCreate(anim , hframestrack , Sprite_2D )
						
						#设置vframes轨道=========================================
						var vframestrack = anim.add_track(Animation.TYPE_VALUE)
						VframesCreate(anim , vframestrack , Sprite_2D )
						
						#设置region_rect轨道=====================================
						var region_rect_track = anim.add_track(Animation.TYPE_VALUE)
						Region_Rect_Create(anim, region_rect_track , Sprite_2D )
						
						
						
						#创建动画
						if ! has_animation_library(animlib):
							add_animation_library(animlib , AnimationLibrary.new())
						get_animation_library(animlib).add_animation(AnimName , anim)
					
						
			

#创建frame轨道=======================================================================================
##用于frame轨道创建
func FrameCreate(Anim , frametrack , _animspeed , Sprite_2D):
	
	Anim.track_set_path(frametrack , str(owner.get_path_to(Sprite_2D)) + ":frame")
	Anim.value_track_set_update_mode(frametrack, Animation.UPDATE_DISCRETE)
	for i in range(from , to + 1):
		Anim.track_insert_key(frametrack , (i - from) * _animspeed , i)
	
	if cycle :
		Anim.loop_mode = Animation.LOOP_LINEAR
	else:
		Anim.loop_mode = Animation.LOOP_NONE



#创建hframes轨道=====================================================================================
##用于hframes轨道创建
func HframesCreate(Anim , hframestrack , Sprite_2D ):
	Anim.track_set_path(hframestrack , str(owner.get_path_to(Sprite_2D)) + ":hframes")
	Anim.value_track_set_update_mode(hframestrack, Animation.UPDATE_DISCRETE)
	Anim.track_insert_key(hframestrack , 0 , hframes)
	
	if cycle :
		Anim.loop_mode = Animation.LOOP_LINEAR
	else:
		Anim.loop_mode = Animation.LOOP_NONE

#创建vframes轨道=====================================================================================
##用于hframes轨道创建
func VframesCreate(Anim , vframestrack , Sprite_2D ):
	Anim.track_set_path(vframestrack , str(owner.get_path_to(Sprite_2D)) + ":vframes")
	Anim.value_track_set_update_mode(vframestrack, Animation.UPDATE_DISCRETE)
	Anim.track_insert_key(vframestrack , 0 , vframes)
	
	if cycle :
		Anim.loop_mode = Animation.LOOP_LINEAR
	else:
		Anim.loop_mode = Animation.LOOP_NONE

#创建region_rect轨道=====================================================================================
##用于region_rect轨道创建
func Region_Rect_Create(Anim , region_rect_track , Sprite_2D ):
	Anim.track_set_path(region_rect_track , str(owner.get_path_to(Sprite_2D)) + ":region_rect")
	Anim.value_track_set_update_mode(region_rect_track, Animation.UPDATE_DISCRETE)
	Anim.track_insert_key(region_rect_track , 0 , region_rect)
	
	if cycle :
		Anim.loop_mode = Animation.LOOP_LINEAR
	else:
		Anim.loop_mode = Animation.LOOP_NONE




@export_category("用于创建动画")
#Mikar·mob
##点击创建读取的文件
@export var 读取文件 : bool:
	set(v):
		if v:
			FileGet()

@export var 创建动画 : bool :
	set(v):
		if v :
			AnimSetting()
