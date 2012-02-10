\l fsm.q
\l seq.q
\l schema.q
\l uid.q
\l util.q
\l seqnew.q
\l math.q

args:.Q.def[`qx`nme!(`:localhost:2009;`zia)].Q.opt .z.x

/-------------------------------------------------------------------------
/Table for the fsm framework


orders : `uid xkey select sym,dir,prx,qty,uid,ste,tif:`$(),zia:`$() from .schema.orders
horders:           select sym,dir,prx,qty,uid,ste,tif:`$(),zia:`$() from .schema.orders

fillls : select sym,dir,prx,qty,uid,ste,rte from .schema.orders
trades : select sym,dir,prx,qty,    ste,rte,seq from .schema.orders

hobk   : select sym,dir,prx,qty,    ste,rte,seq,nmp:`int$() from .schema.orders
bbo    : `sym xkey select sym,bnmp:`int$(),bqty:`float$(), bprx:`float$(), aprx:`float$()
                       , aqty:`float$(),anmp:`int$(),spr:`float$(), seq,rte,ste from .schema.orders
obk::select from hobk where seq in (0!bbo)`seq

sign_ :{ ?[x=`BUY;-1f;1f]}
dir_  :{ ?[x=0f;`Ntl;?[x>0;`Lng;`Sht]] }

reports::update pnl:tpnl+cfs from 
         update dir:dir_ qty, tpnl:qty*?[qty<0;aprx;bprx]  
         from (select qty:sum qty,cfs:sum cfs by sym from update cfs:prx*qty*sign_ dir,qty:qty*neg sign_ dir from fillls) 
         lj bbo

ttable :delete from .fsm.ttable

/---------------------------------------------------------------------------------------------

`ttable insert (`Initial;`hopen;`AllOkay;
				{};{ :not 0=qx::neg hopen x; }
			   );

`ttable insert (`AllOkay;`login;`AllOkay;
				{ qx (`upd;`Login;x) };.fsm.always_true
			   );

`ttable insert (`AllOkay;`Fill;`AllOkay;
				{ `fillls insert update rte:.z.T from x;
				  { update qty:qty-x[`qty] from `orders where uid=x[`uid] } each x;
				    delete from `orders where qty=0;
				 };.fsm.always_true
			   );

`ttable insert (`AllOkay;`Trade;`AllOkay;
				{ `trades insert update rte:.z.T from x;
				  { update prx:x`prx from `zias where sym=x`sym} each x;
				 };
				.fsm.always_true);

`ttable insert (`AllOkay;`Obk;`AllOkay;
				{ `hobk insert t:update rte:.z.T,seq:first .seq.allocate[1] from x;
				  s:select sym,anmp:nmp,aqty:qty,aprx:prx,ste,rte,seq from select by sym from (`prx xdesc t) where dir=`SELL;
				  b:select sym,bnmp:nmp,bqty:qty,bprx:prx,ste,rte,seq from select by sym from (`prx xasc t) where dir=`BUY;
				  `bbo upsert update spr:aprx-bprx from b lj `sym xkey s;
				 };
				.fsm.always_true);


`ttable insert (`AllOkay;`day;`AllOkay;
				{`orders insert o: update uid:.uid.allocate[count x], ste:.z.T,tif:`Day from x;
				 `horders insert o;
				 o:delete zia from o;
				 { qx (`upd;`Day;x) } o;
				 };
				.fsm.always_true);

`ttable insert (`AllOkay;`ioc;`AllOkay;
				{`orders insert o: update uid:.uid.allocate[count x], ste:.z.T,tif:`IOC from x;
				 `horders insert o;
				 {qx (`upd;`IOC;x) } o;
				 };
				.fsm.always_true);

`ttable insert (`AllOkay;`cancel;`AllOkay;
				{t:0!select from `orders where uid in x`uid;
				 delete from `orders where uid in x`uid;
				 `horders insert update tif:`Cnc from t;
				 /break;
				 { qx (`upd;`Cancel; x) } x;
				 };
				.fsm.always_true);

`ttable insert (`AllOkay;`mao;`AllOkay;
				{`orders insert o: update uid:.uid.allocate[count x], ste:.z.T,tif:`MAO from x;
				 `horders insert o;
				 { qx (`upd;`MAO;enlist x) } each o;
				 };
				.fsm.always_true);

qx:0

initial_state:enlist `Initial
on_entry:{}
on_exit:{0N!"on_exit"}
no_transition:{[x;y] 0N!"no_transition for ",string[x]," and ",string y}
conf:`initial_state`on_entry`on_exit`no_transition`ttable!(initial_state;on_entry;on_exit;no_transition;ttable)

.fsm.def conf

ioc:{ x:$[98h=type x;x;enlist x ];upd[`ioc;]x; }
day:{ x:$[98h=type x;x;enlist x ];upd[`day;]x; }
cnc:{ x:$[98h=type x;x;enlist x ];upd[`cancel;]x; }
mao:{ x:$[98h=type x;x;enlist x ];upd[`mao;]x;}

/-------------------------------------------------------------------------
/ The table zias stores all the parameter for the

zias:([]
	  nme:`$(); sym:`$();ptk:`float$();
	  pcl:`int$();     / probability of cancel
	  pmo:`int$();     / probability of market order
	  plo:`int$();     / probability of limit order
	  lmu:`float$();   / probability of mu
	  lsi:`float$();   / probability of sigma
	  pis:`int$();     / probability of in spread
	  pos:`int$();     / probability of outside spread
	  alp:`float$();   / probability of alpha
	  ta1:`float$();   / tau1
	  ta2:`float$();   / tau2
	  wkp:`int$()      / wake up time
	 );
/------------------------------------------------------------------------------------

wkps:{n:count x; r:?[n?10b;x;y]; :`int$raze .rnd.expr[;1] each r}

.uid.init[`zias;3]
N:100;
zias:([] nme:.uid.alc[`zias;N];sym:`AAA;ptk:0.01;prx:100f;
	     pcl:2;pmo:3;plo:6;
	     lmu:4.5;lsi:0.8;
	     pis:1;pos:1;
	     alp:0.3;
	     ta1:60f;ta2:1800)

update wkp:wkps[ta1;ta2],dir:count[zias]?`BUY`SELL from `zias; 

side:()!()
side[`BUY]:1f
side[`SELL]: -1f

ios:()!()
ios[`pis] : { prx:bbo[x`sym;$[`BUY=x`dir;`bprx;`aprx]];
			  if[null prx;:x[`prx]+side[x`dir]*20*x`ptk ];
			  spr:bbo[x`sym;`spr];
			  if[null spr;:prx+side[x`dir]*20*x`ptk];
			  w:first 1?-1_1_til `int $ spr % x`ptk;
			  if[null w;:prx];
			  :prx+side[x`dir]*w*x`ptk}

ios[`pos] : { prx:bbo[x`sym;$[`BUY=x`dir;`bprx;`aprx]];
			  if[null prx;:x[`prx]-side[x`dir]*20*x`ptk ];
			  p:ceiling .rnd.par[1+0.3;1;30;1];
			  :x[`prx]-side[x`dir]*p*x`ptk
			 }


mds:()!()
mds[`pcl]: { o:select from orders where zia=x`nme; if[null last[o]`zia;:()]; cnc last 0!o;}
mds[`pmo]: { d:x`dir;qty:bbo[x`sym;$[`BUY=d;`aqty;`bqty] ];if[null qty;:()];
		     mao enlist `sym`qty`dir`zia!(x`sym;qty;x`dir;x`nme);}
mds[`plo]: { d:x`dir;qty:`float$ 1 | floor exp .rnd.norm[x`lmu;x`lsi;1];
			 ols:.rnd.urn[x;`pis`pos;1]; prx:ios[ols;x];
			 o:enlist `sym`dir`qty`prx`zia!(x`sym;d;qty;prx;x`nme);
			 day o;
			}

.z.ts:{ t:select from zias where wkp=0;
	    { mds[first .rnd.urn[x;`pcl`pmo`plo;1];x]; } each t;
	    update wkp:wkps[ta1;ta2],dir:count[zias]?`BUY`SELL from `zias;
	    min_ : min exec wkp from zias;
	    update wkp:wkp-min_ from `zias;
	    value "\\t ",string 1 | min_;
	   }


upd[`hopen;args`qx]
upd[`login;enlist[`name]!enlist args[`nme]]

/day enlist `sym`dir`prx`qty`zia!(`AAA;`SELL;101f;1000f;`init)
/day enlist `sym`dir`prx`qty`zia!(`AAA;`BUY;100f;1000f;`init)

/day enlist `sym`dir`prx`qty!(`AAA;`BUY;101f;1000f;`zia`first)

/if[ not 0=count select from (0!bbo) where not bprx=0n; "Error in obk"]
/if[ not 0=count select from (0!bbo) where not aprx=0n; "Error in obk"]

/

This is a test case to ensure that the qx is working correctly
