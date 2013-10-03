
/ ql:localhost:8888::

\p 8888

\l quant.q
\l ql.q
/ testing black scholes formula
tab:flip `type_`direct`spot`strike`rate`vola`matur!(`bls`vega`delta`theta`vega`rho;`call;100;100;0.01;0.25;1.0);
update price:.ql.bls tab from tab
num:100000;
tab1:([] type_:num?`bls`vega`delta`theta`vega`rho;direct:num?`call`put;spot:num?100.0;strike:num?100.0;rate:num?0.10;vola:num?0.50;matur:num?10.0 );tab1
update price:.ql.bls tab1 from tab1
ftab:{[x]([] type_:x?`bls`vega`delta`theta`vega`rho;direct:x?`call`put;spot:x?100.0;strike:x?100.0;rate:x?0.10;vola:x?0.50;matur:x?10.0 )};
/ measure time
num:2;
scal:1000000;
perf:flip `num`time!(scal*1+til num;value each "\\t .ql.bls ftab ",/: string scal*1+til num);perf


/ testing implied vola
\l ql.q
num:1000;
tab2:flip `type_`direct`spot`strike`rate`price`matur!(`impl;num?`call`put;100;100;0.01;(03.00 + 0.005*til num);1.0)
t:{[x]flip `type_`direct`spot`strike`rate`price`matur!(`impl;`call;100;100;0.01;(03.00 + 0.005*til x);1.0)}
num:300;
flip `line`time!(1+til num; value each "\\t .ql.bls t ",/: string 1+til num)
update blsprice: .ql.bls res2 from res2:update type_:`bls, vola: .ql.bls tab2 from tab2

/ testing binomial tree
\l ql.q
t:([] spot:100;rate:0.01;vola:0.25;matur:1.0;num:2500;payoff:({x};{max 0,x-100};{max 0,100-x};{abs 100-x}));t
/ update price: .ql.binbaum t from t
update price: .ql.binbaum each t from t


/ testing gaussian random number generator
\l ql.q
num:`int$1e6;
select count i by 0.01 xbar r  from ([] n:til num ;r:.ql.randn num)
\t value ".ql.randn num"
select n, sums r from ([] n:til 1+num ;r:0,.ql.randn num)

/ testing geometric brownian motion
\l ql.q
num:1000000;steps:4;
paths:.ql.paths `type_`spot`drift`diffu`matur`steps`repl!
    (`euler;100f;{[t;s] 0.01 *s };{[t;s] 0.25 * s};1.0;steps;num)
select count i by 1 xbar paths from t:([] paths:last each paths )
exp[-0.01] * avg {max 0,last[x]-100} each paths
exp[-0.01] * avg {max 0,neg last[x]-100} each paths
exp[-0.01] * avg {last[x]} each paths

/ testing simulate multidimensional sde
\l ql.q
num:1000000
L::(0.25 0f; 0 0.25)
steps:5;
arg:`type_`spot`drift`diffu`matur`steps`repl!(`euler;(100 100f);{[t;s] 0.01 *s };{[t;s] s*L};1.0;steps;num)
p:.ql.paths arg
select count i by 0.5 xbar p from ([] p:last each raze p) 
select count i by 0.5 xbar p from ([] p:last flip raze p) / this version is slightly faster
1_select count i by 1 xbar p from ([]p:raze {[x] {[x]max 0,x-100}each last x} each raze p)
1_select count i by 1 xbar p from ([]p:raze {[x] {[x]max 0,100-x}each last x} each raze p)


/ testing monte carlo
/ \l ql.q
/ num:10000;
/ t:([] fs:.ql.mc `type_`spot`drift`diffu`matur`steps`repl`payoffs!(`euler;100f;{[t;s] 0.01 *s };{[t;s] 0.25 * s};1.0;4;num;(last;{max 0,last[x]-100};{max 0,100-last[x]})) )
/ ([] t[`fs])


/ select count[i] % num by 1 xbar x from ([] {x 0} each t`fs)
/ 1_select count[i] % num by 1 xbar x from ([] t[1;`fs])
/ 1_select count[i] % num by 1 xbar x from ([] t[2;`fs])

/ testing donothing strategy
\l ql.q
num:100000;
steps:256;
arg:`type_`spot`drift`diffu`matur`steps`repl`output!
    (`euler;100f;{[t;s] 0.01 *s };{[t;s] 0.25 * s};1.0;steps;num;`wtime);
path:.ql.paths arg;
time:path 0;
path:path 1;
dt:arg[`matur] % arg[`steps]-1;
dfactors:exp neg arg[`drift;1f;1f]*time;
cashflows:{ [x] :(1_count[x]#0f),$[last[x] >=100f;100f+neg last[x];0f]} each path;
freq:reverse select counts:count i  by 0.1 xbar cost from 
    ([]cost:cashflows{[x;y] sum x*y}\:dfactors)
cumu:select cost,c:sums[counts] % num from freq
{ [x] ([] time;s:path[x]; dcfs:sums cashflows[x]*dfactors;pos:signum[cashflows x];dfactors;cfs:cashflows x)} 10
avg cashflows{[x;y] sum x*y}\:dfactors

/ testing do sell/buy at the beginning strategy
\l ql.q
num:100000;
steps:256;
arg:`type_`spot`drift`diffu`matur`steps`repl`output!(`euler;100f;{[t;s] 0.01 *s };{[t;s] 0.25 * s};1.0;steps;num;`wtime);
path:.ql.paths arg;
time:path 0;
path:path 1;
dt:arg[`matur] % arg[`steps]-1;
dfactors:exp neg arg[`drift;1f;1f]*time;
cashflows:{ [x] : (-100f,2_count[x]#0f),$[last[x] >=100f;100f;last[x]]} each path;
freq: select counts:count i  by 0.1 xbar cost from 
    ([]cost:cashflows{[x;y] sum x*y}\:dfactors)
cumu:select cost,c:sums[counts] % num from freq
{ [x] ([] time;s:path[x]; dcfs:sums cashflows[x]*dfactors;pos:signum[cashflows x];dfactors)} 0
([]til num;cost:cashflows{[x;y] sum x*y}\:dfactors)
avg cashflows{[x;y] sum x*y}\:dfactors

/ testing stoploss strategy
\l ql.q
num:1000;
steps:256;
arg:`type_`spot`drift`diffu`matur`steps`repl`output!(`euler;100f;{[t;s] 0.01 *s };{[t;s] 0.25 * s};1.0;steps;num;`wtime);
path:.ql.paths arg;
path:path 1;time:path 0;
dt:arg[`matur] % arg[`steps]-1;
dfactors:exp neg arg[`drift;1f;1f]*time;
cashflows:{ 
    [x] p::x; c:0f{[x;y] $[ &[y<100f;x>=100f];neg x; $[ &[y>=100f;x<100f] ; x; 0f ] ]}': x;
        :$[last[p] >=100f;(-1_c),last[c]+100f; c]} each path;
{ [x] ([] time;s:path[x]; dcfs:sums cashflows[x]*dfactors;pos:neg signum[cashflows x];dfactors)} 0
freq:select counts:count i  by 0.1 xbar cost from ([]cost:cashflows{[x;y] sum x*y}\:dfactors)
cumu:select cost,c:sums[counts] % num from freq
([]til num;cost:cashflows{[x;y] sum x*y}\:dfactors)
avg cashflows{[x;y] sum x*y}\:dfactors

/ testing delta hedge strategy
\l ql.q
num:50000;
steps:256;
arg:`type_`spot`drift`diffu`matur`steps`repl`output!(`euler;100f;{[t;s] 0.01 *s };{[t;s] 0.25 * s};1.0;steps;num;`wtime);
path:.ql.paths arg;
time:path 0;
path:path 1;
dt:arg[`matur] % arg[`steps]-1;
dfactors:exp neg arg[`drift;1f;1f]*time;
/ now we need to calculate the deltas of each path.
/ this way it is more faster
dls:(num,steps) # .ql.bls `type_`direct`spot`strike`rate`vola`matur!(`delta;`call;raze[path];100;0.01;0.25;raze num#enlist 1f-time)
positions: dls{[x;y] p:-1_x;l:last y; l:$[l > 100f; 1-last[p]; last p ]; :(p,l)}'path;
/ If you got a wsfull error, you should use this solution to calculate the position.
positions:{[x]  p::.ql.bls t:-1_([] type_:`delta;direct:`call;spot:x;strike:100;
                   rate:arg[`drift;1f;1f];vola:arg[`diffu;1f;1f];matur:1-time) ;
                l:$[last[x] > 100f; 1-last[p]; last p ];:(p,l)
    } each path;

\t value "positions each path"
cashflows:positions{[x;y] c:-1_y* neg deltas x;l:last[y]*last[x]; : c,$[100f<last y;100f-l ;l ]}'path;
freq:select counts:count i  by 0.05 xbar cost from ([]cost:cashflows{[x;y] sum x*y}\:dfactors);
cumu:select cost,c:sums[counts] % num from freq;
`cost xasc ([]til num;cost:cashflows{[x;y] sum x*y}\:dfactors);
avg cashflows{[x;y] sum x*y}\:dfactors;
{([] time;path:path[x];pos:positions[x];d:deltas positions[x];
    cashflows:cashflows[x])} 0

/ testing cholesky decomposition
\l ql.q
B:(1 2 3f; 0 4 3f; 0 0 3f);
v:flip[B] mmu B;
v~{ flip[x]$x }.ql.cholcov v

/ testing ou process
\l ql.q
num:100000;steps:256;
kappa:4.0;theta:1.5;vola:0.25;
arg:`type_`spot`drift`diffu`matur`steps`repl`output!(`euler;theta;{[t;s] kappa* theta - s };{[t;s] vola };1.0;steps;num;`wtime);
path:.ql.paths arg;time:path 0;path:path 1;

select count i by 0.01 xbar l from ([]n:til num ;l:{max x} each path )
select count i by 0.01 xbar l from ([]n:til num ;l:{min x} each path )
select count i by 0.01 xbar l from ([]n:til num ;l:{avg x} each path )
select l,sums c from select c:count i by 0.01 xbar l from ([]n:til num ;l:{last x} each path )
([] time:time; path:path[0])

/ test the static pairs trading
\l ql.q
num:100000;steps:256;
kappa:8.0;theta:1.5;vola:0.25;
mu:0.01;eta:0.1;rho:neg 0.75;
L:(vola, vola*rho*eta; (vola*rho*eta),eta );
W:.ql.cholcov L;
matur:1.0;spot:15.0;
arg:`type_`spot`drift`diffu`matur`steps`repl`output!(`euler;(spot;theta);{[t;s] ((mu*s[0]),kappa* theta - s[1]) };{[t;s] (s[0],1.0)*W};matur;steps;num;`wtime);
path:.ql.paths arg;time:path 0;path:path 1;
sellpoint:theta+0.5*eta;buypoint:theta-0.5*eta;

/ pos; spread>sellpoint; spread<buypoint; spread<theta; spread>theta
decise:()!();
decise[0f]:{[spread] :$[spread>sellpoint;-1f; $[spread<buypoint;1f;0f] ] };
decise[1f]:{[spread] :$[spread>theta;0f; 1f] };
decise[-1f]:{[spread] :$[spread<theta;0f;-1f] };

sh:{ [p] a:p 0;logspread:p 1;b:a*exp logspread;spread:a-b;
        pos:{[x;y] :decise[x;y]}\[0f;logspread];d:deltas pos;
        cfs:d * spread;
        cfs:cfs where not cfs = 0f;
        nts:2*floor[count[cfs] % 2];
        pnl:sum nts#cfs;
        :`pnl`nts!(pnl;nts% 2)
        };

reports:res each path;
select c:count i by 1 xbar pnl from reports
select count i by 1 xbar nts from reports

/ test the integrate function
\l ql.q
args:`f`a`b`tol!({[x] 1f+x*x};-2f;1f;1e-5)
(.ql.integrate[args]- {[x] x[0]-x[1]} {[x] x+xexp [x ;3] % 3} (1f;-2f))

/ test the pairs trading using stochastic control approach

\l ql.q
num:100000;steps:256;
kappa:8.0;theta:1f;vola:0.25;
mu:0.01;eta:0.25;rho:neg 0.75;
L:(vola, vola*rho*eta; (vola*rho*eta),eta );
W:.ql.cholcov L;
matur:1.0;spot:15.0;
arg:`type_`spot`drift`diffu`matur`steps`repl`output!(`euler;(spot;theta);{[t;s] ((mu*s[0]),kappa* theta - s[1]) };{[t;s] (s[0],1.0)*W};matur;steps;num;`wtime);
path:.ql.paths arg;time:path 0;path:path 1;
gamma:-100f;
alpha:{[x] g:sqrt 1f- gamma;  %[ kappa * 1f - g;  2f * eta *eta] *1+%[2f*g ; (1f-g)-exp[%[2f*kappa*matur-x;g] ]* 1+g] };
beta:{[x]  g:sqrt 1f- gamma;e:exp[%[2f*kappa* matur-x ;g ]];ee:1f-e;eta2:eta*eta; co:2f*rho*vola*eta;
           :(gamma*(g*ee*ee*eta2+co)- ee*eta2+co+2f*kappa*theta ) % (2f*eta2 * (1f-g)-e*1f+g)  };
u:{[x]  b:beta x;a:alpha x;hlf:0.5;
        cps:: (`n`h`g`e`b`r`v`G`a`m`k`t)!(-1f;0.5;gamma;eta;b;rho;vola;gamma-1f;a;mu;kappa;theta);
        :sum {[x] prd cps{`$ x} each x} each ("nhgeeeeb";"ngrveeeb";"nheeeebb";"Geeeea";"gGmee";"nkteeb";"nhgkktt";"nhgtee";"ngtrve";"nhhhgeeee";"nhgrveee";"nhgrrvvee")
  };

g:{[x] $[1=count x; 
    exp %[neg .ql.integrate `f`a`b`tol!(u;x;matur;1e-4);eta*eta*1-gamma]
    ;{[x] exp %[neg .ql.integrate `f`a`b`tol!(u;x;matur;1e-4);eta*eta*1-gamma]} each x]
    };
f:{[x;y] a:alpha x ; b:beta x; :g[x] * exp (y*b)+y*y*a};
G:{[t;v;x] f[t;x]*xexp[v;gamma]};
h:{[t;sp] %[ beta[t]+(2f*sp*alpha[t])-%[kappa*sp-theta;eta*eta]-%[rho*vola;eta]-0.5;1f-gamma]};
positions:h[time];

sca:{ [p] a:p 0;logspread:p 1;b:a*exp logspread;spread:a-b;
        pos:positions logspread; d:deltas pos;
        cfs:d * spread;
        pnl:sums cfs;
        pnl: (-1_pnl),last[pnl] -last[pos]*last[spread];
/        pnl:sum[cfs]-last[pos]*last[spread];
        :pnl
        };

cfs:{ [p] a:p 0;logspread:p 1;b:a*exp logspread;spread:b-a;
        pos:positions logspread; d:deltas pos;
        cfs:neg d * spread;
        pspread :pos*spread;
        cfss:sums[cfs];
        pnl:cfss + pspread;
        ([] time;a;b;logspread;spread;cfs;pos;d;pnl;cfss;pspread;maxpnl:max pnl;minpnl : min pnl;G:G[time;pnl;logspread])
    };

reports:select maxx:max each pnl, minn:min each pnl, l:last each pnl from pnl:([] pnl:sca each path )
select l, sums c from  select c:count[i] by 1 xbar l from reports
select minn, sums c from  select c:count[i] % num by 1 xbar minn from reports
select maxx, sums c from  select c:count[i] % num by 1 xbar maxx from reports

