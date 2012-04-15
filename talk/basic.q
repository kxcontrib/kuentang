 
args:.Q.def[`gamma`num!(-500;10000)].Q.opt .z.x
pi: acos -1;
num:args`num;
steps:`int$252*matur:5.0
show "We will simulate ",string[num]," paths to backtest the pairs trading strategy."
kappa:4.0;theta:1.0;vola:0.15;mu:0.01;eta:0.05;rho:0.79;spot:15.0
L:flip (1f,rho;0f,sqrt[1f-rho*rho])

times:0f,(matur *til[steps-1]+1) % steps-1
show "We generate ",string[tmp:`int$num*steps-1]," normal distributed random variables now."
t:.z.t
`Z`W set'num cut/:L mmu sqrt[-2f*log tmp?1f ]*/:(cos;sin)@\:2*pi*tmp?1f;
show "It took " ,string[.z.t-t]," ."
show "The covariance matrix from Z and W is:"
show {(var[x],cov[x;y];cov[x;y],var[y])}[raze Z; raze W]

show "We simulate the asset A and the spread"
t:.z.t
sdelta:sqrt delta:matur%steps
A:flip { x*exp (delta*mu - 0.5 * vola * vola ) + vola * sdelta * y} scan enlist[spot],Z
skh:sqrt eta * eta % 2f * kappa * 1f - ekh*ekh:exp neg kappa * sdelta
spr:neg A-B:A*exp lspr:flip { (x*ekh) + (theta * 1f-ekh) + y * skh} scan enlist[theta],W  
show "It took " ,string[.z.t-t]," ."

gamma:args`gamma;
show "According to the gamma: ",string[gamma]," we will now calculate the optimal positions."
g1:sqrt 1f- gamma
ee:1f-e;eta2:eta*eta;co:2f*rho*vola*eta;
alpha:{ %[ kappa*1f-g1; 2f*eta*eta]*1+%[2f*g1;(1f-g1)-exp[%[2f*kappa*matur-x;g1]]*1+g1] }
beta:{ e:exp %[2f*kappa* matur-x;g1];:(gamma*(g*ee*ee*eta2+co)- ee*eta2+co+2f*kappa*theta)%(2f*eta2*(1f-g)-e*1f+g)};
h:{[t;sp] ( (count[sp]#enlist beta[t])+(2f*sp*count[sp]#enlist alpha[t])-%[kappa*sp-theta;eta*eta]-%[rho*vola;eta]-0.5) %(1f-gamma)}
pnl:(tpnl:spr *pos)+scfs:flip sums flip cfs:neg spr*dpos:flip deltas flip pos:h[times;lspr]
sh:sqrt[252]*(%) . stats:(avg;dev)@\: flip ret:pnl%flip abs[flip scfs]
mdd:{max neg x-maxs x}
mdds:mdd each pnl

