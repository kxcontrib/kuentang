/ R server for Q

\d .r
dll:`$"/r/w32_rserver/w32/rserver"
nsc:"kdb."
i:0; / index to store the anonymous variable
Rclose:.r.dll 2:(`rclose;1)
Ropen:.r.dll  2:(`ropen;1)
Rcmd:.r.dll   2:(`rcmd;1)
Rget:.r.dll   2:(`rget;1)
Rset:.r.dll   2:(`rset;2)

Rset_      : ()!()
Rset_ [1b] : { t:@[value;x;()];if[0<count t; .r.Rset[string x;t] ]; :x} / for symbol
Rset_ [0b] : { .r.Rset[n:.r.nsc,string .r.i;x];.r.i+:1; :`$n } / for non-symbol

rset       : { :{ .r.Rset_[-11h=type x] x}each x }

con:{distinct `$ ssr[;"`";""] each res where {x like "`*"} res:{raze y vs/:x} over enlist[enlist x],"$(,~=<-)"}

e:{  rset t:.r.con x;.r.Rcmd str:ssr[;"`";""] x;str }

frame_:()!()
frame_[1b]:{ syms:`$x . 0 0;:syms x[1]-1 }
frame_[0b]:{ x }

\d .


/turn off the device

Rcmd:.r.Rcmd
Rclose:.r.Rclose
Ropen:.r.Ropen
Rget:{ .r.Rget $[10h=abs type x;x;string x] }
Rset:.r.rset
Roff:{Rcmd "dev.off()"}

/ create table from dataframe
/Rframe:{flip (`data.frame,`$t .(0;0)) !enlist[`$t .(0;4)] ,(t:Rget x) 1}

Rframe:{ t:Rget x; nme:`$t . 0 0;rns:t . 0 2;
		 mat:{ .r.frame_[0=type x]  x } each t[1];
		rns:$[count[rns]=count first mat; @[(`$);rns;rns];til count first mat];
		/(nme;rns;mat)
		flip ((`$"row_names"),nme)!enlist[rns],mat }

Rplot_  : {s:string Rset y; @[Rcmd; str:string[x],"(",(1_raze ",",/:s),")";()];.r.i:0;str } 
Rplot   : Rplot_[`plot]
Rboxplot: Rplot_[`boxplot]
Rhist   : Rplot_[`hist]
Rrug    : Rplot_[`rug]
Rlines  : Rplot_[`lines]
Rtext   : Rplot_[`text]


/

Test function
Rplot (til 10;xexp[;first 1?1.0] til 10 )
