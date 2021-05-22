* v0.2 by FRA csdid or Multiple periods did. Adds Notyet
* v0.1 by FRA mpdid or Multiple periods did.
* This version implements did::attgp
* Logic. Estimate the ATT of the base (first) year against all subsequent years
* using data BY groups
** assumes all years are available. For now
capture program drop csdid
program csdid, eclass
	syntax varlist(fv ) [if] [in] [iw], /// Basic syntax  allows for weights
										ivar(varname) ///
										time(varname)  ///
										gvar(varname)  ///
										[att_gt]  ///
										[notyet] /// att_gt basic option. May prepare others as Post estimation
										[method(str) ]  // This allows other estimators
	marksample touse
	markout `touse' `ivar' `time' `gvar'
	** First determine outcome and xvars
	gettoken y xvar:varlist
	** determine time0
	if "`time0'"=="" {
	    qui:sum `time' if `touse'
		local time0 `r(min)'
	}
	** prepare loops over gvar.
	local att_gt att_gt
	tempvar tr
	qui:gen byte `tr'=`gvar'!=0 if `gvar'!=.
	if "`att_gt'"!="" {
	    
		qui:levelsof `gvar' if `gvar'>0       & `touse', local(glev)
		qui:levelsof `time' if `time'>`time0' & `touse', local(tlev)
		
		tempname b v
 		foreach i of local glev {		
		    foreach j of local tlev {
				* Stata quirk: `notyet' is called `tyet' because "no" is removed
			    if "`tyet'"=="" {
				    ** This implements the Never treated
					local time1 = min(`i'-1, `j'-1)
					qui:drdid `varlist' if inlist(`gvar',0,`i') & inlist(`time',`time1',`j') [`weight'`exp'], ///
										ivar(`ivar') time(`time') treatment(`tr') `method' stub(__) replace
*					matrix `b'=nullmat(`b'),e(b)
*					matrix `v'=nullmat(`v'),e(V)
					local eqname `eqname' g`i'
					local colname `colname'  t_`time1'_`j'
					capture drop _g`i'_`time1'_`j'
					ren __att    _g`i'_`time1'_`j'
					local vlabrif `vlabrif' _g`i'_`time1'_`j'
				}
				else if "`tyet'"!="" {
				    ** This will implement not yet treated.
					qui:replace `tr'=`gvar'==`i' if `touse'
					local time1 = min(`i'-1, `j'-1)
					* Use as controls those never treated and those not treated by time `j'>`i'
					qui:drdid `varlist' if (`gvar'==0 | `gvar'==`i' | `gvar'> `j') & inlist(`time',`time1',`j') [`weight'`exp'], ///
										ivar(`ivar') time(`time') treatment(`tr') `method' stub(__) replace
*					matrix `b'=nullmat(`b'),e(b)
*					matrix `v'=nullmat(`v'),e(V)
					local eqname `eqname' g`i'
					local colname `colname'  t_`time1'_`j'
					capture drop _g`i'_`time1'_`j'
				    ren __att    _g`i'_`time1'_`j'
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
			*mata:makerif("_g2004_2003_2004 _g2004_2003_2005 _g2004_2003_2006 _g2004_2003_2007 _g2006_2003_2004 _g2006_2004_2005 _g2006_2005_2006 _g2006_2005_2007 _g2007_2003_2004 _g2007_2004_2005 _g2007_2005_2006 _g2007_2006_2007","i.first","wgt","b","V")
			mata:makerif("`vlabrif'","i.`gvar'","`wgtt'","`b'","`v'")
		restore
		
		matrix colname `b'=`colname'
		matrix coleq   `b'=`eqname'
		matrix colname `v'=`colname'
		matrix coleq   `v'=`eqname'
		matrix rowname `v'=`colname'
		matrix roweq   `v'=`eqname'
	}
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
	display "Callaway Sant'Anna (2021)"
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
	// stp3 Exp factor
	real matrix exp_factor
	exp_factor = (rows(all):/colnonmissing(all))
	// stp4 RIF -> IF
	all=all:-mean_y
	// make missing zeros
	_editmissing(all,0)
	all=all:*exp_factor
	// estimate Variance Covariance assuming SUper normal
	real matrix VV
	VV=quadcross(all,all)/rows(all)^2
	st_matrix(b,mean_y)
	st_matrix(V,VV)
}

end

