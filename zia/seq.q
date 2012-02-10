\d .seq


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