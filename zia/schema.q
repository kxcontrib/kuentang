
\d .schema

orders:([] 
		sym:`      $(); / symbol of the share
		dir:`      $(); / direction of the order, usually buy or sell
		prx:`float $(); / price of the limit order
		qty:`float $(); / the qty to buy the share

		uid:`      $(); / unique id of the order
		ste:`time  $(); / send time of this order
		tif:`      $();  

		who:`int   $(); / the handle of the market participant
		rte:`time  $(); / the receive time of this order
		seq:`long  $()  / the sequence order of this order
	   )

members:([]
		 uid:`$();
		 hdl:`int$();
		 nme:`$()
		)

\d .