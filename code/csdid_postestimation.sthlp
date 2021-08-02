{smcl}

{title:{cmd:csdid postestimation}: Post-estimation utilities for CSDID}

{it:{bf:Aggregations and Pretrend testing}}

There are two commands that can be used as post estimation tools. These are {cmd:csdid_estat} and {cmd:csdid_stats}.
Both can be used to obtain similar statistics. The first one, {cmd:csdid_estat}, works when using 
{cmd: estat}, after the model estimation via {help csdid}. 

The second one {csdid_stats} works in a similar way but when using the "saved" RIF file. It can be used to produced 
wild Bootstrap SE.

Below the syntax for both commands are discussed.

{marker syntax}{...}
{title:Syntax}

{cmd:estat} [subcommand], [options]
 
{cmd:csdid_stats} [subcommand], [options]

{marker subcommands}{...}
{title:Subcommands}
{synoptset 20 tabbed}{...}

{synopthdr:Subcommands}
{synoptline}
{synopt :{opt pretrend}}Estimates the chi2 statistic of the null hypothesis that ALL pretreatment ATTGT's are 
statistically equal to zero.{p_end}
 
Aggregation subcommands.
 
{synopt:{opt simple}}Estimates the ATT for all groups across all periods. {p_end}

{synopt:{opt group}}Estimates the ATT for each group or cohort, over all periods {p_end}

{synopt:{opt calendar}}Estimates the ATT for each period, across all groups or cohorts {p_end}

{synopt:{opt event}}Estimates the dynamic ATT's. ATT's are estimated using all period relative to the 
period of first treatment, across all cohorts.{p_end}

{synopt:{opt event, window(#1 #2)}}Same as above, but request only events between #1 and #2 to be estimated. 
Not available when using csdid_stats.{p_end}

{synopt:{opt attgt}}Produces the ATTGT's. Use when recovering results from rif file.{p_end}

{synopthdr:options}
{synoptline}
{synopt:{opt estore(name)}}When using any of the 4 types of aggregations, request storing the outcome in memory as {it:name}{p_end}

{synopt:{opt esave(name)}}When using any of the 4 types of aggregations, request saving the outcome in disk. {p_end}

{synopt:{opt replace}}Request to replace {it:ster} file, if the a file already exists.{p_end}
{synoptline}

{syntab:{bf: Standard Error Options}}

{phang}By default, {cmd:csdid_estat} and {cmd:csdid_stats} produce asymptotic standard errors. {p_end}

{phang}Using {cmd:csdid_estat} or {cmd: estat} {it:subcommand} always produces asymptotic standard errors, even if {help csdid} 
was estimated requesting Wbootstrap standard errors. {p_end}

{phang}{cmd:csdid_stats} can produce Wbootstrap standard if requested, using the following options:

{synopthdr:SE options}
{synoptline}

{synopt:wboot}Request Estimation of Standard errors using a multiplicative WildBootstrap procedure.
The default uses 999 repetitions using mammen approach. {p_end}

{synopt:reps(#)}Specifies the number of repetitions to be used for the Estimaton of the WBoot SE. Default is 999 {p_end}

{synopt:wtype(type)}Specifies the type of Wildbootstrap procedure. The default is "mammen", but "rademacher" is also 
avilable.{p_end}

{synopt:rseed(#)}Specifies the seed for the WB procedure. Use for replication purposes.{p_end}

{synoptline}


{title:{cmd:csdid_plot}: Plots after csdid, csdid_estat and csdid_stats}

{cmd:csdid} also comes with its own command to produce simple plots for all aggregations. It automatically recognizes last 
estimated results left by {cmd: csdid}, {cmd: csdid_estat} and {cmd: csdid_stats}, to produce the corresponding plots.

{synopthdr}
{synoptline}

{marker syntax}{...}
{title:Syntax}

{phang}{cmd:csdid_plot}, [options]

{synopthdr:Plot options}
{synoptline}

{synopt:style(styleoption)} Allows you to change the style of the plot. The options are rspike (default), rarea, rcap and rbar.{p_end}

{synopt:title(str)}Sets title for the constructed figure{p_end}

{synopt:xtitle(str)}Sets title for horizontal axis{p_end}

{synopt:ytitle(str)}Sets title for vertical axis axis{p_end}

{synopt:name(str)}Request storing a graph in memory under {it:name}{p_end}
 
{synopt:group(#)}When using {cmd:csdid_plot} after {csdid} or after {cmd:csdid_stats attgt}, one can produce dynamic type
plots for each group/cohort. In that case, one needs to indicate which {it:group(#)} to plot.

{marker remarks}{...}
{title:Remarks}

{pstd}
When using panel data, the estimator does not require data to be strongly balance. However, when estimating each ATTGT,
only observations that are balance within a specific 2x2 designed are used for the estimator. You will see a warning 
if something like this is detected in the data.
{p_end}
{pstd}
This approach is in contrast with the default approach in R's DID. When unbalanced data exists, the default is to 
estimate the model using Repeated Crossection estimators. See the example below constrasting both approaches.
{p_end}
{pstd}
Even if WBootstrap SE are requested, asymtotic SE are in e().

 
{marker examples}{...}
{title:Examples}

{phang}
{stata "use https://friosavila.github.io/playingwithstata/drdid/mpdta.dta, clear"}

{pstd}Estimation of all ATTGT's using Doubly Robust IPW (DRIPW) estimation method {p_end}

{phang}
{stata csdid  lemp lpop , ivar(countyreal) time(year) gvar(first_treat) method(dripw)}

{pstd}Estimation of all ATTGT's using Doubly Robust IPW (DRIPW) estimation method, with Wildbootstrap SE {p_end}

{phang}
{stata csdid  lemp lpop , ivar(countyreal) time(year) gvar(first_treat) method(dripw) wboot rseed(1)}

{pstd}Repeated crosssection estimator with Wildbootstrap SE{p_end}

{phang}
{stata csdid  lemp lpop , time(year) gvar(first_treat) method(dripw) wboot rseed(1)}

{pstd}Estimation of all Dynamic effects using Doubly Robust IPW (DRIPW) estimation method, with Wildbootstrap SE {p_end}

{phang}
{stata csdid  lemp lpop , ivar(countyreal) time(year) gvar(first_treat) method(dripw) wboot rseed(1) agg(event)}

{pstd}Estimation of all Dynamic effects using Doubly Robust IPW (DRIPW) estimation method, with Wildbootstrap SE, 
and not-yet treated observations as controls {p_end}

{phang}
{stata csdid  lemp lpop , ivar(countyreal) time(year) gvar(first_treat) method(dripw) wboot rseed(1) agg(event) notyet}

{pstd}Estimation of ATTGT's assuming unbalance panel data, with panel estimators {p_end}

{phang}
{stata set seed 1}{p_end}
{phang}
{stata gen sample = runiform()<.9}{p_end}
{phang}
{stata csdid  lemp lpop  if sample==1, ivar(countyreal) time(year) gvar(first_treat) method(dripw) }{p_end}

{pstd}Estimation of ATTGT's assuming unbalance panel data, with repeated crossection estimators, but clustered SE{p_end}

{phang}
{stata csdid  lemp lpop  if sample==1, cluster(countyreal) time(year) gvar(first_treat) method(dripw) }

{marker authors}{...}
{title:Authors}


{pstd}
Fernando Rios-Avila{break}
Levy Economics Institute of Bard College{break}
Annandale-on-Hudson, NY{break}
friosavi@levy.org

{pstd}Pedro H. C. Sant'Anna {break}
Vanderbilt University{p_end}

{marker references}{...}
{title:References}

{phang2}Abadie, Alberto. 2005. 
"Semiparametric Difference-in-Differences Estimators." 
{it:The Review of Economic Studies} 72 (1): 1–19.{p_end}

{phang2}Sant’Anna, Pedro H. C., and Jun Zhao. 2020. 
"Doubly Robust Difference-in-Differences Estimators." 
{it:Journal of Econometrics} 219 (1): 101–22.{p_end}

{phang2}Rios-Avila, Fernando, 
and Pedro H. C. Sant'Anna 2021.
 “CSDID: Difference-in-Differences with Multiple periods.” 
{p_end}

{marker aknowledgement}{...}
{title:Aknowledgement}

{pstd}This command was built using the DID command from R as benchmark, originally written by Pedro Sant'Anna and Brantly Callaway. 
Many thanks to Pedro for helping understanding the inner workings on the estimator.{p_end}

{pstd}Thanks to Enrique, who helped with the displaying set up{p_end}

{title:Also see}

{p 7 14 2}
Help:  {help drdid}, {help csrdid}, {help csdid postesimation}, {help xtdidregress} {p_end}


