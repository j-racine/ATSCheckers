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

TRUE = BLACK 
FALSE = RED
*)

#include
"share/atspre_define.hats"
#include
"share/atspre_staload.hats"

staload "{$CAIRO}/SATS/cairo.sats"
staload "libats/ML/SATS/basis.sats"
staload "libats/ML/SATS/list0.sats"
staload _ = "libats/ML/DATS/list0.dats"


// first bool is "ispiecehere" second is "colorofpiece" 
// third is "is piece king", which I think removes need for the piece datatype

datatype
square =  S of (bool,bool,bool)

datatype 
location = L of (int,int)

// x, y, color, king
datatype
piece = P of (location,bool,bool)

typedef
pieceList = list0 (piece)

typedef
board = list0 (list0 (square))

// fun
// board_get_at(B: board,Red: pieceList,Black: pieceList,i:int,j:int) : piece

fun
board_get_at(b: board, i: int, j: int) : square

// fun
// board_set_at(B: board,p:piece,plist: pieceList,i:int,j:int) : void

fun
board_set_at(b: board, s: square, i: int, j: int) : board

fun
draw_loop{l:agz}(cr: !cairo_ref(l), width:int, height: int,B: board, Red: pieceList, Black: pieceList, highlight:location,cursor:location,turn:bool):void

fun 
draw_piece{l:agz}(cr: !cairo_ref(l), p: piece, diameter: double) : void

fun 
draw_square{l:agz}(cr: !cairo_ref(l), loc: !location, r: double, g: double, b: double): void

fun 
draw_board{l:agz}(cr: !cairo_ref(l), hightlight: !location, cursor: !location): void

fun
legal_move(b: board, source: location, dest: location) : bool

//returns integeer representative of key
fun 
poll_keyboard() : int

fun 
get_CPU_move(B:board,Red: pieceList, Black: pieceList) : board

fun{a:t@ype} 
listGet (ls: list0 (a), n: int): a


fun mydraw{l:agz}
(
  !cairo_ref(l), width: int, height: int
) : void = "ext#Checkers_mydraw"