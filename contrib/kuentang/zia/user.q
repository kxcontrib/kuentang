\l fsm.q
\l seq.q
\l schema.q
\l uid.q
\l util.q

args:.Q.def[`qx`nme!(`:localhost:2009;`user)].Q.opt .z.x

orders : `uid xkey select sym,dir,prx,qty,uid,ste,tif:`$() from .schema.orders
horders:           select sym,dir,prx,qty,uid,ste,tif:`$() from .schema.orders

fillls : select sym,dir,prx,qty,uid,ste,rte from .schema.orders
trades : select sym,dir,prx,qty,    ste,rte,seq from .schema.orders

hobk    : select sym,dir,prx,qty,    ste,rte,seq,nmp:`int$() from .schema.orders
bbo    : `sym xkey select sym,bnmp:`int$(),bqty:`float$(), bprx:`float$(), aprx:`float$()
                       , aqty:`float$(),anmp:`int$(), seq,rte,ste from .schema.orders
obk::select from hobk where seq in (0!bbo)`seq

sign_ :{ ?[x=`BUY;-1f;1f]}
dir_  :{ ?[x=0f;`Ntl;?[x>0;`Lng;`Sht]] }

reports::update pnl:tpnl+cfs from 
         update dir:dir_ qty, tpnl:qty*?[qty<0;aprx;bprx]  
         from (select qty:sum qty,cfs:sum cfs by sym from update cfs:prx*qty*sign_ dir,qty:qty*neg sign_ dir from fillls) 
         lj bbo

ttable :delete from .fsm.ttable

`ttable insert (`Initial;`hopen;`AllOkay;
				{};
				{ :not 0=qx::neg hopen x; }
			   );

`ttable insert (`AllOkay;`login;`AllOkay;
				{ qx (`upd;`Login;x) };
				.fsm.always_true
			   );

`ttable insert (`AllOkay;`Fill;`AllOkay;
				{ `fillls insert update rte:.z.T from x;
				  { update qty:qty-x[`qty] from `orders where uid=x[`uid] } each x;
				    delete from `orders where qty=0;
				 };
				.fsm.always_true
			   );

`ttable insert (`AllOkay;`Trade;`AllOkay;
				{ `trades insert update rte:.z.T from x;};
				.fsm.always_true);

`ttable insert (`AllOkay;`Obk;`AllOkay;
				{ `hobk insert t:update rte:.z.T,seq:first .seq.allocate[1] from x;
				  s:select sym,anmp:nmp,aqty:qty,aprx:prx,ste,rte,seq from select by sym from (`prx xdesc t) where dir=`SELL;
				  b:select sym,bnmp:nmp,bqty:qty,bprx:prx,ste,rte,seq from select by sym from (`prx xasc t) where dir=`BUY;
				  `bbo upsert b lj `sym xkey s;
				 };
				.fsm.always_true);


`ttable insert (`AllOkay;`day;`AllOkay;
				{`orders insert o: update uid:.uid.allocate[count x], ste:.z.T,tif:`Day from x;
				 `horders insert o;
				 qx (`upd;`Day;o);
				 };
				.fsm.always_true);

`ttable insert (`AllOkay;`ioc;`AllOkay;
				{`orders insert o: update uid:.uid.allocate[count x], ste:.z.T,tif:`IOC from x;
				 `horders insert o;
				 qx (`upd;`IOC;o);
				 };
				.fsm.always_true);

`ttable insert (`AllOkay;`mao;`AllOkay;
				{`orders insert o: update uid:.uid.allocate[count x], ste:.z.T,tif:`MAO from x;
				 `horders insert o;
				 qx (`upd;`MAO;o);
				 };
				.fsm.always_true);


`ttable insert (`AllOkay;`cancel;`AllOkay;
				{t:0!select from `orders where uid in x`uid;
				 delete from `orders where uid in x`uid;
				 `horders insert update tif:`Cnc from t;
				 qx (`upd;`Cancel;x);
				 };
				.fsm.always_true);

initial_state:enlist `Initial
on_entry:{}
on_exit:{0N!`$raze "on_exit"}
no_transition:{[x;y] 0N!`$raze "no_transition for ",string[x]," and ",string y}
conf:`initial_state`on_entry`on_exit`no_transition`ttable!(initial_state;on_entry;on_exit;no_transition;ttable)

.fsm.def conf

ioc:{ t:(type[x]=98h | type[x]=99h); if[not t;:show "usage day enlist `sym`dir`prx`qty!(`AAA;`BUY;100f;1000f)"];  upd[`ioc;] x;}
day:{ t:(type[x]=98h | type[x]=99h); if[not t;:show "usage day enlist `sym`dir`prx`qty!(`AAA;`BUY;100f;1000f)"];  upd[`day;] x;}
cnc:{ t:(type[x]=98h | type[x]=99h); if[not t;:show "usage day enlist enlist[`uid]!enlist `0001"];   upd[`cancel;]x;}
mao:{ t:(type[x]=98h | type[x]=99h); if[not t;:show "usage day enlist `sym`dir`prx`qty!(`AAA;`BUY;100f;1000f)"];  upd[`mao;] x;}


upd[`hopen;args`qx]
upd[`login;enlist[`name]!enlist args[`nme]]

/day enlist `sym`dir`prx`qty!(`AAA;`BUY;100f;100f)
/day enlist `sym`dir`prx`qty!(`AAA;`SELL;101f;100f)


/

upd[`hopen;args`qx]
upd[`login;enlist[`name]!enlist args[`nme]]

day enlist `sym`dir`prx`qty!(`AAA;`BUY;100f;1000f)
day enlist `sym`dir`prx`qty!(`AAA;`BUY;99f;1000f)
day enlist `sym`dir`prx`qty!(`AAA;`SELL;101f;1000f)
day enlist `sym`dir`prx`qty!(`AAA;`SELL;102f;1000f)

day enlist `sym`dir`prx`qty!(`AAA;`BUY;101f;1000f)
day enlist `sym`dir`prx`qty!(`AAA;`BUY;102f;1000f)
day enlist `sym`dir`prx`qty!(`AAA;`SELL;100f;1000f)
day enlist `sym`dir`prx`qty!(`AAA;`SELL;99f;1000f)

/if[ not 0f=first (0!reports)`qty;0N!"Error in qty"]
/if[ not 0f=first (0!reports)`cfs;0N!"Error in cfs"]



/if[ not 0=count select from (0!bbo) where not bprx=0n; "Error in obk"]
/if[ not 0=count select from (0!bbo) where not aprx=0n; "Error in obk"]

/

This is a test case to ensure that the qx is working correctly