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
							[notyet] 		/// att_gt basic option. May prepare others as Post estimation
							[method(str) bal(str) ]  // This allows other estimators
	marksample touse
	** First determine outcome and xvars
	gettoken y xvar:varlist
	markout `touse' `ivar' `time' `gvar' `y' `xvar'

	** determine time0
	if "`time0'"=="" {
	    qui:sum `time' if `touse'
		local time0 `r(min)'
	}
	
	** Check if panel is Full Balance
	qui {
	    // Only if panel
	    if "`ivar'"!="" {
			tempvar x1 x2
			bysort `touse' `ivar':gen `x1'=_N if `touse'
			qui:sum `x1'
			local mxcol = `r(max)'
			*bysort `touse' `time':gen `x2'=_N if `touse'
			*noisily tab `x1'
			if `r(min)'<`r(max)' {
			    display in red "Panel is not balanced"
				if "`bal'"=="full" {
					display in red "Will use Only observations fully balanced (Max periods observed)"
					replace `touse'=0 if `x1'<`mxcol'
				}
				if "`bal'"=="" {
					display in red "Will use observations with Pair balanced (observed at t0 and t1)"
				}
				if "`bal'"=="unbal" {
				    //to me added
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
		    foreach j of local tlev {
				local mydots=`mydots'+1
				sdots, mydots(`mydots')
				
				* Stata quirk: `notyet' is called `tyet' because "no" is removed
			    if "`tyet'"=="" {
				    ** This implements the Never treated
					local time1 = min(`i'-1, `j'-1)
					qui:capture:drdid `varlist' if inlist(`gvar',0,`i') & inlist(`time',`time1',`j') & `touse' [`weight'`exp'], ///
										ivar(`ivar') time(`time') treatment(`tr') `method' stub(__) replace
*					matrix `b'=nullmat(`b'),e(b)
*					matrix `v'=nullmat(`v'),e(V)
					local eqname `eqname' g`i'
					local colname `colname'  t_`time1'_`j'
					capture drop _g`i'_`time1'_`j'
					
				    capture   confirm variable __att
				
					if 	_rc==111	qui:gen _g`i'_`time1'_`j'=.
					else 		ren __att    _g`i'_`time1'_`j'
					local vlabrif `vlabrif' _g`i'_`time1'_`j'
					
				}
				else if "`tyet'"!="" {
				    ** This will implement not yet treated.////////////////////
					//////////////////////////////////////
					qui:replace `tr'=`gvar'==`i' if `touse'
					local time1 = min(`i'-1, `j'-1)
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
				}
				local rifvar `rifvar' _g`i'_`time1'_`j'
			}
		}
		** names for Weights
		foreach i of local glev {
			local eqname `eqname' wgt
			local colname `colname'  w`i'
		}
		** Here we do the asymptotic	
		preserve
			tempvar wgtt
			if "`exp'"!="" clonevar `wgtt'`exp'
			else gen byte `wgtt'=1
			qui:keep if `touse'
			qui:keep `ivar' `time' `gvar' `vlabrif' `wgtt' 
			if "`ivar'"=="" {
			    tempvar ivar
				qui:gen double `ivar'=_n
			}
			collapse `time' `gvar' `vlabrif' `wgtt', by(`ivar')
			qui:tab `gvar', gen(gvar_)
			qui:count if `gvar'==0
			if r(N)>0 	mata:makerif("`vlabrif'","gvar_*","`wgtt'","`b'","`v'")
			else 		mata:makerif("`vlabrif'","`gvar' gvar_*","`wgtt'","`b'","`v'")
		restore
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
	ereturn local rif 		`rifvar'
	ereturn local ggroup 	`gvar'
	ereturn local id	 	`ivar'
	
	if  "`tyet'"=="" ereturn local control_group "Never Treated"
	if  "`tyet'"!="" ereturn local control_group "Not yet Treated"
	display _n "Callaway and Sant'Anna (2021)"
	ereturn display
	display "Control: `e(control_group)'" 
end 

/// This can be used for aggregation. Creates the matrixes we need.
mata:
 void makerif(string scalar att_gt_ , pg_ , wgt_, b, V){	
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
	VV=quadcross(all,all)/rows(all)^2
	st_matrix(b,mean_y)
	st_matrix(V,VV)
}

end

