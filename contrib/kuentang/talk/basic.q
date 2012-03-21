
pi: acos -1;
matur:5.0; / 5 years
num:10000;steps:`int$matur*252;

show "We will simulate ",string[num]," paths to backtest the pairs trading strategy based on optimal control approach."

kappa:4.0;theta:1.0;vola:0.15;
mu:0.01;eta:0.005;rho: 0.19;
W:(1f,rho;0f,sqrt[1f-rho*rho])

spot:15.0
times:0f,(matur *til[steps-1]+1) % (steps-1)
/ Generate the normal distributed random variables

delta:sqrt h:matur%steps
show "We generate ",string[tmp:`int$num*steps-1]," normal distributed random variables now."
t:.z.t
`Z`W set'num cut/: W mmu sqrt[-2f * log tmp?1f ] */: (cos;sin) @\: 2*pi*tmp?1f;
show "It took " ,string[.z.t-t]," ."

show "We simulate the asset A and the spread"
t:.z.t

A:flip { x*exp (h*mu - 0.5 * vola * vola ) + vola * delta * y} scan enlist[spot],Z
skh:sqrt eta * eta % 2f * kappa * 1f - ekh*ekh:exp neg kappa * h
spr:neg A-B:A*exp lspr:flip { (x*ekh) + (theta * 1f-ekh) + y * skh} scan enlist[theta],W  
show "It took " ,string[.z.t-t]," ."

gamma:-100;
show "According to the gamma: ",string[gamma],". We will now calculate the optimal positions."

alpha:{[x] g:sqrt 1f- gamma;  %[ kappa * 1f - g;  2f * eta *eta] *1+%[2f*g ; (1f-g)-exp[%[2f*kappa*matur-x;g] ]* 1+g] };
beta:{[x]  g:sqrt 1f- gamma;e:exp[%[2f*kappa* matur-x ;g ]];
    ee:1f-e;eta2:eta*eta; co:2f*rho*vola*eta;
    :(gamma*(g*ee*ee*eta2+co)- ee*eta2+co+2f*kappa*theta ) % (2f*eta2 * (1f-g)-e*1f+g)  };

hi:{[t;sp] ( (count[sp]#enlist beta[t])+(2f*sp*count[sp]#enlist alpha[t])
    -%[kappa*sp-theta;eta*eta]-%[rho*vola;eta]-0.5) %(1f-gamma)};
pnl:(tpnl:spr *pos)+scfs:flip sums flip cfs:neg spr*dpos:flip deltas flip pos:hi[times;lspr];;
sh:sqrt[252]*%[;] . stats:(avg;dev)@\: flip ret:pnl%flip abs[flip scfs]

/ helper plot function
mdd:{ max(1+til count x){max neg (y x-1) - x#y }\:x}
plot:{![;();1b;(tmp,`ret)!((tmp:`pos`dpos`cfs`spr`scfs`tpnl`pnl`A`B`lspr) @\:x),enlist pnl[x] % scfs[x]] ([]times:times)}
stats:{ stat:(sqrt[252]*%[;] . stat 0 1 ),stat:(avg;dev;max;min) @\: ret:plot[x]`ret;`sharpe`avg`dev`max`min`mdd!stat,enlist[mdd `pnl x]}
