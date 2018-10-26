extends Control

enum Stages {FOREST, TEMPLE, TOWER, CAVE, RANDOM}

const descriptions = ["This forest is cool",
	"Devoted to the God of Destruction",
	"I don't even",
	"WIP",
	"Only for the boldest"]
const names = ["Cool Forest", "Temple of Kei", "Tower of Gyro",
	"Ice Cave", "Random"]
const stage_scenes = ["res://stages/Forest/Forest.tscn",
	"res://stages/Temple/Temple.tscn",
	"",
	""]

onready var stage_desc = $StageInfo/Descritption
onready var stage_name = $StageInfo/Name

# Used for testing purposes while we don't have all stages (and if we want to
# have unlockable stages eventually)
var enabled_stages = [FOREST, TEMPLE]

func _ready():
	$Stages/Forest.grab_focus()
	randomize()


func _on_Stage_pressed(stage):
	if stage == RANDOM:
		stage = enabled_stages[randi() % enabled_stages.size()]
	get_tree().change_scene(stage_scenes[stage])


func _on_Stage_focus_entered(stage):
	stage_name.text = names[stage]
	stage_desc.text = descriptions[stage]
