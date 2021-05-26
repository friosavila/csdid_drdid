cscript
use lalonde, clear
local xvar age educ black married nodegree hisp re74

drdid re if treated==0 | sample==2,   time(year) tr( experimental )  all
drdid re if treated==0 | sample==2, ivar(id)  time(year) tr( experimental )  all


drdid re `xvar' if treated==0 | sample==2,   time(year) tr( experimental )  all
drdid re `xvar' if treated==0 | sample==2, ivar(id)  time(year) tr( experimental )  all

/*
Outcome
. use lalonde, clear

. local xvar age educ black married nodegree hisp re74

. 
. drdid re if treated==0 | sample==2,   time(year) tr( experimental )  all

Doubly robust difference-in-differences estimator summary
------------------------------------------------------------------------------
             | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
ATET         |
       dripw |    867.509   389.1652     2.23   0.026     104.7593    1630.259
   dripw_rc1 |    867.509   389.1652     2.23   0.026     104.7593    1630.259
       drimp |    867.509   389.1652     2.23   0.026     104.7593    1630.259
   drimp_rc1 |    867.509   389.1652     2.23   0.026     104.7593    1630.259
         reg |    867.509   389.1652     2.23   0.026     104.7593    1630.259
         ipw |    867.509   491.6271     1.76   0.078    -96.06245     1831.08
      stdipw |    867.509   389.1652     2.23   0.026     104.7593    1630.259
------------------------------------------------------------------------------
Note: This table is provided for comparison across estimations only. You cannot
use it to compare estimates across different estimators
dripw :Doubly Robust IPW
drimp :Doubly Robust Improved estimator
reg   :Outcome regression or Regression augmented estimator
ipw   :Abadie(2005) IPW estimator
stdipw:Standardized IPW estimator
sipwra:IPW and Regression adjustment estimator.

. drdid re if treated==0 | sample==2, ivar(id)  time(year) tr( experimental )  
> all

Doubly robust difference-in-differences estimator summary
------------------------------------------------------------------------------
             | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
ATET         |
       dripw |    867.509   329.9863     2.63   0.009     220.7477     1514.27
       drimp |    867.509   329.9863     2.63   0.009     220.7477     1514.27
         reg |    867.509   329.9863     2.63   0.009     220.7477     1514.27
         ipw |    867.509   329.9863     2.63   0.009     220.7477     1514.27
      stdipw |    867.509   329.9863     2.63   0.009     220.7477     1514.27
      sipwra |    867.509   329.9863     2.63   0.009     220.7477     1514.27
------------------------------------------------------------------------------
Note: This table is provided for comparison across estimations only. You cannot
use it to compare estimates across different estimators
dripw :Doubly Robust IPW
drimp :Doubly Robust Improved estimator
reg   :Outcome regression or Regression augmented estimator
ipw   :Abadie(2005) IPW estimator
stdipw:Standardized IPW estimator
sipwra:IPW and Regression adjustment estimator.

. 
. 
. drdid re `xvar' if treated==0 | sample==2,   time(year) tr( experimental )  a
> ll

Doubly robust difference-in-differences estimator summary
------------------------------------------------------------------------------
             | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
ATET         |
       dripw |  -871.3272   410.2751    -2.12   0.034    -1675.452   -67.20269
   dripw_rc1 |  -871.3272   435.0661    -2.00   0.045    -1724.041   -18.61333
       drimp |  -901.2703   408.3107    -2.21   0.027    -1701.545    -100.996
   drimp_rc1 |  -901.2703   434.3043    -2.08   0.038    -1752.491   -50.04955
         reg |  -1300.645   418.5023    -3.11   0.002    -2120.894   -480.3951
         ipw |  -1107.872   619.4393    -1.79   0.074    -2321.951    106.2068
      stdipw |  -1021.609    495.464    -2.06   0.039    -1992.701   -50.51784
------------------------------------------------------------------------------
Note: This table is provided for comparison across estimations only. You cannot
use it to compare estimates across different estimators
dripw :Doubly Robust IPW
drimp :Doubly Robust Improved estimator
reg   :Outcome regression or Regression augmented estimator
ipw   :Abadie(2005) IPW estimator
stdipw:Standardized IPW estimator
sipwra:IPW and Regression adjustment estimator.

. drdid re `xvar' if treated==0 | sample==2, ivar(id)  time(year) tr( experimen
> tal )  all

Doubly robust difference-in-differences estimator summary
------------------------------------------------------------------------------
             | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
ATET         |
       dripw |  -871.3272   396.0211    -2.20   0.028    -1647.514   -95.14008
       drimp |  -901.2703   393.6127    -2.29   0.022    -1672.737   -129.8037
         reg |  -1300.645   349.8259    -3.72   0.000    -1986.291   -614.9985
         ipw |  -1107.872   408.6127    -2.71   0.007    -1908.738   -307.0058
      stdipw |  -1021.609   397.5201    -2.57   0.010    -1800.735   -242.4845
      sipwra |  -908.2912   393.8673    -2.31   0.021    -1680.257   -136.3255
------------------------------------------------------------------------------
Note: This table is provided for comparison across estimations only. You cannot
use it to compare estimates across different estimators
dripw :Doubly Robust IPW
drimp :Doubly Robust Improved estimator
reg   :Outcome regression or Regression augmented estimator
ipw   :Abadie(2005) IPW estimator
stdipw:Standardized IPW estimator
sipwra:IPW and Regression adjustment estimator.

*/