{smcl}


{marker csdid-difference-in-differences-with-multiple-time-periods}{...}
{title:{cmd:csdid} Difference in differences with multiple time periods}


{marker syntax}{...}
{title:Syntax}

{p 8 15 2} {cmd:csdid} {depvar} [{indepvars}] {ifin} {cmd:,} {opth ivar(varname)} {opth time(varname)} {opth treatment(varname)}{p_end}


{marker options}{...}
{title:Options}


{marker dr-did-with-ipt-and-wls}{...}
{dlgtab:DR DiD with IPT and WLS}

{pstd}Sant’Anna and Zhao (2020a) Improved doubly robust DiD estimator based on inverse probability of tilting and weighted least squares{p_end}


{marker dr-did-with-ipw-and-ols}{...}
{dlgtab:DR DiD with IPW and OLS}

{pstd}Sant’Anna and Zhao (2020a) doubly robust DiD estimator based on stabilized inverse probability weighting and ordinary least squares{p_end}


{marker did-with-ipw}{...}
{dlgtab:DiD with IPW}

{pstd}Abadie (2005) inverse probability weighting DiD estimator{p_end}


{marker did-with-or}{...}
{dlgtab:DiD with OR}

{pstd}Outcome regression DiD estimator based on ordinary least squares{p_end}


{marker did-with-stabilized-ipw}{...}
{dlgtab:DiD with stabilized IPW}

{pstd}Abadie (2005) inverse probability weighting DiD estimator with stabilized weights{p_end}


{marker authors}{...}
{title:Authors}


{marker references}{...}
{title:References}

{text}{phang2}Abadie, Alberto. 2005. “Semiparametric Difference-in-Differences Estimators.” {it:The Review of Economic Studies} 72 (1): 1–19.{p_end}
{phang2}Sant’Anna, Pedro H. C., and Jun Zhao. 2020a. “Doubly Robust Difference-in-Differences Estimators.” {it:Journal of Econometrics} 219 (1): 101–22.{p_end}
{phang2}Sant’Anna, Pedro H. C., and Jun Zhao. 2020b. “DRDID: Doubly Robust Difference-in-Differences Estimators.” [Software] Available at {browse "https://cran.r-project.org/package=DRDID":https://cran.r-project.org/package=DRDID}{p_end}
