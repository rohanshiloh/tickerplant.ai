/ perf.q: every 30 s, record throughput, service time, memory, CPU and output-queue depth
/ into the in-memory keyed tables .perf.stats (one row per snapshot) and .perf.bytbl (per table).
/ Load into any running process with an ABSOLUTE path (RDB/WDB/IDB/HDB have cd'd elsewhere):
/   \l /Users/you/Code/blueprints-scalable-ingestion/perf.q
/ It wraps the process's update entry point (.u.upd on a TP, upd on an RDB/WDB) and chains onto
/ any existing .z.ts, so the process keeps working exactly as before. Undo with .perf.stop[].

.perf.iv:0D00:00:30;                                   / snapshot interval
.perf.keep:1D;                                         / history to keep in memory
.perf.names:5010 5011 5013 5015 5020 5021 5023 5025 5012 5030 5110 5099!`TP0`RDB0`WDB0`IDB0`TP1`RDB1`WDB1`IDB1`HDB`GW`CTP`TP9;
.perf.proc:{$[null p:.perf.names "j"$system"p";`$"p",string system"p";p]};

.perf.stats:([time:`timestamp$()] proc:`symbol$(); msgs:`long$(); rows:`long$(); msgps:`float$(); rowps:`float$();
  avgus:`float$(); maxus:`float$(); busy:`float$(); usedmb:`float$(); heapmb:`float$(); rssmb:`float$();
  cpu:`float$(); subs:`long$(); qbytes:`long$(); qmax:`long$());
.perf.bytbl:([time:`timestamp$(); tbl:`symbol$()] msgs:`long$(); rows:`long$(); rowps:`float$());

/ counters for the current interval
.perf.reset:{.perf.m:.perf.r:(`$())!`long$(); .perf.ns:.perf.mx:0j; .perf.t0:.z.p};
.perf.reset[];

/ rows in one update: a table (RDB side), a list of columns, or a single row of atoms (TP side)
.perf.rc:{$[98=type x;count x;0>type first x;1;count first x]};
/ one ps field for this process: "%cpu" or "rss" (KB); null if ps is unavailable
.perf.ps:{@[{"F"$trim first system"ps -o ",x,"= -p ",string .z.i};x;0n]};

/ wrapper: time every update and count messages and rows per table
.perf.wrap:{[f;t;x] s:.z.p; r:f[t;x]; d:"j"$.z.p-s;
  .perf.m[t]:1+0^.perf.m t; .perf.r[t]:(.perf.rc x)+0^.perf.r t; .perf.ns+:d; .perf.mx|:d; r};

/ take one snapshot and start a new interval
.perf.snap:{
  n:.z.p; s:1e-9*"j"$n-.perf.t0; k:sum .perf.m; rw:sum .perf.r; w:.Q.w[]; v:"j"$sum each value .z.W;
  `.perf.stats upsert (n;.perf.proc[];k;rw;k%s;rw%s;$[k;1e-3*.perf.ns%k;0f];1e-3*.perf.mx;1e-7*.perf.ns%s;
    1e-6*w`used;1e-6*w`heap;1e-3*.perf.ps"rss";.perf.ps"%cpu";count v;sum v;max 0,v);
  if[count .perf.m;
    `.perf.bytbl upsert ([] time:n; tbl:key .perf.m; msgs:value .perf.m; rows:.perf.r key .perf.m; rowps:(.perf.r key .perf.m)%s)];
  delete from `.perf.stats where time<n-.perf.keep;
  delete from `.perf.bytbl where time<n-.perf.keep;
  .perf.reset[]};

/ install: wrap the update function once, chain the timer, make sure a timer is running
.perf.fn:$[`upd in key`.u;`.u.upd;`upd in key`.;`upd;`];
if[not[null .perf.fn] and not `orig in key`.perf; .perf.orig:get .perf.fn; .perf.fn set .perf.wrap[.perf.orig]];
if[not `prevts in key`.perf; .perf.prevts:@[get;`.z.ts;{{}}]];
.z.ts:{.perf.prevts x; if[.z.p>=.perf.t0+.perf.iv; .perf.snap[]]};
if[0=system"t"; system"t 1000"];

.perf.stop:{if[not null .perf.fn; .perf.fn set .perf.orig]; .z.ts:.perf.prevts;
  delete orig, prevts from `.perf; -1"perf: stopped"};

-1"perf: ",string[.perf.proc[]]," snapshots every ",string[.perf.iv],", wrapping ",$[null .perf.fn;"nothing";string .perf.fn];
