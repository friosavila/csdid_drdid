** Goal. Make the estimator modular. That way other options can be added
*! v1.2 DRDID for Stata by FRA All Estimators are ready For panel and RC
* Next help!
* v1.0 DRDID for Stata by FRA All Estimators but IPWRA have are available for panel
* Need to add weights. 
* v0.8 DRDID for Stata by FRA Other estimators are available. Onlyone missing iwp panel
* v0.7 DRDID for Stata by FRA IPW estimator for panel (Asjad original Rep)
* v0.5 DRDID for Stata by FRA Incorporates RC1 and RC2 estimators
* v0.2 DRDID for Stata by FRA Fixes typo with tag
* v0.2 DRDID for Stata by FRA Allows for Factor notation
* v0.1 DRDID for Stata by FRA Typo with ID TIME
* For panel only for now

capture program drop _all

program define drdid, eclass sortpreserve
	syntax varlist(fv ) [if] [in] [iw], [ivar(varname)] time(varname) TReatment(varname) ///
	[noisily drimp dripw reg stdipw aipw ipwra all  rc1]  
	local 00 `0'
	marksample touse
	markout `touse' `ivar' `time' `treatment'

	** Which option 
	if "`drimp'`dripw'`reg'`stdipw'`aipw'`ipwra'`all'"=="" {
	    display "No estimator selected. Using default -drimp-"
		local drimp drimp
	}
	else {
	    if `:word count `drimp' `dripw' `reg' `stdipw' `aipw' `ipwra' `all' '!=1 {
		    display "Only one option allowed, more than 1 selected."
			error 1
		}
	}
	** First determine outcome and xvars
	gettoken y xvar:varlist
	** Sanity Checks for Time. Only 2 values
	tempvar vals
	qui:bysort `touse' `time': gen byte `vals' = (_n == 1) * `touse'
	su `vals' if `touse', meanonly 
	if  r(sum)!=2 {
	    display in red "Time variable can only have 2 values in the working sample"
		error 1
	}
	else {
		tempvar tmt
		qui:egen byte `tmt'=group(`time') if `touse'
		qui:replace `tmt'=`tmt'-1	    
	}
	** Sainity Check Weights
	** Weights
	if "`exp'"=="" {
	    tempname wgt
		gen byte `wgt'=1
	}
	else {
		tempvar wgt
		gen double `wgt'`exp'
		sum `wgt' if `touse' & `tmt'==0, meanonly
		replace `wgt'=`wgt'/r(mean)
	}
	
	
	drop `vals'
	qui:bysort `touse' `treatment': gen byte `vals' = (_n == 1) * `touse'
	su `vals' if `touse', meanonly
 
	if  r(sum)!=2 {
	    display in red "Treatment variable can only have 2 values in the working sample"
		error 1
	}
	else {
		tempvar trt
		qui:egen byte `trt'=group(`treatment') if `touse'
		qui:replace `trt'=`trt'-1
	}
	**# for panel estimator
	tempvar tag
	qui:bysort `touse' `ivar' (`time'):gen byte `tag'=_n if `touse'
	** Default will be IPT 
 	if "`drimp'"!="" {
		drdid_imp , touse(`touse') tmt(`tmt') trt(`trt') y(`y') xvar(`xvar') `isily' ivar(`ivar') tag(`tag') weight(`wgt')
	}
	else if "`dripw'"!="" {
		// DR ipw asjad
		drdid_dripw , touse(`touse') tmt(`tmt') trt(`trt') y(`y') xvar(`xvar') `isily' ivar(`ivar') tag(`tag') weight(`wgt')
	}
	else if "`aipw'"!="" {
		// abadies Done
		drdid_aipw , touse(`touse') tmt(`tmt') trt(`trt') y(`y') xvar(`xvar') `isily' ivar(`ivar') tag(`tag') weight(`wgt')
	}
	else if "`reg'"!="" {
		drdid_reg , touse(`touse') tmt(`tmt') trt(`trt') y(`y') xvar(`xvar') `isily' ivar(`ivar') tag(`tag') weight(`wgt')
	}
	else if "`stdipw'"!="" {
		drdid_stdipw , touse(`touse') tmt(`tmt') trt(`trt') y(`y') xvar(`xvar') `isily' ivar(`ivar') tag(`tag') weight(`wgt')
	}
	else if "`ipwra'"!="" {
		//only one without modeling
		drdid_sipwra , touse(`touse') tmt(`tmt') trt(`trt') y(`y') xvar(`xvar') `isily' ivar(`ivar') tag(`tag') weight(`wgt')
	}
	
	else if "`all'"!="" {
	** DR 		
		tempvar bb VV
	    qui:drdid_dripw , touse(`touse') tmt(`tmt') trt(`trt') y(`y') xvar(`xvar') `isily' ivar(`ivar') tag(`tag') weight(`wgt')
		matrix `bb' = nullmat(`bb')\e(b)
		matrix `VV' = nullmat(`VV')\e(V)
		local clname dripw
		if "`ivar'"=="" {
		    qui:drdid_dripw , touse(`touse') tmt(`tmt') trt(`trt') y(`y') xvar(`xvar') `isily' ivar(`ivar') tag(`tag') weight(`wgt') rc1
			matrix `bb' = nullmat(`bb')\e(b)
			matrix `VV' = nullmat(`VV')\e(V)
			local clname `clname' dripw_rc1
		}
	** DRIMP	
	    qui:drdid_imp , touse(`touse') tmt(`tmt') trt(`trt') y(`y') xvar(`xvar') `isily' ivar(`ivar') tag(`tag') weight(`wgt')
		matrix `bb' = nullmat(`bb')\e(b)
		matrix `VV' = nullmat(`VV')\e(V)
		local clname `clname' drimp
		
		if "`ivar'"=="" {
		    qui:drdid_imp , touse(`touse') tmt(`tmt') trt(`trt') y(`y') xvar(`xvar') `isily' ivar(`ivar') tag(`tag') weight(`wgt') rc1
			matrix `bb' = nullmat(`bb')\e(b)
			matrix `VV' = nullmat(`VV')\e(V)
			local clname `clname' drimp_rc1
		}
	** REG
		qui:drdid_reg , touse(`touse') tmt(`tmt') trt(`trt') y(`y') xvar(`xvar') `isily' ivar(`ivar') tag(`tag') weight(`wgt')
		matrix `bb' = nullmat(`bb')\e(b)
		matrix `VV' = nullmat(`VV')\e(V)
		local clname `clname' reg
	** TRAD_IPW	
	    qui:drdid_aipw , touse(`touse') tmt(`tmt') trt(`trt') y(`y') xvar(`xvar') `isily' ivar(`ivar') tag(`tag') weight(`wgt')
		matrix `bb' = nullmat(`bb')\e(b)
		matrix `VV' = nullmat(`VV')\e(V)
		local clname `clname' aipw
	** STD IPW	
		qui:drdid_stdipw , touse(`touse') tmt(`tmt') trt(`trt') y(`y') xvar(`xvar') `isily' ivar(`ivar') tag(`tag') weight(`wgt')
		matrix `bb' = nullmat(`bb')\e(b)
		matrix `VV' = nullmat(`VV')\e(V)
		local clname `clname' stdipw
		if "`ivar'"!="" {
			display "NOT DRDID: DID with Standard IPW with RA"
			qui:drdid_sipwra , touse(`touse') tmt(`tmt') trt(`trt') y(`y') xvar(`xvar') `isily' ivar(`ivar') tag(`tag') weight(`wgt')
			matrix `bb' = nullmat(`bb')\e(b)
			matrix `VV' = nullmat(`VV')\e(V)
			local clname `clname' sipwra
		}
		matrix `bb'=`bb''
		matrix colname `bb' = `clname'
		
		matrix `VV'=diag(`VV')
		matrix colname `VV' = `clname'		
		matrix rowname `VV' = `clname'
		ereturn post `bb' `VV'
		ereturn display
	}
	
	ereturn local cmd drdid
	ereturn local cmdline drdid `00'
	ereturn local method  `drimp'`dripw'`reg'`stdipw'`aipw'`ipwra'`all'
	ereturn local method2 `drimp'`dripw'`reg'`stdipw'`aipw'`ipwra'`all'
	

end

**# Abadies
program define drdid_aipw, eclass
syntax, touse(str) trt(str) y(str) [xvar(str)] [noisily] [ivar(str)] [tag(str)] tmt(str) [weight(str)]
	** PS
	if "`ivar'"!="" {
	    *display "Estimating IPW logit"
		qui {		
			`isily' logit `trt' `xvar' if `touse' [iw = `weight']
			tempvar psxb
			predict double `psxb', xb
			tempname psb psV
			matrix `psb'=e(b)
			matrix `psV'=e(V)
			** _delta
			capture drop __dy__
			bysort `touse' `ivar' (`tmt'):gen double __dy__=`y'[2]-`y'[1] if `touse'
			** Reg for outcome 
			*`isily' reg __dy__ `xvar' if `trt'==0 
			*tempname regb regV
			*matrix `regb'=e(b)
			*matrix `regV'=e(V)
			tempvar xb
			*predict double `xb'
			capture drop __att__
			gen double __att__=.

		    tempname b V
			mata:ipw_abadie_panel("__dy__","`xvar'","`xb'","`psb' ","`psV' ","`psxb'","`trt'","`tmt'","`touse'","__att__","`b'","`V'","`weight'")
			matrix colname `b'=__att__
			matrix colname `V'=__att__
			matrix rowname `V'=__att__
			ereturn post `b' `V'
			local att1    =`=_b[__att__]'
			local attvar1 =`=_se[__att__]'^2
			ereturn scalar att1    =`att1'
			ereturn scalar attvar1 =`attvar1'
			ereturn matrix ipwb `psb'
			ereturn matrix ipwV `psV'
		}
		display "DiD with IPW"
		display "Abadie (2005) inverse probability weighting DiD estimator"
		ereturn display
	}
	else if "`ivar'"=="" {
	    qui {
			`isily' logit `trt' `xvar' if `touse' [iw = `weight']
			tempvar psxb
			predict double `psxb', xb
			tempname psb psV
			matrix `psb'=e(b)
			matrix `psV'=e(V)
		    tempname b V
			capture drop __att__
			gen double __att__=.
			mata:ipw_abadie_rc("`y'","`xvar'","`tmt'","`trt'","`psV'","`psxb'","`weight'","`touse'","__att__","`b'","`V'")
			matrix colname `b' =__att__
			matrix colname `V' =__att__
			matrix rowname `V' =__att__
		}
		display "DiD with IPW"
		display "Abadie (2005) inverse probability weighting DiD estimator for RC"
		ereturn post `b' `V'
		local att1    =`=_b[__att__]'
		local attvar1 =`=_se[__att__]'^2
		ereturn scalar att1    =`att1'
		ereturn scalar attvar1 =`attvar1'
		ereturn display
		ereturn matrix ipwb `psb'
		ereturn matrix ipwV `psV'
	}
end

** can be more efficient
**#drdid_dripw
program define drdid_dripw, eclass
syntax, touse(str) trt(str) y(str) [xvar(str)] [noisily] [ivar(str)] [tag(str)] tmt(str) [weight(str) rc1]
	** PS
	if "`ivar'"!="" {
	    *display "Estimating IPW logit"
		qui {		
			`isily' logit `trt' `xvar' if `touse' [iw = `weight']
			tempvar psxb
			predict double `psxb', xb
			tempname psb psV
			matrix `psb'=e(b)
			matrix `psV'=e(V)
			** _delta
			capture drop __dy__
			bysort `touse' `ivar' (`tmt'):gen double __dy__=`y'[2]-`y'[1] if `touse'
			** Reg for outcome 
 
			`isily' reg __dy__ `xvar' if `trt'==0  [iw = `weight']
			tempname regb regV
			matrix `regb'=e(b)
			matrix `regV'=e(V)
			tempvar xb
			predict double `xb'
			capture drop __att__
			gen double __att__=.
 
		    tempname b V
			mata:drdid_panel("__dy__","`xvar'","`xb'","`psb'","`psV'","`psxb'","`trt'","`tmt'","`touse'","__att__","`b'","`V'","`weight'")
			matrix colname `b'=__att__
			matrix colname `V'=__att__
			matrix rowname `V'=__att__
			ereturn post `b' `V'
			local att1    =`=_b[__att__]'
			local attvar1 =`=_se[__att__]'^2
			ereturn scalar att1    =`att1'
			ereturn scalar attvar1 =`attvar1'
			ereturn matrix ipwb `psb'
			ereturn matrix ipwV `psV'
			ereturn matrix regb `regb'
			ereturn matrix regV `regV'

		}
		display "DR DiD with IPW and OLS"
		display "Sant'Anna and Zhao (2020)" _n "Doubly robust DiD estimator based on stabilized inverse probability weighting and ordinary least squares"
		ereturn display
	}
	else if "`ivar'"=="" {
	    qui {
		
			`isily' logit `trt' `xvar' if `touse' [iw = `weight']
			tempvar psxb
			predict double `psxb', xb
			tempname psb psV
			matrix `psb'=e(b)
			matrix `psV'=e(V)
		    tempname b V
			capture drop __att__
			gen double __att__=.
			**ols 
			tempvar y00 y01 y10 y11
			tempname regb00 regb01 regb10 regb11 
			tempname regV00 regV01 regV10 regV11
			`isily' reg `y' `xvar' if `trt'==0 & `tmt' ==0 [iw = `weight']
			predict double `y00'
			matrix `regb00'=e(b)
			matrix `regV00'=e(V)
			`isily' reg `y' `xvar' if `trt'==0 & `tmt' ==1 [iw = `weight']
			predict double `y01'
			matrix `regb01'=e(b)
			matrix `regV01'=e(V)
			`isily' reg `y' `xvar' if `trt'==1 & `tmt' ==0 [iw = `weight']
			predict double `y10'
			matrix `regb10'=e(b)
			matrix `regV10'=e(V)
			`isily' reg `y' `xvar' if `trt'==1 & `tmt' ==1 [iw = `weight']
			predict double `y11'
			matrix `regb11'=e(b)
			matrix `regV11'=e(V)
			if "`rc1'"=="" {
				mata:drdid_rc("`y'","`y00' `y01' `y10' `y11'","`xvar'","`tmt'","`trt'","`psV'","`psxb'","`weight'","`touse'","__att__","`b'","`V'")
			}
			else {
			    mata:drdid_rc1("`y'","`y00' `y01' `y10' `y11'","`xvar'","`tmt'","`trt'","`psV'","`psxb'","`weight'","`touse'","__att__","`b'","`V'")
				local nle "Not Locally efficient"
			}
			matrix colname `b' =__att__
			matrix colname `V' =__att__
			matrix rowname `V' =__att__			
		}
		display "DR DiD with IPW and OLS for Repeated Crossection: `nle'"
		display "Sant'Anna and Zhao (2020)" _n "Doubly robust DiD estimator based on stabilized inverse probability weighting and ordinary least squares"
		ereturn post `b' `V'
		ereturn display
		local att1    =`=_b[__att__]'
		local attvar1 =`=_se[__att__]'^2
		ereturn scalar att1    =`att1'
		ereturn scalar attvar1 =`attvar1'
 		ereturn matrix ipwb `psb'
		ereturn matrix ipwV `psV'
		
		ereturn matrix regb00 `regb00'
		ereturn matrix regV00 `regV00'
		ereturn matrix regb01 `regb01'
		ereturn matrix regV01 `regV01'
		ereturn matrix regb10 `regb10'
		ereturn matrix regV10 `regV10'
		ereturn matrix regb11 `regb11'
		ereturn matrix regV11 `regV11'
 
	}
end

**#drdid_reg
program define drdid_reg, eclass
syntax, touse(str) trt(str) y(str) [xvar(str)] [noisily] [ivar(str)] [tag(str)] tmt(str) [weight(str)]
** Simple application. But right now without RIF
	if "`ivar'"!="" {
		qui {
			capture drop __dy__
			bysort `touse' `ivar' (`tmt'):gen double __dy__=`y'[2]-`y'[1] if `touse' 
			`isily' reg __dy__ `xvar' if `trt'==0  [iw = `weight']
			tempvar xb
			predict double `xb'
			capture drop __att__
			gen double __att__=.
			//////////////////////
			tempname regb regV
			matrix `regb'=e(b)
			matrix `regV'=e(V)
			tempname b V
			mata:reg_panel("__dy__", "`xvar'", "`xb'" , "`trt'", "`tmt'" , "`touse'","__att__","`b'","`V'","`weight'") 
	 
			matrix colname `b' = __att__
			matrix colname `V' = __att__
			matrix rowname `V' = __att__
			ereturn post `b' `V'
			local att1    =`=_b[__att__]'
			local attvar1 =`=_se[__att__]'^2
			ereturn scalar att1    =`att1'
			ereturn scalar attvar1 =`attvar1'
			ereturn matrix regb `regb'
			ereturn matrix regV `regV' 
		}
		display "DiD with OR" _n "Outcome regression DiD estimator based on ordinary least squares"
		ereturn display
	}	
	else if "`ivar'"=="" {
		qui {
		    tempvar y00 y01
			tempname regb00 regb01 regV00 regV01
		    `isily' reg `y' `xvar' if `trt'==0 & `tmt' ==0 [iw = `weight']
			predict double `y00'
			matrix `regb00' = e(b)
			matrix `regV00' = e(V)
			`isily' reg `y' `xvar' if `trt'==0 & `tmt' ==1 [iw = `weight']
			predict double `y01'
			matrix `regb01' = e(b)
			matrix `regV01' = e(V)
			tempname b V
			capture drop __att__
			gen double __att__=.
			mata:reg_rc("`y'","`y00' `y01'","`xvar'","`tmt'","`trt'","`weight'","`touse'","__att__","`b'","`V'")
			matrix colname `b' =__att__
			matrix colname `V' =__att__
			matrix rowname `V' =__att__
			ereturn post `b' `V'
			ereturn matrix regb00 `regb00'
			ereturn matrix regV00 `regV00' 
			ereturn matrix regb01 `regb01'
			ereturn matrix regV01 `regV01'
			local att1    =`=_b[__att__]'
			local attvar1 =`=_se[__att__]'^2
			ereturn scalar att1    =`att1'
			ereturn scalar attvar1 =`attvar1'
		}
		display "DiD with OR for RC" _n "Outcome regression DiD estimator based on ordinary least squares"
		ereturn display
	}

end

**#drdid_sipw
program define drdid_stdipw, eclass
syntax, touse(str) trt(str) y(str) [xvar(str)] [noisily] [ivar(str)] [tag(str)] tmt(str) [weight(str)]
** Simple application. But right now without RIF
	if "`ivar'"!="" {
	    *display "Estimating IPW logit"
		qui {		
			`isily' logit `trt' `xvar' if `touse' [iw = `weight']
			tempvar psxb
			predict double `psxb', xb
			tempname psb psV
			matrix `psb'=e(b)
			matrix `psV'=e(V)
			** _delta
			capture drop __dy__
			bysort `touse' `ivar' (`tmt'):gen double __dy__=`y'[2]-`y'[1] if `touse'
			** Reg for outcome 
		}
		*display "Estimating Counterfactual Outcome"	
		qui {
			*`isily' reg __dy__ `xvar' if `trt'==0 
			*tempname regb regV
			*matrix `regb'=e(b)
			*matrix `regV'=e(V)
			tempvar xb
			*predict double `xb'
			capture drop __att__
			gen double __att__=.
		}
		*display "Estimating ATT"
		qui {
		    tempname b V		
			noisily mata:std_ipw_panel("__dy__","`xvar'","`xb'","`psb'","`psV'","`psxb'","`trt'","`tmt'","`touse'","__att__","`b'","`V'","`weight'")		
			matrix colname `b'=__att__
			matrix colname `V'=__att__
			matrix rowname `V'=__att__

		}
		display "DiD with stabilized IPW" _n "Abadie (2005) inverse probability weighting DiD estimator with stabilized weights" 
		ereturn post `b' `V'
		ereturn display
		local att1    =`=_b[__att__]'
		local attvar1 =`=_se[__att__]'^2
		ereturn scalar att1    =`att1'
		ereturn scalar attvar1 =`attvar1'
		ereturn matrix ipwb `psb'
		ereturn matrix ipwV `psV'
	}
	
	else if "`ivar'"=="" {
	    qui {
		    `isily' logit `trt' `xvar' if `touse' [iw = `weight']
			tempvar psxb
			predict double `psxb', xb
			tempname psb psV
			matrix `psb'=e(b)
			matrix `psV'=e(V)
			tempname b V
			capture drop __att__
			gen __att__=.
			mata:std_ipw_rc("`y'","`xvar'","`tmt'","`trt'","`psV'","`psxb'","`weight'","`touse'","__att__","`b'","`V'")
			matrix colname `b' =__att__
			matrix colname `V' =__att__
			matrix rowname `V' =__att__
		}
		
		display "DiD with stabilized IPW for RC" _n "Abadie (2005) inverse probability weighting DiD estimator with stabilized weights" 
		ereturn post `b' `V'
		ereturn display
		local att1    =`=_b[__att__]'
		local attvar1 =`=_se[__att__]'^2
		ereturn scalar att1    =`att1'
		ereturn scalar attvar1 =`attvar1'
		ereturn matrix ipwb `psb'
		ereturn matrix ipwV `psV'
	}
end

// only one without Mata writting. Consider working on it
**#drdid_sipwra
program define drdid_sipwra, eclass
syntax, touse(str) trt(str) y(str) [xvar(str)] [noisily] [ivar(str)] [tag(str)] tmt(str) [weight(str)]
** Simple application. But right now without RIF
   if "`ivar'"=="" {
       display "Estimator not implemented for RC"
	   exit
	   error 
   }
   else {
	qui {
		capture drop __dy__
		bysort `touse' `ivar' (`tmt'):gen double __dy__=`y'[2]-`y'[1] if `touse'
		tempvar sy
		sum __dy__ if  `touse'
		local scl = r(mean)
		gen double `sy'= __dy__/`scl'
		
		qui:teffects ipwra (`sy' `xvar') (`trt' `xvar', logit) if `touse' [iw = `weight'] , atet 
		tempname b V aux
		matrix `aux'=e(b)*`scl'
		matrix `b'=`aux'[1,1]
		matrix `aux'=e(V)*`scl'^2
		matrix `V'=`aux'[1,1]
		matrix colname `b' = __att__
		matrix colname `V' = __att__
		matrix rowname `V' = __att__
		ereturn post `b' `V'
	}
		ereturn display	
   }	
end
 
** Needs rewritting 
**#drdid_dript
program define drdid_imp, eclass sortpreserve
syntax, touse(str) trt(str) y(str) [xvar(str)] [noisily] [ivar(str)] [tag(str)] tmt(str) [weight(str) rc1]
	if "`ivar'"!="" {
	   	*display "Estimating IPT"
		qui {
			`isily' ml model lf drdid_logit (`trt'=`xvar') if `touse' [iw = `weight'], maximize  robust
			`isily' ml display
			tempname iptb iptV
			matrix `iptb'=e(b)
			matrix `iptV'=e(V)
			tempvar psxb
			predict double `psxb',xb
			** Determine dy and dyhat
			capture drop __dy__
			bysort `touse' `ivar' (`tmt'):gen double __dy__=`y'[2]-`y'[1] if `touse'

			** determine weights
			tempvar w0 
			gen double `w0' = ((logistic(`psxb')*(1-`trt')))/(1-logistic(`psxb'))*`weight'
			
			sum `w0' if `touse' , meanonly
			replace `w0'=`w0'/r(mean)
			
			** estimating dy_hat for a counterfactual
 	
			tempname regb regV
			`isily' reg __dy__ `xvar' [w=`w0'] if `trt'==0 & `tmt'==0,
			matrix `regb' =e(b)
			matrix `regV' =e(V)
			tempvar xb
			qui:predict double `xb'
			tempname b V
			capture drop __att__
			gen double __att__=.
			noisily mata:drdid_imp_panel("__dy__","`xvar'","`xb'","`psb'","`psV'","`psxb'","`trt'","`tmt'","`touse'","__att__","`b'","`V'","`weight'")		
			matrix colname `b'=__att__
			matrix colname `V'=__att__
			matrix rowname `V'=__att__
			ereturn post `b' `V'
			local att1    =`=_b[__att__]'
			local attvar1 =`=_se[__att__]'^2
			ereturn scalar att1    =`att1'
			ereturn scalar attvar1 =`attvar1'
			ereturn matrix ipwb `iptb'
			ereturn matrix ipwV `iptV'
			ereturn matrix regb `regb'
			ereturn matrix regV `regV'
		}
		display "DR DiD with IPT and WLS" _n "Sant'Anna and Zhao (2020) Improved doubly robust DiD estimator based on inverse probability of tilting and weighted least squares"
		ereturn display
	}
	else {
	**# for Crossection estimator    
		qui {
			`isily' ml model lf drdid_logit (`trt'=`xvar') if `touse' [w=`weight'] , maximize  robust
			`isily' ml display
			tempname iptb iptV
			matrix `iptb'=e(b)
			matrix `iptV'=e(V)
			tempvar psxb
			predict double `psxb', xb
			** outcomes
			tempvar w1 w0
			*gen double `w1' =    `trt'
			gen double `w0' = (1-`trt')*logistic(`psxb')/(1-logistic(`psxb'))
	
		    tempname regb00 regV00 regb01 regV01 regb10 regV10 regb11 regV11
			tempvar y01 y00 y10 y11
			`isily' reg `y' `xvar' [w=`w0'] if `trt'==0 & `tmt'==0,
			predict double `y00'
			matrix `regb00' =e(b)
			matrix `regV00' =e(V)
			`isily' reg `y' `xvar' [w=`w0'] if `trt'==0 & `tmt'==1,
			predict double `y01'
			matrix `regb01' =e(b)
			matrix `regV01' =e(V)
			`isily' reg `y' `xvar'  		   if `trt'==1 & `tmt'==0,
			predict double `y10'
			matrix `regb10' =e(b)
			matrix `regV10' =e(V)
			`isily' reg `y' `xvar'  		   if `trt'==1 & `tmt'==1,
			predict double `y11'
			matrix `regb11' =e(b)
			matrix `regV11' =e(V)
			capture drop __att__
			gen double __att__=.
			tempname b V
			
			if "`rc1'"=="" {
				mata:drdid_imp_rc("`y'","`y00' `y01' `y10' `y11'","`xvar'","`tmt'","`trt'","`iptV'","`psxb'","`weight'","`touse'","__att__","`b'","`V'")
			}
			else {
			    mata:drdid_imp_rc1("`y'","`y00' `y01' `y10' `y11'","`xvar'","`tmt'","`trt'","`iptV'","`psxb'","`weight'","`touse'","__att__","`b'","`V'")
				local nle "Not Locally efficient"
			}
			matrix colname `b'=__att__
			matrix colname `V'=__att__
			matrix rowname `V'=__att__
			ereturn post `b' `V'
		}
		
		display "DR DiD with IPT and WLS for OLS `nle'" _n "Sant'Anna and Zhao (2020) Improved doubly robust DiD estimator based on inverse probability of tilting and weighted least squares"
		ereturn display
		local att1    =`=_b[__att__]'
		local attvar1 =`=_se[__att__]'^2
		ereturn scalar att1    =`att1'
		ereturn scalar attvar1 =`attvar1'
		ereturn matrix iptb `iptb'
		ereturn matrix iptV `iptV'
		ereturn matrix regb00 `regb00'
		ereturn matrix regV00 `regV00'
		ereturn matrix regb01 `regb01'
		ereturn matrix regV01 `regV01'
		ereturn matrix regb10 `regb10'
		ereturn matrix regV10 `regV10'
		ereturn matrix regb11 `regb11'
		ereturn matrix regV11 `regV11'

	}
end
  
mata 
	////////////////////////////////////////////////////////////////////////////////////////////////
// dript
	void drdid_imp_panel(string scalar dy_, xvar_, xb_ , psb_,psV_,psxb_,trt_,tmt_,touse,att_,bb,VV,ww) {
	    real matrix dy, xvar, xb, psb, psv, psxb, trt, tmt
		// This code is based on Asjad Replication
		// Gather all data
		real scalar nn
		dy  =st_data(.,dy_  ,touse)
		nn=rows(dy)
		//st_view(xvar=.,xvar_,touse)
		xb=st_data(.,xb_,touse)
		psxb=st_data(.,psxb_,touse)
		real matrix psc
		psc=logistic(psxb)
		trt =st_data(.,trt_ ,touse)
		tmt =1:-st_data(.,tmt_ ,touse)
		// and matrices
		///psb =st_matrix(psb_ )
		///psv =st_matrix(psV_ )
		// for now assume weights = 1
		real matrix w
		w=st_data(.,ww,touse)
		real matrix w_1 , w_0, att, att_inf_func
		w_1 = w :* trt
		w_0 = w :* psc :* (1:-trt):/(1:-psc)
		w_1 = w_1:/mean(w_1)
		w_0 = w_0:/mean(w_0)
		att=(dy:-xb):*(w_1:-w_0)
		att_inf_func = mean(att,tmt) :+ att :- w_1:*mean(att,tmt)
		st_store(.,att_,touse, att_inf_func)	
		st_matrix(bb,mean(att_inf_func,tmt ))
		st_matrix(VV,variance(att_inf_func,tmt)/sum(tmt))
		
	}
 
	// standard IPW
  	void std_ipw_panel(string scalar dy_, xvar_, xb_ , psb_,psV_,psxb_,trt_,tmt_,touse,att_,bb,VV,ww) {
	    real matrix dy, xvar, xb, psb, psv, psxb, trt, tmt
 		// Gather all data
		real scalar nn
		dy  =st_data(.,dy_  ,touse)
		nn=rows(dy)
		xvar=st_data(.,xvar_,touse),J(rows(dy),1,1)
		//xb=st_data(.,xb_,touse)
		psxb=st_data(.,psxb_,touse)
		real matrix psc
		psc=logistic(psxb)
		trt =st_data(.,trt_ ,touse)
		tmt =st_data(.,tmt_ ,touse)
		// and matrices
		//psb =st_matrix(psb_ )
		psv =st_matrix(psV_ )
		// for now assume weights = 1
		real matrix w
		w=st_data(.,ww,touse)
		
		real matrix w_1, w_0, att_cont, att_treat,
					eta_treat, eta_cont, 
					lin_ps,  att_inf_func
			
		w_1= w :* trt
		w_0= w :* psc :* (1 :- trt):/(1 :- psc)
		att_treat = w_1:* dy
		att_cont  = w_0:* dy
		eta_treat = mean(att_treat)/mean(w_1)
		eta_cont  = mean(att_cont)/mean(w_0)
		ipw_att   = eta_treat :- eta_cont
		
		inf_treat = (att_treat :- w_1 :* eta_treat)/mean(w_1)
		inf_cont_1 = (att_cont :- (w_0 :* eta_cont))
		lin_ps = (w:* (trt :- psc) :* xvar)*(psv * nn)
		//M2 =
		inf_cont_2 = lin_ps * mean(w_0 :* (dy :- eta_cont) :* xvar)'
		inf_control = (inf_cont_1 :+ inf_cont_2)/mean(w_0)
		att_inf_func = mean(ipw_att):+inf_treat :- inf_control
 
		st_store(.,att_,touse, att_inf_func)	
		st_matrix(bb,mean(att_inf_func,tmt ))
		st_matrix(VV,variance(att_inf_func,tmt)/sum(tmt))
	}
  
	void reg_panel(string scalar dy_, xvar_, xb_ , trt_,tmt_,touse,att_,bb,VV,ww) {
	    real matrix dy, xvar, xb, trt, tmt
		// This code is based on Asjad Replication
		// Gather all data
		real scalar nn
		dy  =st_data(.,dy_  ,touse)
		nn=rows(dy)
		xvar=st_data(.,xvar_,touse),J(rows(dy),1,1)
		xb=st_data(.,xb_,touse)
		// psxb=st_data(.,psxb_,touse)
		// real matrix psc
		// psc=logistic(psxb)
		trt =st_data(.,trt_ ,touse)
		tmt =st_data(.,tmt_ ,touse)
		// and matrices
		// psb =st_matrix(psb_ )
		// psv =st_matrix(psV_ )
		// for now assume weights = 1
		real matrix w
		w=st_data(.,ww,touse)
		real matrix w_1, w_0, att_cont, att_treat,
					eta_treat, eta_cont, wols_x, wols_eX,
					lin_ols, att_inf_func
		
		w_1 = w :* trt
		w_0 = w :* trt
		att_treat = w_1:* dy
		att_cont  = w_0:* xb
		eta_treat = mean(att_treat):/mean(w_1)
		eta_cont  = mean(att_cont)  :/mean(w_0)
		reg_att = eta_treat :- eta_cont
		wols    = w :* (1 :- trt)
		wols_x  = wols :* xvar
		wols_eX = wols :* (dy:-xb) :* xvar
		
		XpX_inv = invsym(quadcross(wols_x, xvar))*nn
		lin_ols = wols_eX * XpX_inv
		inf_treat    = (att_treat :- w_1 * eta_treat):/mean(w_1)
		inf_cont_1   = (att_cont :- w_0 * eta_cont)
		inf_cont_2   = lin_ols * mean(w_0 :* xvar )'
		inf_control  = (inf_cont_1 :+ inf_cont_2):/mean(w_0)
		att_inf_func = mean(reg_att):+(inf_treat :- inf_control)
			
		st_store(.,att_,touse, att_inf_func)	
		st_matrix(bb,mean(att_inf_func,tmt ))
		st_matrix(VV,variance(att_inf_func,tmt)/sum(tmt))
	}
	
 
/////////////////////////////////////////////////////////////////////////////////////////////////	
// TIPW drdid_tipw
 	void ipw_abadie_panel(string scalar dy_, xvar_, xb_ , psb_,psV_,psxb_,trt_,tmt_,touse,att_,bb,VV,ww) {
	    real matrix dy, xvar, xb, psb, psv, psxb, trt, tmt
 		// Gather all data
		real scalar nn
		dy  =st_data(.,dy_  ,touse)
		nn=rows(dy)
		xvar=st_data(.,xvar_,touse),J(rows(dy),1,1)
		//xb=st_data(.,xb_,touse)
		psxb=st_data(.,psxb_,touse)
		real matrix psc
		psc=logistic(psxb)
		trt =st_data(.,trt_ ,touse)
		tmt =st_data(.,tmt_ ,touse)
		// and matrices
		psb =st_matrix(psb_ )
		psv =st_matrix(psV_ )
		// for now assume weights = 1
		real matrix w
		w=st_data(.,ww,touse)
		real matrix w_1, w_0, att_cont, att_treat,
					eta_treat, eta_cont, ipw_att,
					lin_ps, att_lin1, mom_logit, att_lin2, att_inf_func
					
		w_1= w :* trt
		w_0= w :* psc :* (1 :- trt):/(1 :- psc)
		att_treat = w_1:* dy
		att_cont  = w_0:* dy
		eta_treat = mean(att_treat)/mean(w_1)
		eta_cont  = mean(att_cont)/mean(w_1)
		ipw_att   = eta_treat - eta_cont
		lin_ps = (w:* (trt :- psc) :* xvar)*(psv * nn)
		att_lin1  = att_treat :- att_cont
		mom_logit = mean(att_cont  :* xvar)
		att_lin2  = lin_ps * mom_logit'
		att_inf_func = mean(ipw_att):+(att_lin1 :- att_lin2 :- w_1 :* ipw_att)/mean(w_1)
 		st_store(.,att_,touse, att_inf_func)	
		st_matrix(bb,mean(att_inf_func,tmt ))
		st_matrix(VV,variance(att_inf_func,tmt)/sum(tmt))
	}
/// drdid_ipw	
 	void drdid_panel(string scalar dy_, xvar_, xb_ , psb_,psV_,psxb_,trt_,tmt_,touse,att_,bb,VV,ww) {
	    real matrix dy, xvar, xb, psb, psv, psxb, trt, tmt
		// This code is based on Asjad Replication
		// Gather all data
		real scalar nn
		dy  =st_data(.,dy_  ,touse)
		nn=rows(dy)
		xvar=st_data(.,xvar_,touse),J(rows(dy),1,1)
		xb=st_data(.,xb_,touse)
		psxb=st_data(.,psxb_,touse)
		real matrix psc
		psc=logistic(psxb)
		trt =st_data(.,trt_ ,touse)
		tmt =st_data(.,tmt_ ,touse)
		// and matrices
		psb =st_matrix(psb_ )
		psv =st_matrix(psV_ )
		// for now assume weights = 1
		real matrix w
		w=st_data(.,ww,touse)
		
		// TRAD DRDID
		real matrix w_1, w_0 
		w_1 = (w:*trt)
		w_1 = w_1 /mean(w_1)
		w_0 = (w:*psc:*(-trt:+1):/(-psc:+1))
		w_0 = w_0 /mean(w_0 ) 
		// ATT
		real matrix dy_xb, att, w_ols, wols_eX,
					XpX_inv, lin_wols, lin_ps, 
					n1, n0, nest, a, rif
					
		dy_xb=dy:-xb
		att = mean((w_1:-w_0):*(dy_xb))
		
		// influence functions OLS
		w_ols 	 =    w :* (1 :- trt)
		wols_eX  = w_ols:* (dy_xb):* xvar
		XpX_inv  = invsym(quadcross(xvar,w_ols,xvar))*nn 
		lin_wols =  wols_eX * XpX_inv   
		// IF for logit
		lin_ps 	   = (w :* (trt:-psc) :* xvar) * (psv * nn)
		// Components for RIF
		n1   = w_1:*((dy_xb):-mean(dy_xb,w_1))
		n0   = w_0:*((dy_xb):-mean(dy_xb,w_0))
		
		a    = ((1:-trt):/(1:-psc):^2)/ mean(psc:*(1:-trt):/(1:-psc))
		// This only works because w_1 and w_0 are mutually exclusive
		nest = lin_wols * (mean(xvar,w_1):-mean(xvar,w_0))' :+
		       lin_ps   * mean( a :* (dy_xb :- mean(dy_xb,w_0)) :* exp(psxb):/(1:+exp(psxb)):^2:*xvar)'			   
		// RIF att_inf_func = inf_treat' :- inf_control
		rif = att:+n1:-n0:-nest
		st_store(.,att_,touse, rif)	
		st_matrix(bb,mean(rif,tmt))
		st_matrix(VV,variance(rif,tmt)/sum(tmt))
	}
	//// standard IPW

//# RC
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	 void std_ipw_rc(string scalar y_, xvar_ , tmt_, trt_, psv_, pxb_, wgt_ ,  touse, rif,b,V){
    // main Loading variables
    real matrix y, 	xvar, tmt, trt, psv, psc, wgt
				
	y    = st_data(.,y_, touse)
	xvar = st_data(.,xvar_, touse), J(rows(y),1,1)
	tmt  = st_data(.,tmt_, touse)
	trt  = st_data(.,trt_, touse)
	psc  = logistic(st_data(.,pxb_, touse))
	wgt  = st_data(.,wgt_, touse)
	psv  = st_matrix(psv_)
	real scalar nn
 	nn = rows(y)
	
	real matrix w10, w11, w00, w01
	
    w10 = wgt :* trt :* (1 :- tmt)
    w11 = wgt :* trt :* tmt
    w00 = wgt :* psc :* (1 :- trt) :* (1 :- tmt):/(1 :- psc)
    w01 = wgt :* psc :* (1 :- trt) :* tmt:/(1 :- psc)
	
	w00 = w00:/mean(w00 )
	w01 = w01:/mean(w01 )
	w10 = w10:/mean(w10 )
	w11 = w11:/mean(w11 )
	
	real matrix att_treat_pre, att_treat_post, att_cont_pre, att_cont_post,
				eta_treat_pre, eta_treat_post, eta_cont_pre, eta_cont_post
	att_treat_pre  	= w10 :* y
    att_treat_post 	= w11 :* y
    att_cont_pre   	= w00 :* y
    att_cont_post  	= w01 :* y
    eta_treat_pre  	= mean(att_treat_pre)
    eta_treat_post 	= mean(att_treat_post)
    eta_cont_pre   	= mean(att_cont_pre)
    eta_cont_post  	= mean(att_cont_post)
	
	real matrix ipw_att, lin_rep_ps
    ipw_att 		= (eta_treat_post :- eta_treat_pre) :- (eta_cont_post :- eta_cont_pre)
    //score_ps 		= wgt :* (trt :- psc) :* xvar
    //Hessian_ps 		= psv :* nn
    lin_rep_ps 		= (wgt :* (trt :- psc) :* xvar) * (psv :* nn)
    
	real matrix inf_treat, inf_cont, M2_pre, M2_post, inf_cont_ps, att_inf_func
	
	inf_treat 		= (att_treat_post :- w11 :* eta_treat_post) :- (att_treat_pre :- w10 :* eta_treat_pre)
    inf_cont 		= (att_cont_post :- w01 :* eta_cont_post) :- (att_cont_pre :- w00 :* eta_cont_pre)
    M2_pre 			= mean(w00 :* (y :- eta_cont_pre) :* xvar)
    M2_post 		= mean(w01 :* (y :- eta_cont_post) :* xvar)
    inf_cont_ps 	= lin_rep_ps * (M2_post :- M2_pre)'
    inf_cont 		= inf_cont :+ inf_cont_ps
    
	att_inf_func 	= ipw_att :+ inf_treat :- inf_cont

	st_matrix(b,mean(att_inf_func))
	st_matrix(V,variance(att_inf_func)/nn)
	st_store(.,rif,touse,att_inf_func)
 //  -15.80330618	
 //  9.087929526
 }
// Regression approach
  void reg_rc(string scalar y_, yy_, xvar_ , tmt_, trt_, wgt_ ,  touse, rif,b,V) {
    // main Loading variables
    real matrix y,  y00, y01,
				xvar, tmt, trt,   wgt
				
	y    = st_data(.,y_, touse)
	yy   = st_data(.,yy_, touse)
	y00  = yy[,1]
	y01  = yy[,2]

	xvar = st_data(.,xvar_, touse), J(rows(y),1,1)
	tmt  = st_data(.,tmt_, touse)
	trt  = st_data(.,trt_, touse)
	//psc  = logistic(st_data(.,pxb_, touse))
	//psv  = st_matrix(psv_)
	wgt  = st_data(.,wgt_, touse)
	
	real scalar nn
	nn = rows(y)
	
	real matrix w10, w11, w0
	
	w10 			= wgt :* trt :* (1 :- tmt)
    w11 			= wgt :* trt :* tmt
    w0 				= wgt :* trt
	
	w10				= w10:/mean(w10 )
	w11				= w11:/mean(w11 )
	w0				= w0:/mean(w0 )
	
	real matrix att_treat_pre, att_treat_post, att_cont,
				eta_treat_pre, eta_treat_post, eta_cont, reg_att
    att_treat_pre 	= w10 :* y
    att_treat_post 	= w11 :* y
    att_cont 		= w0 :* (y01 :- y00)
    eta_treat_pre 	= mean(att_treat_pre)
    eta_treat_post 	= mean(att_treat_post)
    eta_cont 		= mean(att_cont)
    reg_att 		= (eta_treat_post :- eta_treat_pre) :- eta_cont
	
	real matrix w_ols_pre, wols_eX_pre, XpX_inv_pre, lin_rep_ols_pre
    w_ols_pre 		= wgt :* (1 :- trt) :* (1 :- tmt)
    //wols_x_pre 	= w_ols_pre :* xvar
    wols_eX_pre 	= w_ols_pre :* (y :- y00) :* xvar
    XpX_inv_pre 	= invsym(quadcross(xvar,w_ols_pre, xvar)):*nn
    lin_rep_ols_pre = wols_eX_pre * XpX_inv_pre
	
	real matrix w_ols_post, wols_eX_post, XpX_inv_post, lin_rep_ols_post
    w_ols_post 		= wgt :* (1 :- trt) :* tmt
    //wols_x_post 	= w_ols_post :* xvar
    wols_eX_post 	= w_ols_post :* (y :- y01) :* xvar
    XpX_inv_post 	= invsym(quadcross(xvar, w_ols_post, xvar)):*nn
    lin_rep_ols_post = wols_eX_post * XpX_inv_post
    
	real matrix inf_treat, inf_cont_1, inf_cont_2_post, inf_cont_2_pre, inf_control
	//inf_treat_pre 	= (att_treat_pre :- w10 :* eta_treat_pre)
    //inf_treat_post 	= (att_treat_post :- w11 :* eta_treat_post)
    inf_treat 		= (att_treat_post :- w11 :* eta_treat_post) :- (att_treat_pre :- w10 :* eta_treat_pre)
    inf_cont_1 		= (att_cont :- w0 :* eta_cont)
    //M1 				= mean(w0 :* xvar)
    inf_cont_2_post = lin_rep_ols_post * mean(w0 :* xvar)'
    inf_cont_2_pre 	= lin_rep_ols_pre  * mean(w0 :* xvar)'
    inf_control 	= (inf_cont_1 :+ inf_cont_2_post :- inf_cont_2_pre)
    
	real matrix att_inf_func
	att_inf_func 	= reg_att :+ (inf_treat :- inf_control)
 	
	st_matrix(b,mean(att_inf_func))
	st_matrix(V,variance(att_inf_func)/nn)
	st_store(.,rif,touse,att_inf_func)
 }

 /// Abadies IPW
 
  void ipw_abadie_rc(string scalar y_, xvar_ , tmt_, trt_, psv_, pxb_, wgt_ ,  touse, rif,b,V){
    // main Loading variables
    real matrix y, 	xvar, tmt, trt, psv, psc, wgt
				
	y    = st_data(.,y_, touse)
	xvar = st_data(.,xvar_, touse), J(rows(y),1,1)
	tmt  = st_data(.,tmt_, touse)
	trt  = st_data(.,trt_, touse)
	psc  = logistic(st_data(.,pxb_, touse))
	wgt  = st_data(.,wgt_, touse)
	psv  = st_matrix(psv_)
	real scalar nn
 	nn = rows(y)
	
	real matrix w10, w11, w00, w01
    w10 				= wgt :* trt :* (1 :- tmt)
    w11 				= wgt :* trt :* tmt
    w00 				= wgt :* psc :* (1 :- trt) :* (1 :- tmt):/(1 :- psc)
    w01 				= wgt :* psc :* (1 :- trt) :* tmt:/(1 :- psc)
	
	real matrix pi_hat, lambda_hat, one_lambda_hat
	pi_hat       		= mean(wgt :* trt)
    lambda_hat 			= mean(wgt :* tmt)
    one_lambda_hat 		= mean(wgt :* (1 :- tmt))
	
	real matrix att_treat_pre, att_treat_post, att_cont_pre, att_cont_post,
				eta_treat_pre, eta_treat_post, eta_cont_pre, eta_cont_post
				
    att_treat_pre 		= w10 :* y:/(pi_hat :* one_lambda_hat)
    att_treat_post 		= w11 :* y:/(pi_hat :* lambda_hat)
    att_cont_pre 		= w00 :* y:/(pi_hat :* one_lambda_hat)
    att_cont_post 		= w01 :* y:/(pi_hat :* lambda_hat)
    eta_treat_pre 		= mean(att_treat_pre)
    eta_treat_post 		= mean(att_treat_post)
    eta_cont_pre 		= mean(att_cont_pre)
    eta_cont_post 		= mean(att_cont_post)
	
	real matrix ipw_att
    ipw_att 			= (eta_treat_post :- eta_treat_pre) :- (eta_cont_post :- eta_cont_pre)
	
	real matrix lin_rep_ps, inf_treat_post, inf_treat_pret, inf_cont_post, inf_cont_pret
    //score_ps 			= wgt :* (trt :- psc) :* xvar
    //Hessian_ps 			= psv :* nn
    lin_rep_ps 			= (wgt :* (trt :- psc) :* xvar) * (psv :* nn)
	
	inf_treat_post 		= att_treat_post :- eta_treat_post :+
						-(wgt :* trt :- pi_hat) :* eta_treat_post:/pi_hat :+
						-(wgt :* tmt :- lambda_hat) :* eta_treat_post:/lambda_hat
    ///inf_treat_post 		= inf_treat_post1 :+ inf_treat_post2 :+ inf_treat_post3
	
    inf_treat_pret 		= att_treat_pre :- eta_treat_pre :+
						 -(wgt :* trt :- pi_hat) :* eta_treat_pre:/pi_hat :+
						 -(wgt :* (1 :- tmt) :- one_lambda_hat) :* eta_treat_pre:/one_lambda_hat
    // inf_treat_pret 		= inf_treat_pre1 :+ inf_treat_pre2 :+ inf_treat_pre3
	
    inf_cont_post		= att_cont_post :- eta_cont_post :+
						  -(wgt :* trt :- pi_hat) :* eta_cont_post:/pi_hat :+
						  -(wgt :* tmt :- lambda_hat) :* eta_cont_post:/lambda_hat
    ///inf_cont_post = inf_cont_post1 :+ inf_cont_post2 :+ inf_cont_post3
    inf_cont_pret       = att_cont_pre :- eta_cont_pre :+
						  -(wgt :* trt :- pi_hat) :* eta_cont_pre:/pi_hat :+
						  -(wgt :* (1 :- tmt) :- one_lambda_hat) :* eta_cont_pre:/one_lambda_hat
     		
	//inf_cont_pret= inf_cont_pre1 :+ inf_cont_pre2 :+ inf_cont_pre3
	real matrix inf_logit, att_inf_func
    //mom_logit_pre 		= mean(-att_cont_pre :* xvar)
    //mom_logit_pre 		= mean(mom_logit_pre)
    //mom_logit_post 		= mean(-att_cont_post :* xvar)
    //mom_logit_post 		= mean(mom_logit_post)
    inf_logit 			= lin_rep_ps * (mean(-att_cont_post :* xvar) :- mean(-att_cont_pre :* xvar))'
	
    att_inf_func 		= ipw_att :+ (inf_treat_post :- inf_treat_pret) :- (inf_cont_post :- inf_cont_pret) :+ inf_logit
	
	st_matrix(b,mean(att_inf_func))
	st_matrix(V,variance(att_inf_func)/nn)
	st_store(.,rif,touse,att_inf_func)
//  -19.89330192
//  53.86822411
 }
 
/// DRDID_RC
 void drdid_rc(string scalar y_, yy_, xvar_ , tmt_, trt_, psv_, pxb_, wgt_ ,  touse, rif,b,V){
    // main Loading variables
    real matrix y,  y00, y01, y10, y11,
				xvar, tmt, trt, psv, psc, wgt
				
	y    = st_data(.,y_, touse)
	yy   = st_data(.,yy_, touse)
	y00  = yy[,1]
	y01  = yy[,2]
	y10  = yy[,3]
	y11  = yy[,4]
	xvar = st_data(.,xvar_, touse), J(rows(y),1,1)
	tmt  = st_data(.,tmt_, touse)
	trt  = st_data(.,trt_, touse)
	psc  = logistic(st_data(.,pxb_, touse))
	wgt  = st_data(.,wgt_, touse)
	psv  = st_matrix(psv_)
	
	real matrix y0
	real scalar nn
	y0   = y00:*(-tmt:+1) + y01:*tmt
	nn = rows(y)
	
	real matrix w10, w11, w00, w01, w1
    w10 = wgt :* trt :* (1 :- tmt)
    w11 = wgt :* trt :* tmt
    w00 = wgt :* psc :* (1 :- trt) :* (1 :- tmt):/(1 :- psc)
    w01 = wgt :* psc :* (1 :- trt) :* tmt:/(1 :- psc)
	w1  = wgt :* trt
	
	w00 = w00:/mean(w00 )
	w01 = w01:/mean(w01 )
	w10 = w10:/mean(w10 )
	w11 = w11:/mean(w11 )
	w1 = w1:/mean(w1 )
	
	real matrix att_treat_pre, att_treat_post,  att_cont_pre, att_cont_post,
				att_trt_post, att_trtt1_post, att_trt_pre, att_trtt0_pre,
				eta_treat_pre, eta_treat_post,  eta_cont_pre, eta_cont_post,
				eta_trt_post, eta_trtt1_post, eta_trt_pre, eta_trtt0_pre
				
    att_treat_pre 		= w10 :* (y :- y0)
    att_treat_post 		= w11 :* (y :- y0)
    att_cont_pre  		= w00 :* (y :- y0)
    att_cont_post  		= w01 :* (y :- y0)
	
    att_trt_post   		= w1  :* (y11 :- y01)
    att_trtt1_post 		= w11 :* (y11 :- y01)
    att_trt_pre   		= w1  :* (y10 :- y00)
    att_trtt0_pre 		= w10 :* (y10 :- y00)
	
    eta_treat_pre 		= mean(att_treat_pre)
    eta_treat_post 		= mean(att_treat_post)
    eta_cont_pre  		= mean(att_cont_pre)
    eta_cont_post  		= mean(att_cont_post)
    eta_trt_post   		= mean(att_trt_post)
    eta_trtt1_post 		= mean(att_trtt1_post)
    eta_trt_pre   		= mean(att_trt_pre)
    eta_trtt0_pre 		= mean(att_trtt0_pre)
	
	real matrix trtr_att
    trtr_att      		= (eta_treat_post :- eta_treat_pre) :- (eta_cont_post :- eta_cont_pre) :+ (eta_trt_post :- eta_trtt1_post) :- (eta_trt_pre :- eta_trtt0_pre)
	
	real matrix wgt_ols_pre, XpX_inv_pre, lin_ols_pre, 
				wgt_ols_post, XpX_inv_post, lin_ols_post,
				XpX_inv_pre_treat, lin_ols_pre_treat,
				XpX_inv_post_treat, lin_ols_post_treat
	wgt_ols_pre     	= wgt :* (1 :- trt) :* (1 :- tmt)
    //wols_x_pre          = wgt_ols_pre :* xvar
    //wols_eX_pre         = wgt_ols_pre :* (y :- y00) :* xvar
    XpX_inv_pre         = invsym(quadcross(xvar,wgt_ols_pre, xvar)):*nn
    lin_ols_pre 		= ( wgt_ols_pre :* (y :- y00) :* xvar) * XpX_inv_pre
    
	wgt_ols_post     	= wgt :* (1 :- trt) :* tmt
    //wols_x_post         = wgt_ols_post :* xvar
    //wols_eX_post        = wgt_ols_post :* (y :- y01) :* xvar
    XpX_inv_post 		= invsym(quadcross(xvar,wgt_ols_post, xvar)):*nn
	lin_ols_post 		= (wgt_ols_post :* (y :- y01) :* xvar) * XpX_inv_post
	    
    //wols_x_pre_treat 	= w10 :* xvar
    //wols_eX_pre_treat 	= w10 :* (y :- y10) :* xvar
    XpX_inv_pre_treat 	= invsym(quadcross(xvar, w10, xvar)):*nn
	lin_ols_pre_treat 	= ( w10 :* (y :- y10) :* xvar) * XpX_inv_pre_treat
	
	//wols_x_post_treat   = w11 :* xvar
    //wols_eX_post_treat  = w11 :* (y :- y11) :* xvar
    XpX_inv_post_treat  = invsym(quadcross(xvar, w11, xvar)):*nn
    lin_ols_post_treat 	= (w11 :* (y :- y11) :* xvar) * XpX_inv_post_treat
	
	real matrix lin_rep_ps, inf_treat_pre, inf_treat_post
    // check psv for probit
	//score_ps 			= wgt :* (trt :- psc) :* xvar
    //Hessian_ps 			= psv :* nn
    lin_rep_ps 			= (wgt :* (trt :- psc) :* xvar) * (psv :* nn)
    inf_treat_pre 		= att_treat_pre  :- w10 :* eta_treat_pre 
    inf_treat_post 		= att_treat_post :- w11 :* eta_treat_post
	
	real matrix M1_post, M1_pre, inf_treat_or_post, inf_treat_or_pre
	
    M1_post 			= -mean(w11 :* tmt :* xvar)
    M1_pre 				= -mean(w10 :* (1 :- tmt) :* xvar)
	inf_treat_or_post 	= lin_ols_post * M1_post'
    inf_treat_or_pre 	= lin_ols_pre * M1_pre'
	
	real matrix inf_treat_or, inf_treat, inf_cont_pre, inf_cont_post
	
    inf_treat_or 		= inf_treat_or_post :+ inf_treat_or_pre
    inf_treat 			= inf_treat_post :- inf_treat_pre :+ inf_treat_or
    inf_cont_pre 		= att_cont_pre  :- w00 :* eta_cont_pre 
    inf_cont_post 		= att_cont_post :- w01 :* eta_cont_post 
    
	real matrix M2_pre, M2_post, inf_cont_ps, M3_post, M3_pre, inf_cont_or_post, inf_cont_or_pre
	M2_pre 				= mean(w00 :* (y :- y0 :- eta_cont_pre) :* xvar)
    M2_post 			= mean(w01 :* (y :- y0 :- eta_cont_post) :* xvar)
    inf_cont_ps 		= lin_rep_ps * (M2_post :- M2_pre)'
	
    M3_post 			= -mean(w01 :* tmt :* xvar)
    M3_pre 				= -mean(w00 :* (1 :- tmt) :* xvar)
    inf_cont_or_post 	= lin_ols_post * M3_post'
    inf_cont_or_pre 	= lin_ols_pre  * M3_pre'
	
	real matrix inf_cont_or, inf_cont, trtr_eta_inf_func1
	
    inf_cont_or 		= inf_cont_or_post :+ inf_cont_or_pre
    inf_cont 			= inf_cont_post    :- inf_cont_pre :+ inf_cont_ps :+ inf_cont_or
    trtr_eta_inf_func1 	= inf_treat :- inf_cont
	
	real matrix inf_eff, mom_post, mom_pre, inf_or
    //inf_eff1 			= att_trt_post   :- w1  :* eta_trt_post   
    //inf_eff2 			= att_trtt1_post :- w11 :* eta_trtt1_post 
    //inf_eff3 			= att_trt_pre    :- w1  :* eta_trt_pre   
    //inf_eff4 			= att_trtt0_pre  :- w10 :* eta_trtt0_pre 
    inf_eff 			= ((att_trt_post   :- w1  :* eta_trt_post)    :- 
						   (att_trtt1_post :- w11 :* eta_trtt1_post)) :-
						  ((att_trt_pre    :- w1  :* eta_trt_pre)     :- 
						   (att_trtt0_pre :- w10 :* eta_trtt0_pre))
    mom_post 			= mean((w1 :- w11) :* xvar)
    mom_pre 			= mean((w1 :- w10) :* xvar)
	// check this
    //inf_or_post 		= ((lin_ols_post_treat :- lin_ols_post) * mom_post')
    //inf_or_pre 		= 
    inf_or 				= ((lin_ols_post_treat :- lin_ols_post) * mom_post') :- ((lin_ols_pre_treat :- lin_ols_pre) * mom_pre')
	
	att_inf_func	 	= trtr_att :+ trtr_eta_inf_func1 :+ inf_eff :+ inf_or
	
	st_matrix(b,mean(att_inf_func))
	st_matrix(V,variance(att_inf_func)/nn)
	st_store(.,rif,touse,att_inf_func)
//  -.1677954483	
// .2008991705	
 }

/// DRDID_RC1
void drdid_rc1(string scalar y_, yy_, xvar_ , tmt_, trt_, psv_, pxb_, wgt_ ,  touse, rif,b,V){
    // main Loading variables
    real matrix y,  y00, y01, y10, y11,
				xvar, tmt, trt, psv, psc, wgt
				
	y    = st_data(.,y_, touse)
	yy   = st_data(.,yy_, touse)
	y00  = yy[,1]
	y01  = yy[,2]
	y10  = yy[,3]
	y11  = yy[,4]
	xvar = st_data(.,xvar_, touse), J(rows(y),1,1)
	tmt  = st_data(.,tmt_, touse)
	trt  = st_data(.,trt_, touse)
	psc  = logistic(st_data(.,pxb_, touse))
	wgt  = st_data(.,wgt_, touse)
	psv  = st_matrix(psv_)
	
	real matrix y0
	real scalar nn
	y0   = y00:*(-tmt:+1) + y01:*tmt
	nn = rows(y)
    
	real matrix w10, w11, w00, w01
    w10 		= wgt :* trt :* (1 :- tmt)
    w11 		= wgt :* trt :* tmt
    w00 		= wgt :* psc :* (1 :- trt) :* (1 :- tmt):/(1 :- psc)
    w01 		= wgt :* psc :* (1 :- trt) :* tmt:/(1 :- psc)
	
	w00 = w00:/mean(w00 )
	w01 = w01:/mean(w01 )
	w10 = w10:/mean(w10 )
	w11 = w11:/mean(w11 )
	
	real matrix eta_trt_pre, eta_trt_post, eta_cont_pre, eta_cont_post,
				att_trt_pre, att_trt_post, att_cont_pre, att_cont_post
				
    eta_trt_pre 	= w10 :* (y :- y0)
    eta_trt_post 	= w11 :* (y :- y0)
    eta_cont_pre 	= w00 :* (y :- y0)
    eta_cont_post 	= w01 :* (y :- y0)
    att_trt_pre 	= mean(eta_trt_pre)
    att_trt_post 	= mean(eta_trt_post)
    att_cont_pre 	= mean(eta_cont_pre)
    att_cont_post 	= mean(eta_cont_post)
	
	real matrix trtr_att, w_ols_pre, wols_eX_pre, lin_rep_ols_pre,
						  w_ols_post, wols_eX_post, lin_rep_ols_post
    trtr_att 		= (att_trt_post :- att_trt_pre) :- (att_cont_post :- att_cont_pre)
	
    w_ols_pre 		= wgt :* (1 :- trt) :* (1 :- tmt)
    wols_eX_pre 	= w_ols_pre :* (y :- y00) :* xvar
 
    lin_rep_ols_pre = wols_eX_pre * invsym(quadcross(xvar, w_ols_pre, xvar)):*nn
	
    w_ols_post  	= wgt :* (1 :- trt) :* tmt
    wols_eX_post 	= w_ols_post  :* (y :- y01) :* xvar
    lin_rep_ols_post = wols_eX_post * invsym(quadcross( xvar,w_ols_post, xvar)):*nn
	
	real matrix lin_rep_ps, inf_trt_pre, inf_trt_post, M1_post, M1_pre
    //score_ps 		= wgt :* (trt :- psc) :* xvar
    //Hessian_ps 		= psv :* nn
    lin_rep_ps 		= (wgt :* (trt :- psc) :* xvar) * (psv :* nn)
    inf_trt_pre 	= eta_trt_pre :- w10 :* att_trt_pre
    inf_trt_post 	= eta_trt_post :- w11 :* att_trt_post
	M1_post 		= -mean(w11 :* tmt :* xvar)
    M1_pre 			= -mean(w10 :* (1 :- tmt) :* xvar)
    
	real matrix inf_trt_or, inf_trt
    inf_trt_or 		= (lin_rep_ols_post * M1_post') :+ (lin_rep_ols_pre * M1_pre')
    inf_trt 		= inf_trt_post :- inf_trt_pre :+ inf_trt_or
    
	real matrix inf_cont_pre , inf_cont_post, M2_pre,  M2_post, inf_cont_ps, M3_post, M3_pre

	inf_cont_pre 	= eta_cont_pre :- w00 :* att_cont_pre
    inf_cont_post 	= eta_cont_post :- w01 :* att_cont_post
    M2_pre 			= mean(w00 :* (y :- y0 :- att_cont_pre) :* xvar)
    M2_post 		= mean(w01 :* (y :- y0 :- att_cont_post) :* xvar)
    inf_cont_ps 	= lin_rep_ps * (M2_post :- M2_pre)'
    M3_post 		= -mean(w01 :* tmt :* xvar)
    M3_pre 			= -mean(w00 :* (1 :- tmt) :* xvar)

	real matrix inf_cont_or, inf_cont, att_inf_func
    inf_cont_or 	= (lin_rep_ols_post * M3_post') :+ (lin_rep_ols_pre * M3_pre')
    inf_cont 		= inf_cont_post :- inf_cont_pre :+ inf_cont_ps :+ inf_cont_or
    att_inf_func 	= trtr_att :+ inf_trt :- inf_cont
	
	st_matrix(b,mean(att_inf_func))
	st_matrix(V,variance(att_inf_func)/nn)
	st_store(.,rif,touse,att_inf_func)
 // -3.633433441	
//3.107123089
}
 
/// drdid_imp_rc
void drdid_imp_rc(string scalar y_, yy_, xvar_ , tmt_, trt_, psv_, pxb_, wgt_ ,  touse, rif,b,V){
    // main Loading variables
    real matrix y,  y00, y01, y10, y11,
				xvar, tmt, trt, psv, psc, wgt
				
	y    = st_data(.,y_, touse)
	yy   = st_data(.,yy_, touse)
	y00  = yy[,1]
	y01  = yy[,2]
	y10  = yy[,3]
	y11  = yy[,4]
	xvar = st_data(.,xvar_, touse), J(rows(y),1,1)
	tmt  = st_data(.,tmt_, touse)
	trt  = st_data(.,trt_, touse)
	psc  = logistic(st_data(.,pxb_, touse))
	wgt  = st_data(.,wgt_, touse)
	psv  = st_matrix(psv_)
	
	real matrix y0
	real scalar nn
	y0   = y00:*(-tmt:+1) + y01:*tmt
	nn = rows(y)

	real matrix w10, w11, w00, w01, w1
    w10 = wgt :* trt :* (1 :- tmt)
    w11 = wgt :* trt :* tmt
    w00 = wgt :* psc :* (1 :- trt) :* (1 :- tmt):/(1 :-  psc)
    w01 = wgt :* psc :* (1 :- trt) :* tmt:/(1 :- psc)
    w1  = wgt :* trt

	w00 = w00:/mean(w00 )
	w01 = w01:/mean(w01 )
	w10 = w10:/mean(w10 )
	w11 = w11:/mean(w11 )
	w1 = w1:/mean(w1 )
	
	real matrix att_treat_pre, att_treat_post, att_cont_pre, att_cont_post, att_trt_post, att_trtt1_post,
				att_trt_pre, att_trtt0_pre
	
    att_treat_pre  = w10 :* (y :- y0)
    att_treat_post = w11 :* (y :- y0)
    att_cont_pre   = w00 :* (y :- y0)
    att_cont_post  = w01 :* (y :- y0)
    att_trt_post   = w1  :* (y11 :- y01)
    att_trtt1_post = w11 :* (y11 :- y01)
    att_trt_pre    = w1  :* (y10 :- y00)
    att_trtt0_pre  = w10 :* (y10 :- y00)
	
	real matrix eta_treat_pre, eta_treat_post, eta_cont_pre, eta_cont_post, eta_trt_post, eta_trtt1_post,
				eta_trt_pre, eta_trtt0_pre
				
    eta_treat_pre  = mean(att_treat_pre)
    eta_treat_post = mean(att_treat_post)
    eta_cont_pre   = mean(att_cont_pre)
    eta_cont_post  = mean(att_cont_post)
    eta_trt_post   = mean(att_trt_post)
    eta_trtt1_post = mean(att_trtt1_post)
    eta_trt_pre    = mean(att_trt_pre)
    eta_trtt0_pre  = mean(att_trtt0_pre)
	
	real matrix trtr_att
	
    trtr_att       = (eta_treat_post :- eta_treat_pre) :- (eta_cont_post :- eta_cont_pre) :+ (eta_trt_post :- eta_trtt1_post) :- (eta_trt_pre :- eta_trtt0_pre)
	
	real matrix inf_treat,  inf_cont,  att_inf_func1,  inf_eff, att_inf_func
    //inf_treat_pre  = att_treat_pre  :- w10 :* eta_treat_pre
    //inf_treat_post = att_treat_post :- w11 :* eta_treat_post
    //inf_treat      = inf_treat_post :- inf_treat_pre
    //inf_cont_pre   = att_cont_pre   :- w00 :* eta_cont_pre
    //inf_cont_post  = att_cont_post  :- w01 :* eta_cont_post
    //inf_cont       = inf_cont_post  :- inf_cont_pre
	//att_inf_func1  = inf_treat :- inf_cont
    //inf_eff1       = att_trt_post   :- w1  :* eta_trt_post
    //inf_eff2       = att_trtt1_post :- w11 :* eta_trtt1_post
    //inf_eff3       = att_trt_pre    :- w1  :* eta_trt_pre
    //inf_eff4       = att_trtt0_pre  :- w10 :* eta_trtt0_pre
    //inf_eff        =  (inf_eff1 :- inf_eff2) :- (inf_eff3 :- inf_eff4)
	
	inf_treat      = (att_treat_post :- w11 :* eta_treat_post) :- (att_treat_pre  :- w10 :* eta_treat_pre)
    inf_cont       = (att_cont_post  :- w01 :* eta_cont_post)  :- (att_cont_pre   :- w00 :* eta_cont_pre)
	att_inf_func1  = inf_treat :- inf_cont
    inf_eff        =  ((att_trt_post   :- w1  :* eta_trt_post) :- (att_trtt1_post :- w11 :* eta_trtt1_post)) :- ((att_trt_pre    :- w1  :* eta_trt_pre) :- (att_trtt0_pre  :- w10 :* eta_trtt0_pre))
	
    att_inf_func  = trtr_att :+ att_inf_func1 :+ inf_eff
	
	st_matrix(b,mean(att_inf_func))
	st_matrix(V,variance(att_inf_func)/nn)
	st_store(.,rif,touse,att_inf_func)
//-.2088586355	
//.2003375215	
}
/// drdid_imp_rc1
void drdid_imp_rc1(string scalar y_, yy_, xvar_ , tmt_, trt_, psv_, pxb_, wgt_ ,  touse, rif,b,V){
    // main Loading variables
    real matrix y,  y00, y01, y10, y11,
				xvar, tmt, trt, psv, psc, wgt
	y    = st_data(.,y_, touse)
	yy   = st_data(.,yy_, touse)
	y00  = yy[,1]
	y01  = yy[,2]
	y10  = yy[,3]
	y11  = yy[,4]
	xvar = st_data(.,xvar_, touse), J(rows(y),1,1)
	tmt  = st_data(.,tmt_, touse)
	trt  = st_data(.,trt_, touse)
	psc  = logistic(st_data(.,pxb_, touse))
	wgt  = st_data(.,wgt_, touse)
	psv  = st_matrix(psv_)
	
	real matrix y0
	real scalar nn
	y0   = y00:*(-tmt:+1) + y01:*tmt
	nn = rows(y)
	
	real matrix w10, w11, w00, w01, 
				eta_treat_pre, eta_treat_post, eta_cont_pre, eta_cont_post,
				att_treat_pre, att_treat_post, att_cont_pre, att_cont_post
				
    w10 			= wgt :* trt :* (1 :- tmt)
    w11 			= wgt :* trt :* tmt
    w00 			= wgt :* psc:* (1 :- trt) :* (1 :- tmt):/(1 :-  psc)
	w01 			= wgt :* psc:* (1 :- trt) :* tmt:/(1 :- psc)
    
	eta_treat_pre 	= w10 :* (y :- y0):/mean(w10)
    eta_treat_post 	= w11 :* (y :- y0):/mean(w11)
    eta_cont_pre 	= w00 :* (y :- y0):/mean(w00)
    eta_cont_post 	= w01 :* (y :- y0):/mean(w01)
    
	att_treat_pre 	= mean(eta_treat_pre)
    att_treat_post 	= mean(eta_treat_post)
    att_cont_pre 	= mean(eta_cont_pre)
    att_cont_post 	= mean(eta_cont_post)
    
	real matrix trtr_att, inf_treat, inf_cont, att_inf_func
	trtr_att 		= (att_treat_post :- att_treat_pre) :- (att_cont_post :-  att_cont_pre)
    inf_treat 		= (eta_treat_post :- w11 :* att_treat_post:/mean(w11) ):- (eta_treat_pre :- w10 :* att_treat_pre:/mean(w10))
    inf_cont 		= (eta_cont_post :- w01 :* att_cont_post:/mean(w01)) :- ( eta_cont_pre :- w00 :* att_cont_pre:/mean(w00))
    att_inf_func 	= trtr_att :+ inf_treat :- inf_cont
	
	// Wrapping up
	st_matrix(b,mean(att_inf_func))
	st_matrix(V,variance(att_inf_func)/nn)
	st_store(.,rif,touse,att_inf_func)
//  -3.683728719	
//	 3.114495585
}
 
end


** estimators left
**dp p
** dr p imp Done
** reg perhaps via teffects
**ipw p perhaps via gmm and manual
** ipw p std via teffects 
