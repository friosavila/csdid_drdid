{smcl}


{marker drdid-doubly-robust-difference-in-differences-estimators}{...}
{title:{cmd:drdid} Doubly Robust Difference-in-Differences Estimators}


{marker syntax}{...}
{title:Syntax}

{p 8 15 2} {cmd:csdid} {depvar} [{indepvars}] {ifin} {cmd:,} {opth ivar(varname)} {opth time(varname)} {opth treatment(varname)}{p_end}


{marker options}{...}
{title:Options}

{synoptset tabbed}{...}
{synopthdr:Option}
{synoptline}
{synopt:{bf:ivar}}Variable indexing groups, e.g., {it:country}{p_end}
{synopt:{bf:time}}Variable indexing time, e.g., {it:year}{p_end}
{synopt:{bf:treatment}}Dummy variable indicating treatment, e.g., {it:reform}{p_end}
{synoptline}


{marker models}{...}
{title:Models}


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


{marker authors-1}{...}
{dlgtab:Authors}

{text}{phang2}Fernando Rios-Avila (Levy Economics Institute of Bard College), {it:maintainer}{p_end}
{phang2}Asjad Naqvi (International Institute for Applied Systems Analysis){p_end}



{marker contributors}{...}
{dlgtab:Contributors}

{text}{phang2}Miklós Koren (Central European University){p_end}
{phang2}Pedro H. C. Sant'Anna (Vanderbilt University){p_end}



{marker license-and-citation}{...}
{title:License and Citation}

{pstd}You are free to use this package under the terms of its {browse "LICENSE":license}. If you use it, please cite {it:both} the original article and the software package in your work:{p_end}

{text}{phang2}Sant’Anna, Pedro H. C., and Jun Zhao. 2020a. “Doubly Robust Difference-in-Differences Estimators.” {it:Journal of Econometrics} 219 (1): 101–22.{p_end}
{phang2}Rios-Avila, Fernando, Asjad Naqvi (authors), Miklós Koren and Pedro H. C. Sant'Anna (contributors). 2021. “DRDID: Doubly Robust Difference-in-Differences Estimators for Stata.” [Software] Available at {browse "https://github.com/friosavila/csdid_drdid/":https://github.com/friosavila/csdid_drdid/}{p_end}



{marker references}{...}
{title:References}

{text}{phang2}Abadie, Alberto. 2005. “Semiparametric Difference-in-Differences Estimators.” {it:The Review of Economic Studies} 72 (1): 1–19.{p_end}
{phang2}Sant’Anna, Pedro H. C., and Jun Zhao. 2020a. “Doubly Robust Difference-in-Differences Estimators.” {it:Journal of Econometrics} 219 (1): 101–22.{p_end}
{phang2}Sant’Anna, Pedro H. C., and Jun Zhao. 2020b. “DRDID: Doubly Robust Difference-in-Differences Estimators.” [Software] Available at {browse "https://cran.r-project.org/package=DRDID":https://cran.r-project.org/package=DRDID}{p_end}
