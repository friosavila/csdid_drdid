/** Command 
drdid: Doubly Robust  DID
Syntax
drdid outcome xvars if (conditions), ivar(panelidvar) time(timevar) tr(treatment group)
xvar: This are all controls for the oucome model and for the propensity score
ivar: must include the panel identifier
time: Variable identifying Time.
tr: Variable identify ever treated group

*/
adopath + C:\Users\Fernando\Documents\GitHub\csdid_drdid\code
adopath + C:\Users\Fernando\Documents\GitHub\csdid_drdid\data
sysuse lalonde, clear
** Example Simple Panel estimator
drdid re age educ black married nodegree hisp re74 if treated==0 | sample==2 , ivar(id) time(year) tr( experimental )  
drdid re age educ black married nodegree hisp re74 if treated==0 | sample==2 , ivar(id) time(year) tr( experimental )  all
** DRDID IPW instead of IPT
drdid re age educ black married nodegree hisp re74 if treated==0 | sample==2 , ivar(id) time(year) tr( experimental )  drimp

drdid re age educ black married nodegree hisp re74 if treated==0 | sample==2 , ivar(id) time(year) tr( experimental )  dripw

drdid re age educ black married nodegree hisp re74 if treated==0 | sample==2 , ivar(id) time(year) tr( experimental )  reg

drdid re age educ black married nodegree hisp re74 if treated==0 | sample==2 , ivar(id) time(year) tr( experimental )  sipw

drdid re age educ black married nodegree hisp re74 if treated==0 | sample==2 , ivar(id) time(year) tr( experimental )  ipwra

** Example RC estimator
drdid re age educ black married nodegree hisp re74 if treated==0 | sample==2 ,   time(year) tr( experimental )  

** need to think of doing this via Moptimize
sysuse mpdta, clear
foreach i in 2004 2005 2006 2007 {
display "group:2004 TY:`i'"
drdid  lemp lpop if inlist(first_treat,0,2004) & inlist(year,2003,`i'), ivar(countyreal)  time(year) tr(treat)
}

foreach i in 2004 2005 2006 2007 {
display "group:2004 TY:`i'"
drdid  lemp lpop if inlist(first_treat,0,2007) & inlist(year,2003,`i'), ivar(countyreal)  time(year) tr(treat)
}

*** 2003 is universtal T0
** How to detect is the one before....
drdid  lemp lpop if inlist(first_treat,0,2004) & inlist(year,2003,2004), ivar(countyreal)  time(year) tr(treat)

drdid  lemp lpop if inlist(first_treat,0,2004) & inlist(year,2003,2005), ivar(countyreal)  time(year) tr(treat)

drdid  lemp lpop if inlist(first_treat,0,2004) & inlist(year,2003,2006), ivar(countyreal)  time(year) tr(treat)

drdid  lemp lpop if inlist(first_treat,0,2004) & inlist(year,2003,2007), ivar(countyreal)  time(year) tr(treat)

** How to detect is the one before....
drdid  lemp lpop if inlist(first_treat,0,2006) & inlist(year,2003,2004), ivar(countyreal)  time(year) tr(treat)

drdid  lemp lpop if inlist(first_treat,0,2006) & inlist(year,2004,2005), ivar(countyreal)  time(year) tr(treat)

drdid  lemp lpop if inlist(first_treat,0,2006) & inlist(year,2005,2006), ivar(countyreal)  time(year) tr(treat)

drdid  lemp lpop if inlist(first_treat,0,2006) & inlist(year,2005,2007), ivar(countyreal)  time(year) tr(treat)

** How to detect is the one before....
drdid  lemp lpop if inlist(first_treat,0,2007) & inlist(year,2003,2004), ivar(countyreal)  time(year) tr(treat)

drdid  lemp lpop if inlist(first_treat,0,2007) & inlist(year,2004,2005), ivar(countyreal)  time(year) tr(treat)

drdid  lemp lpop if inlist(first_treat,0,2007) & inlist(year,2005,2006), ivar(countyreal)  time(year) tr(treat)

drdid  lemp lpop if inlist(first_treat,0,2007) & inlist(year,2006,2007), ivar(countyreal)  time(year) tr(treat)

/////
sysuse mpdta, clear
csdid  lemp lpop , ivar(countyreal) time(year) gvar(first_treat)

/*
. csdid  lemp lpop , ivar(countyreal) time(year) gvar(first_treat) notyet
Callaway Santana (2021)
------------------------------------------------------------------------------
             |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
g2004        |
 t_2003_2004 |  -.0211832   .0216696    -0.98   0.328    -.0636549    .0212885
 t_2003_2005 |  -.0816037    .028369    -2.88   0.004     -.137206   -.0260014
 t_2003_2006 |  -.1384089    .033571    -4.12   0.000    -.2042068    -.072611
 t_2003_2007 |  -.0923548    .031973    -2.89   0.004    -.1550208   -.0296888
-------------+----------------------------------------------------------------
g2006        |
 t_2003_2004 |  -.0074923   .0218504    -0.34   0.732    -.0503182    .0353336
 t_2004_2005 |  -.0046434   .0182985    -0.25   0.800    -.0405079    .0312211
 t_2005_2006 |   .0086951   .0168543     0.52   0.606    -.0243388    .0417289
 t_2005_2007 |  -.0223236   .0187218    -1.19   0.233    -.0590177    .0143706
-------------+----------------------------------------------------------------
g2007        |
 t_2003_2004 |   .0266993   .0140788     1.90   0.058    -.0008947    .0542933
 t_2004_2005 |  -.0045906    .015728    -0.29   0.770    -.0354169    .0262357
 t_2005_2006 |  -.0284515   .0181982    -1.56   0.118    -.0641193    .0072163
 t_2006_2007 |  -.0287821   .0162518    -1.77   0.077     -.060635    .0030709
------------------------------------------------------------------------------
Control: Not yet Treated
*/
