
\l util.q

cmd: .util.cmd .z.x

gamma:parse cmd`gamma
h:hopen parse cmd`report

neg[h] ({[x;y] reports[x]:y;};`$cmd`gamma;gamma)