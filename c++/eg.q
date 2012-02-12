/This script is for use with the example c code contained inthe same directory
/The file should be loaded into the appropriate q server.

/" Over written .z.p[sg], .z.p[oc] message handlers"

.log.out:{[x]0N! x};
.z.po:{[x].log.out[`message`con`user`ip!(" connection opened";x;.z.u;.z.a)]};
.z.pc:{[x].log.out[`message`con!(" connection closed";x)]};
.z.pg:{[x].log.out[`message`con`user`ip`data!(" synch  [get] message";x;.z.u;.z.a;x)];value[x]};
.z.ps:{[x].log.out[`message`con`user`ip`data!(" asynch [set] message";x;.z.u;.z.a;x)];value[x]};
display:{[x] show x};

/Functions with different valencies for use by c client.

f1s:{[x]:x};
f2i:{[x;y]:x+y};
f3f:{[x;y;z]x+y+z};
t1:([]x:1 2 3;y:1 2 3.;z:`qq`we`re;w:"qwe");

