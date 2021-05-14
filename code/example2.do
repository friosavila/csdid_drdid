adopath + C:\Users\Fernando\Documents\GitHub\csdid_drdid\code
adopath + C:\Users\Fernando\Documents\GitHub\csdid_drdid\data
sysuse sim_rc, clear

** para Cross section
drdid y x1 x2 x3 x4, time(post) tr( d)   all 

sysuse lalonde, clear
** Para panel
drdid re age educ black married nodegree hisp re74 if treated==0 | sample==2 , ivar(id) time(year) tr( experimental )  all

