
args:.Q.def[`results`mx`gamma`num!(`:localhost:1111;`:localhost:2222;-500;1000)].Q.opt .z.x

pi: acos -1;
matur:5.0; / 5 years
num:args`num;steps:`int$matur*256;

show "We will simulate ",string[num]," paths to backtest the pairs trading strategy."

kappa:4.0;theta:1.0;vola:0.15;
mu:0.01;eta:0.005;rho: 0.19;
W:(1f,rho;0f,sqrt[1f-rho*rho])

spot:15.0
times:0f,(matur *til[steps-1]+1) % (steps-1)
/ Generate the normal distributed random variables

h:matur%steps
delta:sqrt h
show "We generate ",string[tmp:`int$num*steps-1]," normal distributed random variables now."
t:.z.t
wnt:sqrt[-2f * log tmp?1f ] */: (cos;sin) @\: 2*pi*tmp?1f
wnt:num cut/: W mmu wnt
show "It took " ,string[.z.t-t]," ."

show "We simulate the asset A and the spread"
t:.z.t

A:flip enlist[st],{ [x;y] x*exp (h*mu - 0.5 * vola * vola ) + vola * delta * y}\[st:num#spot;first wnt]
ekh:exp neg kappa * h
skh:sqrt eta * eta % 2f * kappa * 1f - ekh*ekh
lspr:flip enlist[st],{ (x*ekh) + (theta * 1f-ekh) + y * skh}\[st:num#theta;last wnt]
B:A*exp lspr    
spr:B-A
show "It took " ,string[.z.t-t]," ."

gamma:args`gamma;
show "According to the gamma: ",string[gamma],". We will now calculate the optimal positions."

alpha:{[x] g:sqrt 1f- gamma;  %[ kappa * 1f - g;  2f * eta *eta] *1+%[2f*g ; (1f-g)-exp[%[2f*kappa*matur-x;g] ]* 1+g] };
beta:{[x]  g:sqrt 1f- gamma;e:exp[%[2f*kappa* matur-x ;g ]];
    ee:1f-e;eta2:eta*eta; co:2f*rho*vola*eta;
    :(gamma*(g*ee*ee*eta2+co)- ee*eta2+co+2f*kappa*theta ) % (2f*eta2 * (1f-g)-e*1f+g)  };

hi:{[t;sp] ( (count[sp]#enlist beta[t])+(2f*sp*count[sp]#enlist alpha[t])
    -%[kappa*sp-theta;eta*eta]-%[rho*vola;eta]-0.5) %(1f-gamma)};

pos:hi[times;lspr];
del:flip deltas flip pos;
cfs:neg del*spr
scfs:flip sums flip cfs
tpnl:spr *pos
pnl:scfs+tpnl
plot:{ ([] times;pos:pos x;del:del x;cfs:cfs x;spr:spr x;scfs:scfs x;tpnl:tpnl x; pnl:pnl x;A:A x; B: B x; lspr:lspr x;ret:pnl[x]% abs[scfs x]  ) };
stats:{ /:ret:u:x`ret; }


(sqrt[252]*%[;] . stat),stat:(avg;dev) @\:plot[1234]`ret
(max;min)@\:plot[1234]`pnl
/

select times,lspr from plot 123
select c:count i by 100 xbar pnl from ([]pnl:last each pnl)
select pnl, sums[c] from  select c:count[i] by 100 xbar pnl from ([]pnl:last each pnl)
select pnl, sums[c] % num from  select c:count[i] by 1 xbar pnl from ([]pnl:last each pnl)
select from ([]til num;pnl:last each pnl) where pnl > 0

select count i by 10 xbar del from update del:deltas pnl from plot 3456
plot[3456]
num:5000;
mx : neg hopen args`mx

.z.ts:{ tmp:value flip plot num;
        a:1+num mod 4;
        stat:{x," ",y} over string (sqrt[252]*%[;] . stat),stat:(avg;dev)@\:plot[num]`ret;
        mx (`put;"tmp";tmp);
        mx (`evl;"ax(1)=subplot(2,2,1);");
        mx (`evl;"bar(tmp(1,:),tmp(2,:));");
        mx (`evl;"title('pos, num is ",string[num],"');");
        mx (`evl;"ax(2)=subplot(2,2,2);");
        mx (`evl;"bar(tmp(1,:),[0 diff(tmp(8,:))]);");
        mx (`evl;"title('del ",stat," ');");
        mx (`evl;"ax(3)=subplot(2,2,3);");
        mx (`evl;"plot(tmp(1,:),tmp(5,:));");
        mx (`evl;"title('spr');");
        mx (`evl;"ax(4)=subplot(2,2,4);");
        mx (`evl;"bar(tmp(1,:),tmp(8,:));");
        mx (`evl;"title('pnl');");
        mx (`evl;"linkaxes(ax,'x');");
        num::num+1;}

\t 2000

.z.ts[]
 
