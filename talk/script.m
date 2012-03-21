javaaddpath('C:\q\matlab\jdbc.jar');
kdb=c('localhost',1234);
%%
r= fetch(kdb,'reports')
plot(r.r1,r.r2,'.')
%%
L = fetch(kdb,'([]a1 :first L; a2: last L)')
%%
c10 = fetch(kdb,'select c:count i by 1 xbar pnl from reports[-10f]');
c50 = fetch(kdb,'select c:count i by 1 xbar pnl from reports[-50f]');
c100 = fetch(kdb,'select c:count i by 1 xbar pnl from reports[-100f]');
c150 = fetch(kdb,'select c:count i by 1 xbar pnl from reports[-150f]');
c200 = fetch(kdb,'select c:count i by 1 xbar pnl from reports[-200f]');
c250 = fetch(kdb,'select c:count i by 1 xbar pnl from reports[-250f]');
c500 = fetch(kdb,'select c:count i by 1 xbar pnl from reports[-500f]');

plot(c10.pnl,c10.c,c50.pnl,c50.c,c100.pnl,c100.c,c150.pnl,c150.c ... 
    ,c200.pnl,c200.c ... 
    ,c250.pnl,c250.c,c500.pnl,c500.c)
%%
c10 = fetch(kdb,'select pnl, c:sums c from  select c:count[i] by 1 xbar pnl from reports[-10f]');
c50 = fetch(kdb,'select pnl, c:sums c from  select c:count[i] by 1 xbar pnl from reports[-50f]');
c100 = fetch(kdb,'select pnl, c:sums c from  select c:count[i] by 1 xbar pnl from reports[-100f]');
c150 = fetch(kdb,'select pnl, c:sums c from  select c:count[i] by 1 xbar pnl from reports[-150f]');
c200 = fetch(kdb,'select pnl, c:sums c from  select c:count[i] by 1 xbar pnl from reports[-200f]');
c250 = fetch(kdb,'select pnl, c:sums c from  select c:count[i] by 1 xbar pnl from reports[-250f]');
c500 = fetch(kdb,'select pnl, c:sums c from  select c:count[i] by 1 xbar pnl from reports[-500f]');

plot(c10.pnl,c10.c,c50.pnl,c50.c,c100.pnl,c100.c,c150.pnl,c150.c ... 
    ,c200.pnl,c200.c ... 
    ,c250.pnl,c250.c,c500.pnl,c500.c)
%%
 plotyy(rep.time,rep.A,rep.time,rep.B)
%%
plotyy(rep.time,rep.lspr,rep.time,rep.spr)
%%
plotyy(rep.time,rep.pos,rep.time,rep.lspr)
%%
subplot(2,2,1)
plotyy(rep.time,rep.A,rep.time,rep.B)

subplot(2,2,2)
plotyy(rep.time,rep.pos,rep.time,rep.lspr)

subplot(2,2,3)
plotyy(rep.time,rep.pos,rep.time,rep.spr)

subplot(2,2,4)
plotyy(rep.time,rep.pos,rep.time,rep.pnl)

