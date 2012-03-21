
([]value "\\dir")
("SSSSSSSSSSSSSSSSSSSS"; enlist ";") 0: 10#read0 `$":index_fdax_ts_20090930.csv"
10#read0 `$":1019_00_D_08_E_20091102.csv"
([]100#read0 `$":2220-m_3_20080401.csv")

abc: ("SISSSFFSSFIFISFIS";enlist ",") 0: `$":2220-m_3_20080401.csv"

raze (#[100;];#[-2;]) @\: abc 
100#abc

select from abc where (EVENT_TYPE=`T),EXP_DAY=`080620
