
\d .rnd

pi2:            2*acos -1

urn:{ r:z?raze x[y] #' y;$[1=z;first r;r]}
expr:{r:neg x* log y?1.0;$[1=y;first r;r]}
par:{[a;l;h;n] h:xexp[;a] h; l:xexp[;a] l; u:n?1.0;
	 r:xexp[; neg 1% a] (h-u*h-l) % h*l;$[1=n;first r;r]}
norm:{[x;y;z] r:x+y*z#raze sqrt[-2.0*log hn?1.0]*/:(cos;sin) @\: pi2 * (hn: 1 |`int$ z % 2)?1.0;
	          $[1=z;first r;r]
	  }
\d .

/ several functions to simulate normal, exponential and power law distribution