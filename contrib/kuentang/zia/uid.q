\d .uid

init_ : ([nme:`$()]; num:`long$();dig:`int$() )
init:{ (`$".uid.init_") upsert (x;1j;y); }

/ Number of digits
n: 8

/ Next sequence number
i: 1j

/ Return x sequence numbers
allocate: {
	t: i + til x;
	i +: x;
	{`$ ssr [(neg n) $ string x; " "; "0"]} each t
	}

alc: {
	n:.uid.init_ [x;`num];d:.uid.init_ [x;`dig];
	t: n + til y;
	update num:n+y from `$".uid.init_"; 
	{`$ ssr [neg[x] $ string y; " "; "0"]}[d;] each t
	}

\d .

\

Allocate sequence numbers as n-digit symbols.