
\l util.q
\l quant.q
\l ql.q

cmd:.util.cmd .z.x;

num:60000;steps:256;
kappa:8.0;theta:0.75;vola:0.25;
mu:0.01;eta:0.25;rho:neg 0.75;
L:(vola, vola*rho*eta; (vola*rho*eta),eta );
W:.ql.cholcov L;
matur:1.0;spot:15.0;
/ arg:`type_`spot`drift`diffu`matur`steps`repl`output!(`euler;(spot;theta);{[t;s] ((mu*s[0]),kappa* theta - s[1]) };{[t;s] (s[0],1.0)*W};matur;steps;num;`wtime);
arg:`type_`spot`matur`steps`repl`output!(`neuler;(spot;theta);matur;steps;num;`wtime);
arg,:enlist [`drift]!enlist {[t;s] flip ((mu*flip[s] 0);kappa* theta - flip[s] 1) }
arg,:enlist [`diffu]!enlist {[t;s;w] flip (flip[s] 0;1.0)*flip w mmu W}
path:.ql.paths arg;

time:path 0;path:path 1;
gamma:parse cmd`gamma;
alpha:{[x] g:sqrt 1f- gamma;  %[ kappa * 1f - g;  2f * eta *eta] *1+%[2f*g ; (1f-g)-exp[%[2f*kappa*matur-x;g] ]* 1+g] };
beta:{[x]  g:sqrt 1f- gamma;e:exp[%[2f*kappa* matur-x ;g ]];ee:1f-e;eta2:eta*eta; co:2f*rho*vola*eta;
           :(gamma*(g*ee*ee*eta2+co)- ee*eta2+co+2f*kappa*theta ) % (2f*eta2 * (1f-g)-e*1f+g)  };
u:{[x]  b:beta x;a:alpha x;hlf:0.5;
        cps:: (`n`h`g`e`b`r`v`G`a`m`k`t)!(-1f;0.5;gamma;eta;b;rho;vola;gamma-1f;a;mu;kappa;theta);
        :sum {[x] prd cps{`$ x} each x} each ("nhgeeeeb";"ngrveeeb";"nheeeebb";"Geeeea";"gGmee";"nkteeb";"nhgkktt";"nhgtee";"ngtrve";"nhhhgeeee";"nhgrveee";"nhgrrvvee")};

g:{[x] $[1=count x; 
    exp %[neg .ql.integrate `f`a`b`tol!(u;x;matur;1e-4);eta*eta*1-gamma]
    ;{[x] exp %[neg .ql.integrate `f`a`b`tol!(u;x;matur;1e-4);eta*eta*1-gamma]} each x]};

f:{[x;y] a:alpha x ; b:beta x; :g[x] * exp (y*b)+y*y*a};
G:{[t;v;x] f[t;x]*xexp[v;gamma]};
h:{[t;sp] %[ (count[sp]#enlist beta[t])+(2f*sp*count[sp]#enlist alpha[t])-%[kappa*sp-theta;eta*eta]-%[rho*vola;eta]-0.5;1f-gamma]};

A:flip[path] 0;lspr:flip[path] 1;B:A*exp lspr;spr:B-A;
pos:h[time;lspr];
del:flip deltas flip pos;
cfs:neg del*spr;scfs:flip sums flip cfs;
tpnl:spr *pos;pnl:scfs+tpnl;
plot:{ ([] time;pos:pos x;cfs:cfs x;spr:spr x;del:del x;scfs:scfs x;tpnl:tpnl x; pnl:pnl x;A:A x; B: B x; lspr:lspr x  ) }

reports:select maxx:max each pnl, minn:min each pnl,pnl:last each pnl from  ([] pnl);

/h: hopen parse cmd`report;

/neg[h] ({[x;y] reports[x]:y;};gamma;reports);


/select from reports where pnl < -100

/select c:count i by 1 xbar pnl from reports
/select pnl, sums c from  select c:count[i] by 1 xbar pnl from reports
/select minn, sums c from  select c:count[i] % num by 1 xbar minn from reports
/select maxx, sums c from  select c:count[i] % num by 1 xbar maxx from reports