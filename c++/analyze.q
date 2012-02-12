
select count i by 10 xbar r from t:([]r:randn 100)

\t "n=count randn n:1000000"

sthreadIdxx:raze 10#enlist (0 1);
sthreadIdxy:raze (10#0;10#1);
sblockIdxx: raze 2#enlist raze {2#x} each til 5;
sblockIdxy: 20#0;
sblockDimx:20#2;
sblockDimy:20#2;
sgridDimx:20#5;
sgridDimy:20#1;

t:([]sthreadIdxx)
t:update sthreadIdxy from t
t:update sblockIdxx from t
t:update sblockIdxy from t
t:update sblockDimx from t
t:update sblockDimy from t
t:update sgridDimx from t
t:update sgridDimy from t
t:update x:sthreadIdxx + sblockIdxx*sblockDimx from t
t:update y:sthreadIdxy + sblockIdxy*sblockDimy from t
t:update offset:x+y*sblockDimx*sgridDimx from t
t
([] sthreadIdxx;sthreadIdxy;sblockIdxx )
\l ql.q
\l boost.q

result:{ [x;y]
         str: { "\\t ",x} each raze y {x, string y}\:/: x;
         sym: raze y {[x;y]`$x}\:/: x;
         num: raze y {[x;y] y }\:/: x;
         val: { value "\\t ",x} each raze y {x, string y}\:/: x;
        ([]sym;num;str;val)}[100000*1+til 100;(".bst.randn ";".ql.randn ";".cda.randn ")]



select num,val,val1,val2 from 
       (select from result where sym=`$".bst.cudan") 
    lj (`num xkey select num,val1:val from result where sym=`$".bst.randn")
    lj (`num xkey select num,val2:val from result where sym=`$".ql.randn")

select count i by 0.01 xbar rnd from t : ([] rnd: .bst.cudan 20000000)

\l boost.q
\l ql.q

result:([]num:();cda:();q:())
t::();
p::();
{
    t::`real$.bst.randn x;
    p::`real$.cda.randn x;
    cda: value "\\t .cda.vwap[t;p]";
    vwap: value "\\t wavg[t;p]";
    `result insert (x;cda;vwap);
} each 200000*1+til 100

update sf:q % cda from result

n:30000000;t:`real$.bst.randn n;p:`real$.cda.randn n;
(.cda.vwap[p;t];wavg[p;t])
tt wavg tt:`real$til[10000 ]
sum[tt*tt] % sum tt 

.cda.vwap[tt;tt]
\t .cda.vwap[p;t]
\t wavg[p;t]
\l quant.q
n:10000000;
tt: raze exec  s*f,s*g from select s:sqrt -2.0*log u1,f:cos .quant.pi2 * u2,g:sin .quant.pi2 * u2 from t:([]u1:n?1.0;u2:n?1.0)
\t update z1:u*SS, z2:v*SS from update SS:sqrt (-2f* log S) % S from update S:(v*v)+u*u from s:([]v:neg 1f-2f*n?1.0;u:neg 1f-2f*n?1.0)

\t .ql.randn 2*n
select count i by 0.01 xbar tt from ([] tt)
count tt
\t .bst.randn 2*n   
\t .cda.randn 2*n
