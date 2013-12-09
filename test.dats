// copied from assignment7 test.dats

#include
"share/atspre_define.hats"
#include
"share/atspre_staload.hats"

dynload "./Checkers.dats"

staload "{$CAIRO}/SATS/cairo.sats"

staload
UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

(* ****** ****** *)

extern
fun mydraw 
(
  cr: !cairo_ref1, width: int, height: int
) : void = "ext#Checkers_mydraw" // endfun

(* ****** ****** *)

%{^
typedef char **charptrptr ;
%} ;
abstype charptrptr = $extype"charptrptr"

(* ****** ****** *)

staload "/cs/coursedata/cs520/Fall13/myGTK/SATS/gtkcairoclock.sats"
staload _ = "/cs/coursedata/cs520/Fall13/myGTK/DATS/gtkcairoclock.dats"

(* ****** ****** *)

val the_ntimeout_ref = ref<int> (0)

(* ****** ****** *)

implement
main0 (argc, argv) =
{
//
var argc: int = argc
var argv: charptrptr = $UN.castvwtp1{charptrptr}(argv)
//
val () = $extfcall (void, "gtk_init", addr@(argc), addr@(argv))
//
implement
gtkcairoclock_title<> () = stropt_some"gtkcairoclock"
implement
gtkcairoclock_timeout_update<> () = !the_ntimeout_ref := !the_ntimeout_ref + 1
implement
gtkcairoclock_timeout_interval<> () = 500U (* millisecs *)
implement
gtkcairoclock_mydraw<> (cr, W, H) = mydraw (cr, W, H)
//
val ((*void*)) = gtkcairoclock_main ((*void*))
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [test.dats] *)
