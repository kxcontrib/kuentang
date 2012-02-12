
\d .bst

dll:`$"../Release/boost"

foo: dll 2: (`$"foo";1)
randn: dll 2: (`$"randn";1)
/cudan: dll 2: (`$"cudan_";1)

\d .

\d .cda

dll: `$"../Release/glib"
foo : dll 2: (`$"foo";1)
randn : dll 2: (`$"randn";1)
ssum : dll 2: (`$"sum";1)
vwap: dll 2: (`$"vwap";2)
\d .