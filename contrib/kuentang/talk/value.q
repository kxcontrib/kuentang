
\l quant.q
\l ql.q
num:1000;steps:256;
kappa:8.0;theta:1.5;vola:0.25;
mu:0.01;eta:0.25;rho:neg 0.75;
L:(vola, vola*rho*eta; (vola*rho*eta),eta );
W:.ql.cholcov L;
matur:1.0;spot:15.0;
/ arg:`type_`spot`drift`diffu`matur`steps`repl`output!(`euler;(spot;theta);{[t;s] ((mu*s[0]),kappa* theta - s[1]) };{[t;s] (s[0],1.0)*W};matur;steps;num;`wtime);
arg:`type_`spot`matur`steps`repl`output!(`neuler;(spot;theta);matur;steps;num;`wtime);
arg,:enlist [`drift]!enlist {[t;s] flip ((mu*flip[s] 0);kappa* theta - flip[s] 1) }
arg,:enlist [`diffu]!enlist {[t;s;w] flip (flip[s] 0;1.0)*flip w mmu W}
path:.ql.paths arg;time:path 0;path:path 1;
gamma:-10f;
alpha:{[x] g:sqrt 1f- gamma;  %[ kappa * 1f - g;  2f * eta *eta] *1+%[2f*g ; (1f-g)-exp[%[2f*kappa*matur-x;g] ]* 1+g] };
beta:{[x]  g:sqrt 1f- gamma;e:exp[%[2f*kappa* matur-x ;g ]];ee:1f-e;eta2:eta*eta; co:2f*rho*vola*eta;
           :(gamma*(g*ee*ee*eta2+co)- ee*eta2+co+2f*kappa*theta ) % (2f*eta2 * (1f-g)-e*1f+g)  };
u:{[x]  b:beta x;a:alpha x;hlf:0.5;
        cps:: (`n`h`g`e`b`r`v`G`a`m`k`t`i)!(-1f;0.5;gamma;eta;b;rho;vola;gamma-1f;a;mu;kappa;theta;0.0);
        :sum {[x] prd cps{`$ x} each x} each ("nhgeeeeb";"ngrveeeb";"nheeeebb";"Geeeea";"gGiee";"nkteeb";"nhgkktt";"nhgtee";"ngtrve";"nhhhgeeee";"nhgrveee";"nhgrrvvee")};

g:{[x] $[1=count x; 
    exp %[neg .ql.integrate `f`a`b`tol!(u;x;matur;1e-4);eta*eta*1-gamma]
    ;{[x] exp %[neg .ql.integrate `f`a`b`tol!(u;x;matur;1e-4);eta*eta*1-gamma]} each x]};

f:{[x;y] a:alpha x ; b:beta x; :exp %[neg .ql.integrate `f`a`b`tol!(u;x;matur;1e-4);eta*eta*1-gamma]+(y*b)+y*y*a};
G:{[t;v;x] f[t;x]*xexp[v;gamma]};
h:{[t;sp] %[ (count[sp]#enlist beta[t])+(2f*sp*count[sp]#enlist alpha[t])-%[kappa*sp-theta;eta*eta]-%[rho*vola;eta]-0.5;1f-gamma]};

G[0.6;0.2;1.5]
f[0.8;1.5]


