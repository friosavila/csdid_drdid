** NOTE when Panel is unbalanced (check this somehow.)
** there could be two solutions.
** 1 Using strong balance 
** 2 use semi balance (whenever att_gt exists)
** 3 use weak balance/crossection with cluster.

*! v1.03 by FRA. Adding Balance checks
*! v1.02 by FRA. added touse
*! v1.01 by FRA. Make sure we have at least 1 not treated period.
// and check that if no Never treated exist, we add extra variable for dummies.
// exclude if There are no treated observations
* v1 by FRA csdid Added all tests! and ready to play
* v0.2 by FRA csdid or Multiple periods did. Adds Notyet

* v0.1 by FRA mpdid or Multiple periods did.
* This version implements did::attgp
* Logic. Estimate the ATT of the base (first) year against all subsequent years
* using data BY groups
** assumes all years are available. For now
 
/*program csdid_check,
syntax varlist(fv ) [if] [in] [iw], /// Basic syntax  allows for weights
										[ivar(varname)]  ///
										time(varname)    ///
										[gvar(varname)]  /// Ppl either declare gvar
										[trvar(varname)] /// or declare treat var, and we create gvar. Only works if Panel data
										[att_gt]  ///
										[notyet] /// att_gt basic option. May prepare others as Post estimation
										[method(str) ]  // This allows other estimators
	
end*/
*capture program drop sdots
*capture program drop csdid
program sdots
syntax , [mydots(integer 10) maxdots(int 50)]
	if mod(`mydots',`maxdots')==0 {
		display "." 
	}
	else {
		display "." _c
	}
end

program csdid, sortpreserve eclass
	syntax varlist(fv ) [if] [in] [iw], 	/// Basic syntax  allows for weights
							[ivar(varname)] ///
							time(varname)   ///
							gvar(varname)  	/// Ppl either declare gvar
							[cluster(varname)] /// 
							[notyet] 		/// att_gt basic option. May prepare others as Post estimation
							[saverif(name) replace ]    ///
							[method(str) bal(str)  ]  // This allows other estimators
	marksample touse
	** First determine outcome and xvars
	gettoken y xvar:varlist
	markout `touse' `ivar' `time' `gvar' `y' `xvar' `cluster'

	** Confirm if new file exists
	if "`saverif'"!="" {
	    capture confirm new file "`saverif'.dta"
		if _rc!=0 {
			if "`replace'"=="" {
			    display in red "File `saverif'.dta already exists"
				display in red "Please use a different file name or use -replace-"
				exit 602
			}
			else {
			    display "File `saverif'.dta will be replaced"
			}
		}
		else {
		    display "File `saverif'.dta will be used to save all RIFs"
		}
	}
	
	** determine time0
	if "`time0'"=="" {
	    qui:sum `time' if `touse'
		local time0 `r(min)'
	}
	
	** Check if panel is Full Balance
	qui {
	    // Only if panel
	    if "`ivar'"!="" {
			** First check if data is Panel
			tempname ispan
			mata:ispanel("`ivar' `time'", "`touse'", "`ispan'") 
			if scalar(`ispan')>1 {
				display in red 	"{p}Repeated time values within panel `ivar'{p_end}" _n ///
								"{p}You may want to use Repeated crosssection estimators {p_end}"
				exit 451
			}
			
			tempname isbal
			mata:isbalanced("`ivar'","`touse'","`isbal'")

			if scalar(`isbal')!=1 {
			    display in red "Panel is not balanced"
				if "`bal'"=="full" {
					display in red "Will use Only observations fully balanced (Max periods observed)"
					replace `touse'=0 if `x1'<`mxcol'
				}
				if "`bal'"=="" {
					display in red "Will use observations with Pair balanced (observed at t0 and t1)"
				}
				if "`bal'"=="unbal" {
					display in red "Will use all observations (as if CS)"
					local cluster `ivar'
					local ivar    
				}
			}	
		}
	}
	
	** prepare loops over gvar.
	*local att_gt att_gt
	tempvar tr
	qui:gen byte `tr'=`gvar'!=0 if `gvar'!=.
	
	qui:levelsof `gvar' if `gvar'>0       & `touse', local(glev)
	qui:levelsof `time' if `time'>`time0' & `touse', local(tlev)
	
	** Checks If Gvar is ever untreated
	if `:word 1 of `glev'' < `:word 1 of `tlev'' {
	    display in red "All observations require at least 1 not treated period"
		display in red "See cross table below, and verify All Gvar have at least 1 not treated period"
		tab `time' `gvar' if `touse'
		error 1
	}
 		tempname b v
 		foreach i of local glev {		
			local time1 = `time0'
 
		    foreach j of local tlev {
				local mydots=`mydots'+1
				sdots, mydots(`mydots')
				* Stata quirk: `notyet' is called `tyet' because "no" is removed
			    if "`tyet'"=="" {
				    ** This implements the Never treated
					///local time1 = `min(`i'-1, `j'-1)'
					*display "inlist(`time',`time1',`j')"		
					qui:capture:drdid `varlist' if inlist(`gvar',0,`i') ///
														 & inlist(`time',`time1',`j') ///
														 & `touse' [`weight'`exp'], ///
														ivar(`ivar') time(`time') treatment(`tr') ///
														`method' stub(__) replace
												
					*else 		local time1 = `j'
*					matrix `b'=nullmat(`b'),e(b)
*					matrix `v'=nullmat(`v'),e(V)
					local eqname `eqname' g`i'
					local colname `colname'  t_`time1'_`j'
					capture drop _g`i'_`time1'_`j'
					
				    capture   confirm variable __att
				
					if 	_rc==111	qui:gen _g`i'_`time1'_`j'=.
					else 		ren __att    _g`i'_`time1'_`j'
					local vlabrif `vlabrif' _g`i'_`time1'_`j'
					if `j'<`i' local time1 = `j'
				}
				else if "`tyet'"!="" {
				    ** This will implement not yet treated.////////////////////
					//////////////////////////////////////
					qui:replace `tr'=`gvar'==`i' if `touse'
					*local time1 = min(`i'-1, `j'-1)
					* Use as controls those never treated and those not treated by time `j'>`i'
					qui:capture:drdid `varlist' if (`gvar'==0 | `gvar'==`i' | `gvar'> `j') & inlist(`time',`time1',`j') & `touse' [`weight'`exp'], ///
										ivar(`ivar') time(`time') treatment(`tr') `method' stub(__) replace
*					matrix `b'=nullmat(`b'),e(b)
*					matrix `v'=nullmat(`v'),e(V)
					
					local eqname `eqname' g`i'
					local colname `colname'  t_`time1'_`j'
					capture drop _g`i'_`time1'_`j'					
				    capture confirm variable __att
					if 	_rc==111	qui:gen _g`i'_`time1'_`j'=.
					else 			ren __att    _g`i'_`time1'_`j'
					local vlabrif `vlabrif' _g`i'_`time1'_`j'
					if `j'<`i' local time1 = `j'	
				}
				local rifvar `rifvar' _g`i'_`time1'_`j'
			}
		}
		** names for Weights
		foreach i of local glev {
			local eqname `eqname' wgt
			local colname `colname'  w`i'
		}
////////////////////////////////////////////////////////////////////////////////
		preserve
			tempvar wgtt
			if "`exp'"!="" clonevar `wgtt'`exp'
			else gen byte `wgtt'=1
			qui:keep if `touse'
			qui:keep `ivar' `time' `gvar' `vlabrif' `wgtt' `cluster'
			if "`ivar'"=="" {
			    tempvar ivar
				qui:gen double `ivar'=_n
			}
			collapse `time' `gvar' `vlabrif' `wgtt' `cluster', by(`ivar') fast
			
			ren `wgtt' __wgt__
			label var  __wgt__  "Weight Variable"
			qui:levelsof `gvar', local(gglev) 
			foreach i of local gglev {
				qui:gen byte gvar_`i'=`gvar'==`i'
			}
			qui:count if `gvar'==0
			if r(N)>0 	noisily mata:makerif("`vlabrif'","       gvar_*","__wgt__","`b'","`v'","`cluster' ")
			else 		noisily mata:makerif("`vlabrif'","`gvar' gvar_*","__wgt__","`b'","`v'","`cluster' ")
			/// saving RIF
			note: Data created with -csdid-. Contains all -RIFs- associated with model estimation. 
			note: Command use: csdid `0'
			if "`saverif'"!="" {
			    save `saverif', replace
			}
		restore
		capture drop `vlabrif'
////////////////////////////////////////////////////////////////////////////////
		matrix colname `b'=`colname'
		matrix coleq   `b'=`eqname'
		matrix colname `v'=`colname'
		matrix coleq   `v'=`eqname'
		matrix rowname `v'=`colname'
		matrix roweq   `v'=`eqname'
	*
	*** Mata to put all together.
 
	ereturn post `b' `v'
	ereturn local cmd 		csdid
	ereturn local cmdline 	csdid `0'
	ereturn local estat_cmd csdid_estat
	ereturn local glev 		`glev'
	ereturn local tlev 		`tlev'
	ereturn local time0		`time0'
	ereturn local rif 		`rifvar'
	ereturn local ggroup 	`gvar'
	ereturn local id	 	`ivar'
	ereturn local riffile	`saverif'
	/// Add here Cluster var and number of Clusters.
	if  "`tyet'"=="" ereturn local control_group "Never Treated"
	if  "`tyet'"!="" ereturn local control_group "Not yet Treated"
	display _n "Callaway and Sant'Anna (2021)"
	ereturn display
	display "Control: `e(control_group)'" 
end 

/// This can be used for aggregation. Creates the matrixes we need.
mata:
 void makerif(string scalar att_gt_ , pg_ , wgt_, b, V, clv){	
    real matrix att_gt, pg, all, wgt
	att_gt	= st_data(.,att_gt_)
	pg    	= st_data(.,pg_)
	wgt   	= st_data(.,wgt_)
	wgt	  	= wgt:/mean(wgt)
	pg	  	= pg[,2..cols(pg)]:*wgt
 	pg		= pg:/rowsum(mean(pg))
	/// pg here is just a dummy
	// stp1 all together
	all=att_gt,pg
	// stp2 get Mean(RIF) 
	real matrix mean_y
	mean_y=colsum(all):/colnonmissing(all)
	_editmissing(mean_y,0)
	// stp3 Exp factor
	real matrix exp_factor
	exp_factor = (rows(all):/colnonmissing(all))
	// stp4 RIF -> IF
	all=all:-mean_y
	// make missing zeros
	_editmissing(all,0)
	_editmissing(exp_factor,0)
	all=all:*exp_factor
 
	// estimate Variance Covariance assuming SUper normal
	real matrix VV
	st_matrix(b,mean_y)
	
	if (clv==" ") {	
		VV=quadcross(all,all)/rows(all)^2
	}
	else {
		real scalar cln
		real matrix clvar
		clvar=st_data(.,clv)
		clusterse(all,clvar,VV,cln)
	}
	st_matrix(V,VV)
}

void clusterse(real matrix iiff, cl, V, real scalar cln){
    /// estimates Clustered Standard errors
    real matrix ord, xcros, ifp, info, vv 
	//1st get the IFS and CL variable. 
	//iiff = st_data(.,rif,touse)
	//cl   = st_data(.,clvar,touse)
	// order and sort them, Make sure E(IF) is zero.
	ord  = order(cl,1)
	//iiff = iiff:-mean(iiff)
	iiff = iiff[ord,]
	cl   = cl[ord,]
	// check how I cleaned data!
	info  = panelsetup(cl,1)
	// faster Cluster? Need to do this for mmqreg
	ifp   = panelsum(iiff,info)
	xcros = quadcross(ifp,ifp)
	real scalar nt, nc
	nt=rows(iiff)
	nc=rows(info)
	V =	xcros/(nt^2)
	cln=nc
	//*nc/(nc-1)
	//st_matrix(V,    vv)
	//st_numscalar(ncl, nc)
	//        ^     ^
	//        |     |
	//      stata   mata
}

void isbalanced(string ivar, touse, isbal) {
    real matrix xx, info
	xx= st_data(.,ivar,touse)
	xx=sort(xx,1)
	info=panelsetup(xx,1)
	info=info[,2]:-info[,1]:+1
	st_numscalar(isbal,max(info)==min(info))
}

void ispanel(string itvar, touse, ispan) {
    real matrix xx, info
	xx= st_data(.,itvar,touse)
	info=uniqrows(xx,1)[,3]
	st_numscalar(ispan,max(info))
}

end

