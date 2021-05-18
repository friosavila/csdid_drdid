{smcl}


{marker drdid-doubly-robust-difference-in-differences-estimators}{...}
{title:{cmd:drdid} Doubly Robust Difference-in-Differences Estimators}


{marker syntax}{...}
{title:Syntax}

{text}{phang2}{cmd:csdid} {it:depvar} [{it:indepvars}] [{it:if}] [{it:in}] [{it:iweight}], [{bf:ivar}({it:varname})] {bf:time}({it:varname}) {bf:TReatment}({it:varname}) [{bf:noisily} {it:method} {bf:rc1} {bf:boot} {bf:reps}({it:int})]{p_end}



{marker options}{...}
{title:Options}


{marker parameters}{...}
{dlgtab:Parameters}

{synoptset tabbed}{...}
{synopthdr:Parameter}
{synoptline}
{synopt:{bf:ivar}}Variable indexing groups, e.g., {it:country}{p_end}
{synopt:{bf:time}}Variable indexing time, e.g., {it:year}{p_end}
{synopt:{bf:treatment}}Dummy variable indicating treatment, e.g., {it:reform}{p_end}
{synoptline}


{marker methods}{...}
{dlgtab:Methods}

{pstd}{it:method} is one of{p_end}

{synoptset tabbed}{...}
{synopthdr:Method}
{synoptline}
{synopt:{bf:drimp} (default)}Sant’Anna and Zhao (2020a) Improved doubly robust DiD estimator based on inverse probability of tilting and weighted least squares{p_end}
{synopt:{bf:dripw}}Sant’Anna and Zhao (2020a) doubly robust DiD estimator based on stabilized inverse probability weighting and ordinary least squares{p_end}
{synopt:{bf:reg}}Outcome regression DiD estimator based on ordinary least squares{p_end}
{synopt:{bf:stdipw}}Abadie (2005) inverse probability weighting DiD estimator with stabilized weights{p_end}
{synopt:{bf:aipw}}Abadie (2005) inverse probability weighting DiD estimator{p_end}
{synopt:{bf:ipwra}}Inverse-probability-weighted regression adjustment{p_end}
{synopt:{bf:all}}Compute all of the above{p_end}
{synoptline}


{marker options-1}{...}
{dlgtab:Options}

{synoptset tabbed}{...}
{synopthdr:Option}
{synoptline}
{synopt:{bf:rc1}}Data is repeated cross section (default is panel){p_end}
{synopt:{bf:boot}}Bootstrapped standard errors{p_end}
{synopt:{bf:reps}({it:int})}{it:int} number of bootstrap repetitions{p_end}
{synoptline}


{marker examples}{...}
{title:Examples}

{phang2}{cmd}. sysuse lalonde, clear


{pstd}Panel estimator with default {bf:drimp} method{p_end}

{phang2}{cmd}. drdid re age educ black married nodegree hisp re74 if treated==0 | sample==2, ivar(id) time(year) tr(experimental)  


{pstd}Repeated cross section{p_end}

{phang2}{cmd}. drdid re age educ black married nodegree hisp re74 if treated==0 | sample==2, time(year) tr(experimental)



{marker authors}{...}
{title:Authors}

{text}{phang2}Fernando Rios-Avila (Levy Economics Institute of Bard College), {it:maintainer}{p_end}
{phang2}Asjad Naqvi (International Institute for Applied Systems Analysis){p_end}
{phang2}Pedro H. C. Sant'Anna (Vanderbilt University){p_end}



{marker license-and-citation}{...}
{title:License and Citation}

{pstd}You are free to use this package under the terms of its {browse "LICENSE":license}. If you use it, please cite {it:both} the original article and the software package in your work:{p_end}

{text}{phang2}Sant’Anna, Pedro H. C., and Jun Zhao. 2020a. “Doubly Robust Difference-in-Differences Estimators.” {it:Journal of Econometrics} 219 (1): 101–22.{p_end}
{phang2}Rios-Avila, Fernando, Asjad Naqvi and Pedro H. C. Sant'Anna. 2021. “DRDID: Doubly Robust Difference-in-Differences Estimators for Stata.” [Software] Available at {browse "https://github.com/friosavila/csdid_drdid/tree/v0.1":https://github.com/friosavila/csdid_drdid/tree/v0.1}{p_end}



{marker references}{...}
{title:References}

{text}{phang2}Abadie, Alberto. 2005. “Semiparametric Difference-in-Differences Estimators.” {it:The Review of Economic Studies} 72 (1): 1–19.{p_end}
{phang2}Sant’Anna, Pedro H. C., and Jun Zhao. 2020a. “Doubly Robust Difference-in-Differences Estimators.” {it:Journal of Econometrics} 219 (1): 101–22.{p_end}
{phang2}Sant’Anna, Pedro H. C., and Jun Zhao. 2020b. “DRDID: Doubly Robust Difference-in-Differences Estimators.” [Software] Available at {browse "https://cran.r-project.org/package=DRDID":https://cran.r-project.org/package=DRDID}{p_end}
