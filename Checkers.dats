#include
"share/atspre_define.hats"
#include
"share/atspre_staload.hats"
#include
"share/atspre_staload_libats_ML.hats"

%{^
#include "Checkers.cats"
%}

extern fun key_get () : int = "mac#"

staload "{$CAIRO}/SATS/cairo.sats"
staload "./Checkers.sats"
staload "libats/ML/SATS/basis.sats"
staload "libats/ML/SATS/list0.sats"
staload _(*anon*) = "libats/ML/DATS/list0.dats"

// --------Actual Code-------- 


implement
draw_square{l}(cr, loc, r, g, b) =
let
  val () = cairo_set_line_width(cr, 0.004)
  val () = cairo_set_source_rgb(cr, r, g, b)
  val scale = 0.125
  val-L(x, y) = loc
  val () = cairo_move_to(cr, x*scale, y*scale)
  val () = cairo_line_to(cr, (x+1)*scale, y*scale)
  val () = cairo_line_to(cr, (x+1)*scale, (y+1)*scale)
  val () = cairo_line_to(cr, x*scale, (y+1)*scale)
  val () = cairo_line_to(cr, x*scale, y* scale)
  val () = cairo_stroke(cr)
in
end

implement
draw_board{l}(cr,b, highlight, cursor) = 
let
  // assuming that user space is scaled by now
  val () = cairo_rectangle(cr, 0.0, 0.0, 1.0, 1.0)
  val () = cairo_set_source_rgb(cr, 0.8, 0.0, 0.0) // red
  fun loop(cr: !cairo_ref1, row: int, col: int): void = 
  let
    val fact = (if (row > col) then (row - col) else (col - row)):int
    val r = 0.8 - (0.8 * ((fact) mod 2)) // I hate using if statements
    val scale = 0.125 //dividing board into eighths
    val () = cairo_rectangle(cr, row * scale, col * scale, (row + 1.0) * scale, (col + 1.0) * scale)
    val () = cairo_set_source_rgb(cr, r, 0.0, 0.0)
    val () = cairo_fill(cr)
    val () = draw_piece(cr, L(row,col),board_get_at(b,row,col))
  in
    case+ (row, col) of
    | (7, 7) => 
    let
      val () = draw_square(cr, highlight, 0.7, 0.7, 0.0)
      val () = draw_square(cr, cursor, 0.1, 0.1, 0.7)
    in
    end
    | (i, 7) => loop(cr, i+1, 0)
    | (i, j) => loop(cr, i, j+1)
  end
in
  loop(cr, 0, 0)
end

implement
draw_piece{l}(cr, loc, sq) =
let
	val-S (e,color,king) = sq
	val-L (x,y) = loc
        var scale = 0.125
	val () = cairo_set_line_width(cr,0.008)
	val () = (if (color = true) then cairo_set_source_rgb(cr,0.0,0.0,0.0) else cairo_set_source_rgb(cr,0.4,0.0,0.0)):void
	val () = cairo_arc(cr, x*scale + scale,y*scale + scale,0.12,0.0,6.288)
	val () = cairo_stroke_preserve(cr)
	val () = (if (color = true) then cairo_set_source_rgb(cr,0.1,0.1,0.1) else cairo_set_source_rgb(cr,0.6,0.0,0.0)):void
	val () = cairo_fill(cr)
	val () = (if (king = true) then draw_crown(cr,loc) else ()) :void
in
end

implement
draw_crown{l}(cr,loc) = 
let
	var scale = 0.125
	val-L (x,y) = loc
	val () = cairo_set_line_width(cr,0.004)
	val () = cairo_set_source_rgb(cr,1.0,0.8,0.2)
	val () = cairo_move_to(cr,x*scale,y*scale+ scale/4*3)
in
end


implement{a:t@ype}
listGet(ls, n) = 
let
  val-list0_cons (x, xs) = ls
in
  case+ n of
  | 0 => x
  | _ => listGet(xs, n -1)
end

implement
board_get_at(b, i, j) =
let
in
  listGet<square>(listGet<list0 (square)>(b, i), j)
end

implement
board_set_at(b, s, i, j) = 
let
  val list = listGet<list0 (square)>(b, i)
  val nlist = list0_insert_at_exn(list, j, s)
in
  list0_insert_at_exn(b, i, nlist)
end

implement
legal_move(b, source, dest) = 
let
  val-L(sx, sy) = source
  val-L(dx, dy) = dest
  val-S(exist,black,king) = board_get_at(b, sx, sy) // listGet<square>(listGet<list0 (square)>(b, sx), sy)
  val valid = exist
  val-S(dex,dr,dk) = board_get_at(b, dx, dy) // listGet<square>(listGet<list0 (square)>(b, dx), dy)
  val valid = valid && ~dex
  val mx = sx - dx
  val my = (sy - dy):int
  val valid = valid && ((king || (mx < 0 && black)) || (mx > 0 && ~black))
  val valid = valid && (((mx/my) = 1) || ((mx/my) = ~1))
  val skip = (mx = 2 || mx = ~2)
  val taking = (if (skip) then (
      let
        val-S(tex,tr,tk) = board_get_at(b, sx + (mx/2), sy + (my/2)) // listGet<square>(listGet<list0 (square)>(b, sx + (mx/2)), sy + (my/2))
	val took = tex && ((tr && ~black) || (~tr && black))
      in
        took
      end
      ) 
    else true):bool
  val valid = valid && taking
in 
  valid
end


implement
initialize_board() = 
let 
    var b = list0<list0(square)>
    fun loop(b: !board, i: int, j: int) :void  = 
    case (i,j) of 
    |(7,7) => board_set_at(b,S(true,true,false),i,j)
    |(7,j) => if((i mod 2) = (j mod 2)) then loop(board_set_at(b,S(true,true,false),i,j),7,j+1) else loop(b,7,j+1)
    |(i,7) => if((i mod 2) = (j mod 2)) then loop(board_set_at(b,S(true,i>3,false),i,j),i+1,0) else loop(b,i+1,0)
    |(i,j) => if((i mod 2) = (j mod 2)) then loop(board_set_at(b,S(true,i>3,false),i,j),i,j+1) else loop(b,i,j+1)
in
end
// --------Included for testing purposes only--------

implement
mydraw{l}(cr,b , width, height) = 
let
  val () = cairo_scale(cr, width*1.0, height*1.0)
  val i = key_get()
  val () = fprintln! (stdout_ref, "key = ", i)
  val () = draw_board(cr,b, L(1,2), L(2,1))
in  
end

