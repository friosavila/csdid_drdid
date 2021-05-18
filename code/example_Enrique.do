adopath + C:\Users\Fernando\Documents\GitHub\csdid_drdid\code
adopath + C:\Users\Fernando\Documents\GitHub\csdid_drdid\data
**#Example
sysuse lalonde, clear
** Para panel
drdid re age educ black married nodegree hisp re74 if treated==0 | sample==2 , ivar(id) time(year) tr( experimental )  drimp
drdid re age educ black married nodegree hisp re74 if treated==0 | sample==2 , ivar(id) time(year) tr( experimental )  all

** El comando de arriba reproduce todos los modelos que Sant'Anna & Zhao (2020) tienen en su paper.
** Estos puede reproducirse asi:

sysuse lalonde, clear

** DRIPW
global xvar age educ black married nodegree hisp re74
keep if treated==0 | sample==2 
logit experimental $xvar if year==1975 
predict pscore

** obtener el "cambio" en el outcome (first DIff)
bysort id (year):gen double __dy__=re[2]-re[1] 

reg __dy__ $xvar if experimental==0  & year==1975
predict dy_hat

** weights
gen wgt1=experimental
gen wgt0= pscore * (1 - experimental)/(1 - pscore)
** normalized weights
sum wgt1
replace wgt1=wgt1/r(mean)
sum wgt0
replace wgt0=wgt0/r(mean)
** Effecto:
gen att=(wgt1-wgt0)*(__dy__-dy_hat)
sum att if year==1975

** DRIMP Improved IPT: Este es el que se considera el preferido

** IPT en vez de logit
mlexp ( experimental*{xb:$xvar _cons}- (experimental==0)*exp({xb:}) ) if year == 1975, vce(robust)
** predict pscore2
predictnl pscore2=logistic(xb())

** Normalize weight

gen wgt00=((pscore2*(1-experimental)))/(1-pscore2)
sum wgt00
replace wgt00=wgt00/r(mean)
** Weight1 es el mismo que antes.


** Weighted OLS
reg __dy__ $xvar [w=wgt00] if experimental==0  & year==1975
predict dy_hat2

** El efecto
gen att2=(wgt1-wgt00)*(__dy__-dy_hat2)
sum att2 if year==1975


*** REG is basicamente igual que teffects

teffects ra (__dy__ $xvar) (experimental) if year==1975, atet

*** IPW (creo que puse AIPW en la version que te envie) es:

*logit experimental $xvar if year==1975 
*predict pscore

*Pesos
sum experimental
local wgtmn=r(mean)
gen wgt111=experimental/`wgtmn'
gen wgt000=pscore*(1-experimental)/(1-pscore)/`wgtmn'

** efecto

gen att3=(wgt111-wgt000)*(__dy__)
sum att3 if year==1975

** Standard IPW se puede repiclar con teffects
replace __dy__=__dy__/100
teffects ipw (__dy__ ) (experimental $xvar) if year==1975, atet

** Cuando pueda te envio los resultados para panel.

** Ahora bien para hacer various de estos, como lo hace "DID" lo que estoy haciendo es 
** ejecutar DRDID por acada subsample

sysuse mpdta, clear
/*

. csdid  lemp lpop , ivar(countyreal) time(year) gvar(first_treat) 
Callaway Sant'Anna (2021)
------------------------------------------------------------------------------
             | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
g2004        |
 t_2003_2004 |  -.0145329   .0221602    -0.66   0.512     -.057966    .0289002
 t_2003_2005 |  -.0764267   .0287098    -2.66   0.008    -.1326969   -.0201566
 t_2003_2006 |  -.1404536   .0354269    -3.96   0.000     -.209889   -.0710183
 t_2003_2007 |  -.1069093   .0329364    -3.25   0.001    -.1714634   -.0423551
-------------+----------------------------------------------------------------
g2006        |
 t_2003_2004 |  -.0006112   .0222299    -0.03   0.978    -.0441809    .0429586
 t_2004_2005 |   -.006267   .0185075    -0.34   0.735     -.042541    .0300071
 t_2005_2006 |   .0009473    .019409     0.05   0.961    -.0370936    .0389883
 t_2005_2007 |  -.0413123   .0197454    -2.09   0.036    -.0800126   -.0026119
-------------+----------------------------------------------------------------
g2007        |
 t_2003_2004 |   .0266993   .0140788     1.90   0.058    -.0008947    .0542933
 t_2004_2005 |  -.0045906    .015728    -0.29   0.770    -.0354169    .0262357
 t_2005_2006 |  -.0284515   .0181982    -1.56   0.118    -.0641193    .0072163
 t_2006_2007 |  -.0287821   .0162518    -1.77   0.077     -.060635    .0030709
------------------------------------------------------------------------------
*/

** Por ejemplo esto replica los prim
drdid lemp lpop if inlist(year,2003,2004) & inlist(first_treat,0,2004), ivar(countyreal) time(year) tr(first_treat)
drdid lemp lpop if inlist(year,2003,2005) & inlist(first_treat,0,2004), ivar(countyreal) time(year) tr(first_treat)
drdid lemp lpop if inlist(year,2003,2006) & inlist(first_treat,0,2004), ivar(countyreal) time(year) tr(first_treat)
drdid lemp lpop if inlist(year,2003,2007) & inlist(first_treat,0,2004), ivar(countyreal) time(year) tr(first_treat)

**En este sentido se usarian muestras distintas para cada regression.

