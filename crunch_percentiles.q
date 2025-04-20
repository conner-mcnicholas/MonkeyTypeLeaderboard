f:{[t;c]
    dmap:(distinct desc 8h$t[c])!100*sums value (count each group desc 8h$t[c])%count t;
    newcol:`$(string c),"pct";
    ![t;();0b;(enlist newcol)!enlist(`dmap;($;8h;c))]}

fp:{[t;c]
    dmap:(distinct desc 8h$t[c])!100*sums value (count each group desc 8h$t[c])%count t;
    flip (c;`pctl)!(key dmap;value dmap)}

// ################# mode = 60 second #################

pct60:("ISFFFFZ";enlist ",") 0: read0 `$"data\\leaderboard_60sec.csv"
pct60:update diff:raw-wpm from pct60

pct60:f[pct60;`wpm]
pct60:f[pct60;`raw]
pct60:f[pct60;`acc]
pct60:f[pct60;`consistency]
pct60:f[pct60;`diff]
pct60:f[pct60;`datetime]
pct60:update delta:wpmpct-accpct from pct60
pct60:f[pct60;`delta]

wpm60:fp[pct60;`wpm]
raw60:fp[pct60;`raw]
acc60:fp[pct60;`acc]
cons60:fp[pct60;`consistency]                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
diff60:fp[pct60;`diff]
datetime60:fp[pct60;`datetime]
delta60:fp[pct60;`delta]

// ################# mode = 15 second #################

pct15:("ISFFFFZ";enlist ",") 0: read0 `$"data\\leaderboard_15sec.csv"

0N!"# records 15 second leaderboard: ",string(count(pct15))
0N!"# records 60 second leaderboard: ",string(count(pct60))

// Removing any records from the 15second leaderboard with wpm rates slower than the user's 60second rate
common: (pct15`name) inter pct60`name
common15: 1!select name,wpm15:wpm from pct15 where name in common
common60: 1!select name,wpm60:wpm from pct60 where name in common
0N!"# users have submitted scores in both 15 and 60 second modes: ",string(count(common))

both: common15 lj common60
trash: exec name from 0!both where wpm15 < wpm60
pct15:delete from pct15 where name in trash

0N!"removed ",(string (count(trash)))," users from the 15 second leaderboard who have faster 60 second scores"

0N!"# records 15 second leaderboard post pruning: ",string(count(pct15))

pct15:update diff:raw-wpm from pct15

pct15:f[pct15;`wpm]
pct15:f[pct15;`raw]
pct15:f[pct15;`acc]
pct15:f[pct15;`consistency]
pct15:f[pct15;`diff]
pct15:f[pct15;`datetime]
pct15:update delta:wpmpct-accpct from pct15
pct15:f[pct15;`delta]

wpm15:fp[pct15;`wpm]
raw15:fp[pct15;`raw]
acc15:fp[pct15;`acc]
cons15:fp[pct15;`consistency]
diff15:fp[pct15;`diff]
datetime15:fp[pct15;`datetime]
delta15:fp[pct15;`delta]

// ################# conversion tables #################

wpmtab:update mult:wpm15%wpm60,gap:wpm15-wpm60 from (select wpm60:max wpm by .5 xbar pctl from wpm60)lj(select wpm15:max wpm by .5 xbar pctl from wpm15)
rawtab:update mult:raw15%raw60,gap:raw15-raw60 from (select raw60:max raw by .5 xbar pctl from raw60)lj(select raw15:max raw by .5 xbar pctl from raw15)
acctab:update mult: acc15%acc60,gap:acc15-acc60 from (select acc60:max acc by .5 xbar pctl from acc60)lj(select acc15:max acc by .5 xbar pctl from acc15)
constab:update mult:cons15%cons60,gap:cons15-cons60 from (select cons60:max consistency by .5 xbar pctl from cons60)lj(select cons15:max consistency by .5 xbar pctl from cons15)
difftab:update mult:diff15%diff60,gap:diff15-diff60 from (select diff60:max diff by .5 xbar pctl from diff60)lj(select diff15:max diff by .5 xbar pctl from diff15)
datetab:update mult:datetime15%datetime60,gap:datetime15-datetime60 from (select datetime60:max datetime by .5 xbar pctl from datetime60)lj(select datetime15:max datetime by .5 xbar pctl from datetime15)
deltatab:update mult:delta15%delta60,gap:delta15-delta60 from (select delta60:max delta by .5 xbar pctl from delta60)lj(select delta15:max delta by .5 xbar pctl from delta15)

// ################ SAVING TO DATA DIR ################

system("cd data")

save `wpm60.csv
save `raw60.csv
save `acc60.csv
save `cons60.csv
save `diff60.csv
save `datetime60.csv
save `delta60.csv
save `:pct60.csv

save `wpm15.csv
save `raw15.csv
save `acc15.csv
save `cons15.csv
save `diff15.csv
save `datetime15.csv
save `delta15.csv
save `:pct15.csv

save `wpmtab.csv
save `rawtab.csv
save `acctab.csv
save `constab.csv
save `difftab.csv
save `datetab.csv
save `deltatab.csv  

system("cd ..")

0N!"SUCCESSFULLY SAVED DOWN ALL TABLES - exiting"