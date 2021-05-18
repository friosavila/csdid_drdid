# `drdid` Doubly Robust Difference-in-Differences Estimators

# Syntax

- `csdid` *depvar* [*indepvars*] [*if*] [*in*] [*iweight*], [**ivar**(*varname*)] **time**(*varname*) **TReatment**(*varname*) [**noisily** *method*  **rc1** **boot** **reps**(*int*)]

# Options
## Parameters
Parameter | Description
-------|------------
**ivar**   | Variable indexing groups, e.g., *country*
**time**   | Variable indexing time, e.g., *year*
**treatment** | Dummy variable indicating treatment, e.g., *reform*

## Methods
*method* is one of

Method | Description
------|------------
**drimp** (default) | Sant’Anna and Zhao (2020a) Improved doubly robust DiD estimator based on inverse probability of tilting and weighted least squares
**dripw** | Sant’Anna and Zhao (2020a) doubly robust DiD estimator based on stabilized inverse probability weighting and ordinary least squares
**reg** | Outcome regression DiD estimator based on ordinary least squares
**stdipw** | Abadie (2005) inverse probability weighting DiD estimator with stabilized weights
**aipw** | Abadie (2005) inverse probability weighting DiD estimator
**ipwra** |  Inverse-probability-weighted regression adjustment
**all** | Compute all of the above 

## Options
Option | Description
-------|------------
**rc1** | Data is repeated cross section (default is panel)
**boot** | Bootstrapped standard errors
**reps**(*int*) | *int* number of bootstrap repetitions

# Examples
```
sysuse lalonde, clear
```
Panel estimator with default **drimp** method
```
drdid re age educ black married nodegree hisp re74 if treated==0 | sample==2, ivar(id) time(year) tr(experimental)  
```
Repeated cross section
```
drdid re age educ black married nodegree hisp re74 if treated==0 | sample==2, time(year) tr(experimental)
```

# Authors
- Fernando Rios-Avila (Levy Economics Institute of Bard College), *maintainer*
- Asjad Naqvi (International Institute for Applied Systems Analysis)
- Pedro H. C. Sant'Anna (Vanderbilt University)

# License and Citation
You are free to use this package under the terms of its [license](LICENSE). If you use it, please cite *both* the original article and the software package in your work:

- Sant’Anna, Pedro H. C., and Jun Zhao. 2020a. “Doubly Robust Difference-in-Differences Estimators.” *Journal of Econometrics* 219 (1): 101–22.
- Rios-Avila, Fernando, Asjad Naqvi and Pedro H. C. Sant'Anna. 2021. “DRDID: Doubly Robust Difference-in-Differences Estimators for Stata.” [Software] Available at https://github.com/friosavila/csdid_drdid/tree/v0.1

# References
- Abadie, Alberto. 2005. “Semiparametric Difference-in-Differences Estimators.” *The Review of Economic Studies* 72 (1): 1–19.
- Sant’Anna, Pedro H. C., and Jun Zhao. 2020a. “Doubly Robust Difference-in-Differences Estimators.” *Journal of Econometrics* 219 (1): 101–22.
- Sant’Anna, Pedro H. C., and Jun Zhao. 2020b. “DRDID: Doubly Robust Difference-in-Differences Estimators.” [Software] Available at https://cran.r-project.org/package=DRDID