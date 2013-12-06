(*
So, we need three basic things:

AI
Graphics
Input(currently keyboard) + GameLogic

Data Structures:

Board-list of list of boolean tuples
Square: piece color, is piece here  (tuple of booleans)
Piece : color, location, kingstatus

AI always RED
User always BLACK

location = (x,y) both as ints
kingstatus = boolean
color = boolean

Rectangular board. 
Top-left corner is red, alternates from there.

//kings will be drawn in gold.

//legal move note: if x % 2 and y % 2 are equivalent

//board and piecelists should be linear types so that they can get passed around
*)

// first bool is "ispiecehere" second is "colorofpiece" 
datatype
square =  S of (bool,bool)

datatype 
location = L of (int,int)

// x, y, color, king
datatype
piece = P of (location,bool,bool)

datatype 
pieceList = PL of list0<piece>

datatype  
board = B of list0(list0<square>)

fun
board_get_at(B: board,Red: pieceList,Black: pieceList,i:int,j:int) : piece

fun
board_set_at(B: board,p:piece,plist: pieceList,i:int,j:int) : void

fun
draw_loop(cr: !cairo_ref1,width:int, height: int,B: board, Red: pieceList, Black: pieceList, highlight:location,cursor:location,turn:bool):void

fun 
draw_piece(cr: !cairo)ref1, p: piece) : void

//returns integeer representative of key
fun 
poll_keyboard() : int

fun 
get_CPU_move(B:board,Red: pieceList, Black: pieceList) : board