* v0.2 by FRA csdid or Multiple periods did. Adds Notyet
* v0.1 by FRA mpdid or Multiple periods did.
* This version implements did::attgp
* Logic. Estimate the ATT of the base (first) year against all subsequent years
* using data BY groups
** assumes all years are available. For now
capture program drop csdid
program csdid, eclass
	syntax varlist(fv ) [if] [in] [iw], /// Basic syntax  allows for weights
	ivar(varname) time(varname) gvar(varname) [att_gt] [notyet] /// att_gt basic option. May prepare others as Post estimation
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
					qui:drdid `varlist' if inlist(`gvar',0,`i') & inlist(`time',`time1',`j'), ivar(`ivar') time(`time') treatment(`tr') `method' stub(__) replace
					matrix `b'=nullmat(`b'),e(b)
					matrix `v'=nullmat(`v'),e(V)
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
					qui:drdid `varlist' if (`gvar'==0 | `gvar'==`i' | `gvar'> `j') & inlist(`time',`time1',`j'), ivar(`ivar') time(`time') treatment(`tr') `method' stub(__) replace
					matrix `b'=nullmat(`b'),e(b)
					matrix `v'=nullmat(`v'),e(V)
					local eqname `eqname' g`i'
					local colname `colname'  t_`time1'_`j'
					capture drop _g`i'_`time1'_`j'
				    ren __att    _g`i'_`time1'_`j'
					local vlabrif `vlabrif' _g`i'_`time1'_`j'
				}
			}
		}
		matrix `v'=diag(`v')
		matrix colname `b'=`colname'
		matrix coleq   `b'=`eqname'
		matrix colname `v'=`colname'
		matrix coleq   `v'=`eqname'
		matrix rowname `v'=`colname'
		matrix roweq   `v'=`eqname'
	}
	*** Mata to put all together.
	
	ereturn post `b' `v'
	ereturn local cmd csdid
	ereturn local cmdline csdid `0'
	if  "`tyet'"=="" ereturn local control_group "Never Treated"
	if  "`tyet'"!="" ereturn local control_group "Not yet Treated"
	display "Callaway Sant'Anna (2021)"
	ereturn display
	display "Control: `e(control_group)'" 
end 

/// This can be used for aggregation. Creates the matrixes we need.
/*mata:
///mata drop makerif()
void makerif(string scalar yxvar){	
	real matrix y, info
	y=st_data(.,yxvar)
	y=sort(y,1)	
	info=panelsetup(y,1)
	_editmissing(y,0)
	y=panelsum(y,info)
	variance(y)/rows(y)
	
}

end
*/
