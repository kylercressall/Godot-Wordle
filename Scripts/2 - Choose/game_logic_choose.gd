extends Node2D

var sprites = []
var labels = []
var valid_words = []

var guesses = 0
var current_word = ""
var word_to_guess = ""
var game_start = false

var darkgraybox = load("res://Assets/boxes/darkgraybox.png")
var graybox = load("res://Assets/boxes/graybox.png")
var yellowbox = load("res://Assets/boxes/yellowbox.png")
var greenbox = load("res://Assets/boxes/greenbox.png")

var keyboard_sprites = []
var keyboard_order = "qwertyuiopasdfghjklzxcvbnm"
var alphabet = "abcdefghijklmnopqrstuvwxyz"
var keyboard_green_letters = ""
var keyboard_yellow_letters = ""

var game_over = false

func _ready() -> void:
	set_initial_letters()
	create_valid_word_list()
	set_keyboard_sprites()
	find_child("chooseword").grab_focus()

func set_initial_letters():
	for i in range(0,5):
		sprites.append(get_child(guesses).get_child(i*2))
		labels.append(get_child(guesses).get_child(i*2+1))

func set_letters_and_labels():
	# first 5 children of the root node need to be the word parents
	# proper grabbing here relies on letter then label pairs and nothing else
	print("setting up word ", guesses)
	if guesses >= 6:
		print("out of guesses")
		set_label_end()
		return
	for i in range(0,5):
		sprites[i] = get_child(guesses).get_child(i*2)
		labels[i] = get_child(guesses).get_child(i*2+1)

func create_valid_word_list():
	var file = FileAccess.open("res://Assets/words.txt", FileAccess.READ)
	var content = file.get_as_text()
	valid_words = content.split("\n")

func set_keyboard_sprites():
	# magic method to get all sprites in the keyboard. not alphabetical
	for i in range(0,26):
		keyboard_sprites.append(get_child(6).get_child(i*2))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event):
	if guesses >= 6:
		game_over = true
		lose_animation()
	if game_over:
		return
	if !game_start:
		return
	if event is InputEventKey and event.pressed:
		var keycode = event.keycode
		if len(current_word) < 5:
			# is an alpha character
			if keycode >= 65 and keycode <= 90:
				var new_letter = String.chr(keycode)
				current_word += new_letter
				labels[len(current_word)-1].set_text(new_letter)
		
		if len(current_word) > 0:
			# backspace character
			if keycode == 4194308:
				labels[len(current_word)-1].set_text("")
				current_word = current_word.substr(0,len(current_word)-1)
		
		if len(current_word) == 5:
			if keycode == 4194309:
				if current_word.to_lower() in valid_words:
					print("valid word: ", current_word)
					set_color_feedback() # also progresses word and check if correct
				else:
					print("invalid word: ", current_word)
					tween_word_incorrect_shake()

func set_color_feedback():
	var guessed_word = current_word.to_lower()
	var correct_word = word_to_guess.to_lower()
	var notation = "55555"
	#print("guess: ", guessed_word, ", correct word: ", correct_word)
	
	for i in range(0,5):
		if guessed_word[i] == correct_word[i]:
			sprites[i].texture = greenbox
			correct_word[i] = "!"
			set_keyboard_color(guessed_word[i], 2)
	
	# Fill in all yellows
	for i in range(0,5):
		if correct_word[i] != "!":
			if guessed_word[i] in correct_word and guessed_word[i] != correct_word[i]:
				sprites[i].texture = yellowbox
				correct_word[i] = "-"
				set_keyboard_color(guessed_word[i], 1)
	#print("guess: ", guessed_word, " correct word: ", correct_word)
	
	for i in range(0,5):
		if correct_word[i] != "!" and correct_word[i] != "-":
			set_keyboard_color(guessed_word[i], 0)
	
	print("guess notation: ", correct_word)

	#for i in range(0,5):
		#if 
		
		
	guessed_word = current_word.to_lower()
	correct_word = word_to_guess.to_lower()
	if guessed_word == correct_word:
		print("CORRECT")
		set_label_end()
		game_over = true
		win_animation()
	else:
		guesses += 1
		set_letters_and_labels()
		current_word = ""

func set_label_end():
	for i in range(0,5):
		sprites[i] = null
		labels[i] = null

func set_keyboard_color(letter, color):
	# letter is a one-character string, and color is an int -1 = gray, 0 = darkgray, 1 = yellow, 2 = green
	if len(letter) != 1:
		print("letter given is too many characters")
		return
		
	var index = keyboard_order.find(letter)
	if index == -1:
		print("invalid keyboard character: ", letter)
		return
	
	#print(letter, " letter found at index ", index)
	if color == -1:
		keyboard_sprites[index].texture = graybox
	elif color == 0:
		if letter in keyboard_green_letters or letter in keyboard_yellow_letters:
			return
		keyboard_sprites[index].texture = darkgraybox
		print("set letter ", letter, " to darkgray")
	elif color == 1:
		keyboard_sprites[index].texture = yellowbox
		if letter in keyboard_green_letters:
			return
		keyboard_yellow_letters += letter
	elif color == 2:
		keyboard_sprites[index].texture = greenbox
		keyboard_green_letters += letter
	else:
		print("invalid keyboard color to set")

func tween_word_incorrect_shake():
	var tween = create_tween()
	var child_number = guesses
	var shake_speed = 0.05
	var not_text = find_child("not")
	tween.tween_property(get_child(child_number), "position:x", get_child(child_number).position.x+15, shake_speed)
	tween.chain().tween_property(get_child(child_number), "position:x", get_child(child_number).position.x-15, shake_speed)
	tween.chain().tween_property(get_child(child_number), "position:x", get_child(child_number).position.x+15, shake_speed)
	tween.chain().tween_property(get_child(child_number), "position:x", get_child(child_number).position.x-15, shake_speed)
	tween.chain().tween_property(get_child(child_number), "position:x", get_child(child_number).position.x, shake_speed)
	
	var text_tween = create_tween()
	text_tween.tween_property(not_text, "modulate:a", 1, 0.1)
	text_tween.chain().tween_property(not_text, "modulate:a", 1, 1)
	text_tween.chain().tween_property(not_text, "modulate:a", 0, 0.1)

func win_animation():
	var text_tween = create_tween()
	var win_text = find_child("win")
	text_tween.tween_property(win_text, "modulate:a", 1, 0.1)

func lose_animation():
	var text_tween = create_tween()
	var lose_text = find_child("lose")
	text_tween.tween_property(lose_text, "modulate:a", 1, 0.1)
	
	find_child("revealanswer").get_child(0).text = "word was: " + word_to_guess
	var rev_tween = create_tween()
	var rev_text = find_child("revealanswer")
	rev_tween.tween_property(rev_text, "modulate:a", 1, 0.1)

func _on_chooseword_text_submitted(new_text: String) -> void:
	var textbox = find_child("chooseword")
	if len(new_text) != 5:
		textbox.text = ""
		textbox.placeholder_text = "invalid, choose a 5 letter word"
		return
	
	for i in range(0,5):
		if new_text[i] not in alphabet:
			textbox.text = ""
			textbox.placeholder_text = "invalid, no special characters allowed"
			return
	
	game_start = true
	word_to_guess = new_text
	valid_words.append(new_text)
	textbox.editable = false
	
	var text_tween = create_tween()
	text_tween.tween_property(textbox, "modulate:a", 0, 0.1)
