adopath + C:\Users\Fernando\Documents\GitHub\csdid_drdid\code
adopath + C:\Users\Fernando\Documents\GitHub\csdid_drdid\data
sysuse sim_rc, clear

** para Cross section
drdid y x1 x2 x3 x4, time(post) tr( d)   all 

sysuse lalonde, clear
** Para panel
drdid re age educ black married nodegree hisp re74 if treated==0 | sample==2 , ivar(id) time(year) tr( experimental )  all

sysuse mpdta, clear
csdid  lemp lpop , ivar(countyreal) time(year) gvar(first_treat) reg  


** Examples for simple aggregation.
** assumes balance panel. Across time same weight. across groups weight by group
lincom (100*_b[g2004:t_2003_2004]+200*_b[g2006:t_2005_2006]+655*_b[g2007:t_2006_2007])/(100+200+655)
lincom (100*_b[g2004:t_2003_2005]+200*_b[g2006:t_2005_2007])/300
lincom (_b[g2004:t_2003_2006])
lincom (_b[g2004:t_2003_2007])

lincom (_b[g2004:t_2003_2004]+_b[g2004:t_2003_2005]+_b[g2004:t_2003_2006]+_b[g2004:t_2003_2007])/4

/*gen sm=_g2004_2003_2007!=. |  _g2006_2005_2007!=. |  _g2007_2006_2007!=.
capture program drop suunx
program suunx
args lnf x1 x2 x3

qui: {
	replace `lnf'=0
	replace `lnf'=`lnf'-($ML_y1-`x1')^2 if $ML_y1!=.
	replace `lnf'=`lnf'-($ML_y2-`x2')^2 if $ML_y2!=.
	replace `lnf'=`lnf'-($ML_y3-`x3')^2 if $ML_y3!=.
}
end

ml model lf suunx (_g2004_2003_2004  = )  (_g2006_2005_2006= )  (_g2007_2006_2007= ) , miss robust
ml maximize
lincom (100*_b[eq1:_cons]+200*_b[eq2:_cons]+655*_b[eq3:_cons])/(655+200+100)
pseudo SIM regression for aggregation
*/
