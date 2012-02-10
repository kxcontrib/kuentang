
\l fsm.q
\l seq.q
\l schema.q
\l uid.q
\l util.q

args:.Q.def[enlist[`nme]!enlist `qxe].Q.opt .z.x

.uid.n:4 / for members we only need 4 digits

orders :delete from .schema.orders
members:delete from .schema.members

choose:()!()
choose[`SELL]:{t:`prx xdesc`seq xasc select from `orders where sym = x[`sym], dir = `BUY, prx >= x[`prx];
			    delete from `orders where sym = x[`sym], dir = `BUY, prx >= x[`prx];:t}

choose[`BUY]: {t:`prx`seq xasc select from `orders where sym = x[`sym], dir = `SELL, prx <= x[`prx];
			   delete from `orders where sym = x[`sym], dir = `SELL, prx <= x[`prx];:t}

matching:{[x;y]   x:update rqty:qty & 0f | sums[qty]-y[`qty] from x;  / calculate the fill volume
			      x:update tqty:qty-rqty from select from x ;
			      fill:select sym,dir,prx,qty:tqty,uid,who from x where tqty > 0; / the passive side
		          y:update qty:qty-(sum exec qty from fill) from y;
			      trade:select sym,dir:y[`dir],prx,qty from fill;                 / all trades are marked with the acive side
			      fill,:update dir:y[`dir],uid:y[`uid],who:y[`who] from fill;     / the active side
		          x:update qty:rqty from x;
			      x:flip cols[orders]!x[cols orders];
			      :`passive`fill`trade`o!(x;fill;trade;y)
			}

nullobk:{[x] t:`sym`dir`prx`qty`ste`seq`nmp!($[1=count x;first x;x];`BUY;0n;0n;.z.T;.seq.allocate[count x];0N);
		     :$[1=count x;enlist t; flip t ];}

ttable :delete from .fsm.ttable

`ttable insert (`AllOkay;`Login;`AllOkay;
				{`members insert (.uid.allocate[1];.z.w;x[`name])};
				.fsm.always_true);

`ttable insert (`AllOkay;`Day;`AllOkay;
				{if[not .z.w in members`hdl; :() ];
				 t:raze {p:choose[x`dir;x];                                                / choose all matchable day orders
						 e:matching[p;x];
						 upd[`fill;e`fill];                                                / we publish the fills first
						 `orders insert oo:select from $[98h=type e`o;e`o;enlist e`o] where qty>0;       / if it is a day order we need to put it in the orders back
						 `orders insert oo:select from $[98h=type e[`passive];e[`passive];enlist e[`passive]] where qty>0;
						 /show oo;
						 :e`trade
						} each update who:.z.w,rte:.z.T,seq:.seq.allocate[count x] from x;				 
				 upd[`trade;t];
				 upd[`obk;distinct exec sym from x];
				};
				.fsm.always_true);

`ttable insert (`AllOkay;`fill;`AllOkay;
				{ { .utl.printif @[neg x[`who]; (`upd; `Fill; select sym,dir,prx,qty,uid,ste:.z.T from enlist x); 
								   "failed to write fills to ", string x[`who]];
				   } each x;
				};
				.fsm.always_true);

`ttable insert (`AllOkay;`trade;`AllOkay;
				{ x{[x;y]  .utl.printif @[neg y; (`upd; `Trade; update ste:.z.T,seq:.seq.allocate[count x] from x); 
										  "failed to write trade to ", string y];}/: members`hdl;};
				.fsm.always_true);

`ttable insert (`AllOkay;`obk;`AllOkay;
				{  t:0!select qty:sum qty, nmp:count i,ste:.z.T by sym,dir,prx from orders where sym in x;
				   t:$[0=count t;nullobk[distinct x];t];
				   t{[x;y]  .utl.printif @[neg y; (`upd; `Obk; x); "failed to write obk to ", string y];}/: members`hdl;
				};
				.fsm.always_true);

`ttable insert (`AllOkay;`Cancel;`AllOkay;
				{ syms:exec distinct sym from orders where who=.z.w,uid in x`uid;
				  delete from `orders where who=.z.w,uid in x`uid;
				  upd[`obk;syms];
				 };
				.fsm.always_true);


`ttable insert (`AllOkay;`IOC;`AllOkay;
				{if[not .z.w in members`hdl; :() ];
				 t:raze {p:choose[x`dir;x];                                       / choose all matchable day orders
						 e:matching[p;x];
						 upd[`fill;e`fill];                                                / we publish the fills first
						 orders,: select from e[`passive] where qty>0;
						 :e`trade
				 } each update who:.z.w,rte:.z.T,seq:.seq.allocate[count x] from x;				 
				 upd[`trade;t];
				 upd[`obk;distinct exec sym from x];
				};
				.fsm.always_true);

`ttable insert (`AllOkay;`MAO;`AllOkay;
				{if[not .z.w in members`hdl; :() ];
				 x:update prx:?[`BUY=x`dir; 0w;-0w ] from x;
				 t:raze {p:choose[x`dir;x];                                       / choose all matchable day orders
						 e:matching[p;x];
						 upd[`fill;e`fill];                                                / we publish the fills first
						 orders,: select from e[`passive] where qty>0;
						 :e`trade
				 } each update who:.z.w,rte:.z.T,seq:.seq.allocate[count x] from x;				 
				 upd[`trade;t];
				 upd[`obk;distinct exec sym from x];
				};
				.fsm.always_true);

initial_state:enlist `AllOkay
on_entry:{ .z.pc::{delete from `members where hdl=x;
				   syms:exec distinct sym from orders where who=x;
				   delete from `orders where who=x;
				   upd[`obk;syms];} 
		  }
on_exit:{0N!"on_exit"}
no_transition:{[x;y] 0N!"no_transition for ",string[x]," and ",string y}
conf:`initial_state`on_entry`on_exit`no_transition`ttable!(initial_state;on_entry;on_exit;no_transition;ttable)

.fsm.def conf


/

This script will implement an exchange. It needs to be able to react to 4 events.
`Day`IOC`Cancel`Login

Day or Limit orders have the structure
Afterwards it needs to send 4 events. These are `Reject`Fill`OBK`Trade