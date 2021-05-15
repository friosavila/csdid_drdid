# `drdid` Doubly Robust Difference-in-Differences Estimators

# Syntax

{p 8 15 2} {cmd:csdid} {depvar} [{indepvars}] {ifin} {cmd:,} {opth ivar(varname)} {opth time(varname)} {opth treatment(varname)} 

# Options

Option | Description
-------|------------
**ivar**   | Variable indexing groups, e.g., *country*
**time**   | Variable indexing time, e.g., *year*
**treatment** | Dummy variable indicating treatment, e.g., *reform*

# Models
## DR DiD with IPT and WLS
Sant’Anna and Zhao (2020a) Improved doubly robust DiD estimator based on inverse probability of tilting and weighted least squares
## DR DiD with IPW and OLS
Sant’Anna and Zhao (2020a) doubly robust DiD estimator based on stabilized inverse probability weighting and ordinary least squares
## DiD with IPW
Abadie (2005) inverse probability weighting DiD estimator
## DiD with OR
Outcome regression DiD estimator based on ordinary least squares
## DiD with stabilized IPW
Abadie (2005) inverse probability weighting DiD estimator with stabilized weights

# Authors
## Authors
- Fernando Rios-Avila (Levy Economics Institute of Bard College), *maintainer*
- Asjad Naqvi (International Institute for Applied Systems Analysis)

## Contributors
- Miklós Koren (Central European University)
- Pedro H. C. Sant'Anna (Vanderbilt University)

# License and Citation
You are free to use this package under the terms of its [license](LICENSE). If you use it, please cite *both* the original article and the software package in your work:

- Sant’Anna, Pedro H. C., and Jun Zhao. 2020a. “Doubly Robust Difference-in-Differences Estimators.” *Journal of Econometrics* 219 (1): 101–22.
- Rios-Avila, Fernando, Asjad Naqvi (authors), Miklós Koren and Pedro H. C. Sant'Anna (contributors). 2021. “DRDID: Doubly Robust Difference-in-Differences Estimators for Stata.” [Software] Available at https://github.com/friosavila/csdid_drdid/

# References
- Abadie, Alberto. 2005. “Semiparametric Difference-in-Differences Estimators.” *The Review of Economic Studies* 72 (1): 1–19.
- Sant’Anna, Pedro H. C., and Jun Zhao. 2020a. “Doubly Robust Difference-in-Differences Estimators.” *Journal of Econometrics* 219 (1): 101–22.
- Sant’Anna, Pedro H. C., and Jun Zhao. 2020b. “DRDID: Doubly Robust Difference-in-Differences Estimators.” [Software] Available at https://cran.r-project.org/package=DRDID