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


