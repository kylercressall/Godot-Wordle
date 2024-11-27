extends Sprite2D

var graybox
var yellowbox
var greenbox

func _ready() -> void:
	graybox = load("res://Assets/boxes/graybox.png")
	yellowbox = load("res://Assets/boxes/yellowbox.png")
	greenbox = load("res://Assets/boxes/greenbox.png")

func gray():
	texture = graybox

func yellow():
	texture = yellowbox

func green():
	texture = greenbox
