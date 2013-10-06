
/

06.10.2013 17:55:08

Simple functions to plot time series

plot1 til 100;
plotxy [til 100]til 100;

Other plots like barchart or boxplot should come in short

\

plot1:{
 w:value "\\c";
 l:first[w]-10;
 w:last[w]-10;
 -1 "   ",(w+3)#"-";
 t:t!w xrank t:til count x;
 m:{c:count each group x;n:y#0; n[key c]: value c;n}[;w] each t k!g k:desc key g:group l xrank x;
 show {((til 11)!(" ",raze string[1+til 9],"*"))x} each floor 10*m % max raze m;
 -1 "   ",(w+3)#"-";
 {-1"     ",x;} each flip ("0",/:string til 10),string 10_til w;
 }

plotxy:{
 w:value "\\c";
 l:first[w]-10;
 w:last[w]-10;
 -1 "   ",(w+3)#"-";
 t:til[count x]!w xrank x;
 m:{c:count each group x;n:y#0; n[key c]: value c;n}[;w] each t k!g k:desc key g:group l xrank y;
 show {((til 11)!(" ",raze string[1+til 9],"*"))x} each floor 10*m % max raze m;
 -1 "   ",(w+3)#"-";
 {-1"     ",x;} each flip ("0",/:string til 10),string 10_til w;
 }