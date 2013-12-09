#include
"share/atspre_define.hats"
#include
"share/atspre_staload.hats"

staload "{$CAIRO}/SATS/cairo.sats"
staload "./Checkers.sats"

// --------Actual Code-------- 

implement
draw_board{l}(cr, highlight, cursor) = 
let
  // assuming that user space is scaled by now
  val () = cairo_rectangle(cr, 0.0, 0.0, 1.0, 1.0)
  val () = cairo_set_source_rgb(cr, 0.8, 0.0, 0.0) // red
  fun loop(cr: !cairo_ref1, row: int, col: int): void = 
  let
    val r = 0.8 - (0.8 * ((row - col) mod 2)) // I hate using if statements
    val scale = 0.125 //dividing board into eighths
    val () = cairo_rectangle(cr, row * scale, col * scale, (row + 1.0) * scale, (col + 1.0) * scale)
    val () = cairo_set_source_rgb(cr, r, 0.0, 0.0)
    val () = cairo_fill(cr)
  in
    case+ (row, col) of
    | (7, 7) => () // done
    | (i, 7) => loop(cr, i+1, 0)
    | (i, j) => loop(cr, i, j+1)
  end
in
  loop(cr, 0, 0)
end

// --------Included for testing purposes only--------

implement
mydraw{l}(cr, width, height) = 
let
  val () = cairo_scale(cr, width*1.0, height*1.0)
  val () = draw_board(cr, L(0,0), L(0,0))
in
end