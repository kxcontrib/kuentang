\d .seq

init_ : ([] nme:`$(); num:`long$() )
init:{ (`$".seq.init_") insert (x;1j); }

i: 1j / Next sequence number

/ Return x sequence numbers
allocate: {
	t: i + til x;
	i +: x;
	:t
	}

\d .

\

Allocate sequence numbers as n-digit symbols.
