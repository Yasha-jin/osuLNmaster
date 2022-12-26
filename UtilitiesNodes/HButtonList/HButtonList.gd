extends HBoxContainer
class_name HButtonList

export var KeepFocus = false
export var SelectedButtonIndex = 0

signal SelectedButtonChanged

func _ready() -> void:
	var valid_btn = false
	var btn_child = get_child(SelectedButtonIndex)
	if btn_child is Button:
		valid_btn = true
		btn_child.pressed = true
		if KeepFocus:
			btn_child.grab_focus()
	
	for btn in get_children():
		if btn is Button:
			btn.connect("pressed", self, "UpdateSelectedList", [btn])
			btn.toggle_mode = true
			if valid_btn == false:
				btn.pressed = true
				if KeepFocus:
					btn.grab_focus()
				SelectedButtonIndex = btn.get_index()
				valid_btn = true

func UpdateSelectedList(sender_btn):
	SelectedButtonIndex = sender_btn.get_index()
	for btn in get_children():
		if btn is Button:
			btn.pressed = false
	sender_btn.pressed = true
	if !KeepFocus:
		sender_btn.release_focus()
	emit_signal("SelectedButtonChanged", sender_btn.text)
