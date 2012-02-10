/This is the file where the idea of a fsm is implemented.

\d .fsm

always_true:{:1b}
always_false:{:0b}


current_state:()
ttable:([]    startstate:`$()
            ; event     :`$()
            ; nextstate :`$()
            ; action    :()
            ; guard     :())
no_transition:()
upd:{[x;y] t:update g:guard @\:y from select from .fsm.ttable where (startstate in .fsm.current_state),event=x;
	 t:select from t where g=1b;
	 if[0=count t;:.fsm.no_transition[.fsm.current_state;x]];
/	 show t;
	 {[x;y]aa::x;bb::y;x[`action;y]}[;y] each t; 
	 .fsm.current_state::distinct t`nextstate;
	 }
def:{
	  .fsm.current_state::x`initial_state; / this is the dynamic state
	  .fsm.ttable::x`ttable;
	  .fsm.no_transition::x`no_transition;
	  x[`on_entry;x];
	  .z.exit::x[`on_exit];
	  }

\d .

upd: {[x; y]if [count y; .fsm.upd [x; y] ];}
