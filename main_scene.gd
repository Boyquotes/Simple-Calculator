extends VBoxContainer

#references to some nodes
onready var input_1 = get_node("input/input_1")
onready var output_label = get_node("output/Label")

#the string that is used for calculation, not shown to user
var Calculation_String = ""

#counts how many left bracket used back to back
var LeftBracketCounter = 0

#true if equal pressed and result is shown
var equal_pressed_before = false

#Max input length
const MAX_INPUT_LENGTH = 125

func _ready():
	#connecting buttons to "pressed" signal
	for input_button in input_1.get_children():
		input_button .connect("pressed", self, "_on_button_pressed", [input_button .name])

#function used for buttons
func _on_button_pressed(button_name):
	match button_name:
		"AC":
			AC()
		"BackSpace":
			BackSpace()
		"Remainder":
			Sign_Pressed(button_name)
		"Division":
			Sign_Pressed(button_name)
		"Multiply":
			Sign_Pressed(button_name)
		"Minus":
			Sign_Pressed(button_name)
		"Plus":
			Sign_Pressed(button_name)
		"Comma":
			Sign_Pressed(button_name)
		"9":
			Number_Pressed(button_name)
		"8":
			Number_Pressed(button_name)
		"7":
			Number_Pressed(button_name)
		"6":
			Number_Pressed(button_name)
		"5":
			Number_Pressed(button_name)
		"4":
			Number_Pressed(button_name)
		"3":
			Number_Pressed(button_name)
		"2":
			Number_Pressed(button_name)
		"1":
			Number_Pressed(button_name)
		"0":
			Number_Pressed(button_name)
		"LeftBracket":
			LeftBracket()
		"RightBracket":
			RightBracket()
		"Equal":
			Equal()

#function for AC
func AC():
	#Resetting all the variables
	output_label.set_text("")
	Calculation_String = ""
	LeftBracketCounter = 0
	equal_pressed_before = false

#function for BackSpace
func BackSpace():
	#user may press Backspace right after pressing Equal, below lines show only result in this situation
	if equal_pressed_before:
		output_label.set_text(Calculation_String)
		equal_pressed_before = false
		return
	#being sure there is any character to delete
	if output_label.get_text().length() == 0:
		return
	#deleting last char of the 'output_label.text' and 'Calculation_String'
	output_label.set_text(output_label.get_text().left(output_label.get_text().length() - 1))
	Calculation_String = Calculation_String.left(Calculation_String.length() - 1)
	#if there is nothing left after backspace, resetting 'LeftBracketCounter'
	if output_label.get_text().length() == 0:
		LeftBracketCounter = 0

#function for mathmatical operators and comma
# % / x - +
func Sign_Pressed(Operator):
	var temp = output_label.get_text()
	#avoiding mathmatical sign when there is nothing on the screen, exmp: "/8+2-(7*2)"
	if temp.length() > 0:
		if temp[temp.length() - 1] in "%/x-+(":
			return
		#avoiding excess input
		if temp.length() == MAX_INPUT_LENGTH:
			return
		#putting mathmatical signs to end of the 'output_label.text' and Calculation_String
		match Operator:
			"Remainder":
				output_label.set_text(output_label.get_text() + "%")
				Calculation_String = Calculation_String + "%"
			"Division":
				output_label.set_text(output_label.get_text() + "/")
				Calculation_String = Calculation_String + "/"
			"Multiply":
				#user sees 'X' but there should be '*' in the 'Calculation_String'
				output_label.set_text(output_label.get_text() + "x")
				Calculation_String = Calculation_String + "*"
			"Minus":
				output_label.set_text(output_label.get_text() + "-")
				Calculation_String = Calculation_String + "-"
			"Plus":
				output_label.set_text(output_label.get_text() + "+")
				Calculation_String = Calculation_String + "+"
			_:
				pass

#function for number buttons '1,2,3,4,5,6,7,8,9,0'
func Number_Pressed(Number):
	var temp = output_label.get_text()
	#if there is no character on screen we can't get the index -1
	if temp.length() > 0:
		#avoiding number input right after ')'
		if temp[temp.length() - 1] == ")":
			return
		#avoiding excess input
		if temp.length() == MAX_INPUT_LENGTH:
			return
	output_label.set_text(output_label.get_text() + Number)
	Calculation_String = Calculation_String + Number

#function for left bracket
func LeftBracket():
	var temp = output_label.get_text()
	if temp.length() > 0:
		#avoiding left bracket right after a number
		if temp[temp.length() - 1] in "1234567890":
			return
	#avoiding excess input
	if temp.length() == MAX_INPUT_LENGTH:
		return
	output_label.set_text(output_label.get_text() + "(")
	Calculation_String = Calculation_String + "("
	LeftBracketCounter += 1

#function for right bracket
func RightBracket():
	var temp = output_label.get_text()
	#avoiding bracket pairs with no expression
	if temp.length() > 0:
		if temp[temp.length() - 1] == "(":
			return
	#no left bracket, no right bracket
	if LeftBracketCounter == 0:
		return
	else:
		output_label.set_text(output_label.get_text() + ")")
		Calculation_String = Calculation_String + ")"
		LeftBracketCounter -= 1


#function for equality and showing the result
func Equal():
	if not equal_pressed_before:
		#passing if there is no input
		if Calculation_String.length() == 0:
			return
		#user may ignore closing the bracket before calculation, we should handle this
		for i in LeftBracketCounter:
			RightBracket()
		
		#calculating the result and writing it into 'output_label.text' and 'Calculation_String'
		var expression = Expression.new()
		var error = expression.parse(Calculation_String, [])
		if error != OK:
			#print(expression.get_error_text())
			Calculation_String = "0"
			output_label.set_text("0")
			return
		var result = expression.execute([], null, true)
		if not expression.has_execute_failed():
			output_label.set_text(output_label.get_text() + "\n=" + str(result))
			Calculation_String = str(result)
			equal_pressed_before = true
	#user may press Equal right after finishing calculation
	#there lines shows only result in this situation
	else:
		output_label.set_text(Calculation_String)
		equal_pressed_before = false
		return
