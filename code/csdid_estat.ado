*! v1.2 FRA Adds the options for simple and calendar so it doesnt depend on consecutive years
* also adds the option window
*! v1 FRA Adds Safeguards to csdid calendar. Calendar starts after treatment
** Estat command for aggregators
program csdid_estat, sortpreserve  
version 14
        if "`e(cmd)'" != "csdid" {
                error 301
        }
		gettoken key rest : 0, parse(", ")
		 
		if inlist("`key'","simple","pretrend","group","calendar","event","all") | ///
		   inlist("`key'","group_alt","calendar_alt","event_alt"){
			csdid_`key'  `rest'
		}
		else {
		    display in red "Option `key' not recognized"
			error 199
		}
		
end

program csdid_all, sortpreserve rclass
	csdid_pretrend
	csdid_simple
	csdid_group
	csdid_calendar
	csdid_event
end

program csdid_pretrend, sortpreserve rclass
	local pretrend
	foreach i in `e(glev)' {		
   		local time1 = `e(time0)'
		foreach j in `e(tlev)' {
			*local time1 = min(`i'-1, `j'-1)
			if `j'<`i' local pretrend `pretrend' ([g`i']t_`time1'_`j'=0)
			if `j'<`i' local time1 = `j'							
		}
	}
	display "Pretrend Test. H0 All Pre-treatment are equal to 0"
	test `pretrend'
	return scalar chi2_pretest	= scalar(r(chi2))
	return scalar df_pretest    = scalar(r(df))
	return scalar p_pretest		= scalar(r(p))
end

program csdid_simple,  rclass sortpreserve
	syntax , [post estore(name)]
	local simple `simple' (simple: ( ( 
	foreach i in `e(glev)' {
   		local time1 = `e(time0)'
		foreach j in `e(tlev)' {
			*local time1 = min(`i'-1, `j'-1)
			if (`i'<=`j') {
				local simple `simple' [g`i']t_`time1'_`j'*[wgt]w`i'+
				local wcl      `wcl' 	  [wgt]w`i'+
			}
			if `j'<`i' local time1 = `j'							
		}
	}
	local simple `simple' 0)/(`wcl'0)))
	display "Simple Average Treatment"
	
	if "`post'`estore'"=="" {
		nlcom  `simple', noheader
		tempvar b V
		matrix `b' = r(b)
		matrix `V' = r(V)
		return matrix b_simple = `b'
		return matrix V_simple = `V'
	}
	else if "`post'"!="" & "`estore'"==""  {
	    nlcom `simple', noheader post
	}
	else if "`estore'"!="" & "`post'"==""  {
	   	tempname lastreg
		tempvar b V table
		capture:est store `lastreg'
		nlcom `simple', noheader post
		est store `estore'
		display "Output store in `estore'"
		matrix `b' = e(b)
		matrix `V' = e(V)
		matrix `table' = r(table)
		qui:est restore `lastreg'
		return matrix b_simple 	= `b'
		return matrix V_simple 	= `V'
		return matrix table 	= `table'
	}
end

program csdid_group, sortpreserve rclass
	syntax , [post estore(name)]

	foreach i in `e(glev)'  {		
   		local time1 = `e(time0)'
		local group `group' (g`i': ( ( 
		local cnt=0
		foreach j in `e(tlev)' {
			*local time1 = min(`i'-1, `j'-1)
			if (`i'<=`j') {
						local cnt=`cnt'+1
				local group `group' [g`i']t_`time1'_`j'+
			}
			if `j'<`i' local time1 = `j'			
		}
		local group `group' 0)/`cnt'))
	}
	
	display "Group Effects"
	if "`post'`estore'"=="" {
		nlcom `group', noheader
		tempvar b V
		matrix `b' = r(b)
		matrix `V' = r(V)
		return matrix b_group = `b'
		return matrix V_group = `V'
	}
	else if "`post'"!="" & "`estore'"==""  {
	    nlcom `group', noheader post
	}
	else if "`estore'"!="" & "`post'"==""  {
	   	tempname lastreg
		tempvar b V table
		capture:est store `lastreg'
		nlcom `group', noheader post
		est store `estore'
		display "Output store in `estore'"
		matrix `b' = e(b)
		matrix `V' = e(V)
		matrix `table' = r(table)
		qui:est restore `lastreg'
		return matrix b_group 	= `b'
		return matrix V_group 	= `V'
		return matrix table 	= `table'
	}	
end

program csdid_group_alt, sortpreserve rclass
	syntax ,  
	display "Group Effects"
	foreach i in `e(glev)'  {		
   		local time1 = `e(time0)'
		local group (g`i': ( ( 
		local cnt=0
		foreach j in `e(tlev)' {
			*local time1 = min(`i'-1, `j'-1)
			if (`i'<=`j') {
						local cnt=`cnt'+1
				local group `group' [g`i']t_`time1'_`j'+
			}
			if `j'<`i' local time1 = `j'			

		}
		local group `group' 0)/`cnt'))
		nlcom `group', noheader
	}
end


program csdid_calendar, sortpreserve rclass
	syntax , [post estore(name)]

	** Verify Tlevel > glevel
	local mint:word 1 of `e(glev)'
	local time1 = `e(time0)'
	foreach j in `e(tlev)' {
		if `j' >= `mint' {
		    local cnt=0    
			local mcalendar   (t`j': ( ( 
			macro drop _wcl
*****************************************************************			
			foreach i in `e(glev)' {
				local time1 = `e(time0)'
				foreach t in `e(tlev)' {
					if (`i'<=`j' & `t'==`j') {
						local cnt=`cnt'+1    
						local mcalendar `mcalendar' [g`i']t_`time1'_`j'*[wgt]w`i'+
						local wcl      `wcl' 	  [wgt]w`i'+ 
					}					
					if `t'<`i' local time1 = `t'			
				}			    				
			}
*****************************************************************
			local mcalendar `mcalendar' 0)/(`wcl'0)))
			if `cnt'>0 local calendar `calendar' `mcalendar'
		}
	}
	display "Time Estimated Effects"
	if "`post'`estore'"=="" {
		nlcom `calendar', noheader
		tempvar b V
		matrix `b' = r(b)
		matrix `V' = r(V)
		return matrix b_calendar = `b'
		return matrix V_calendar = `V'	
	}
	else if "`post'"!="" & "`estore'"=="" {
	    nlcom `calendar', noheader post
	}
	else if "`estore'"!="" & "`post'"==""  {
	   	tempname lastreg
		tempvar b V table
		capture:est store `lastreg'
		nlcom `calendar', noheader post
		est store `estore'
		display "Output store in `estore'"
		matrix `b' = e(b)
		matrix `V' = e(V)
		matrix `table' = r(table)
		qui:est restore `lastreg'
		return matrix b_calendar 	= `b'
		return matrix V_calendar 	= `V'
		return matrix table 	= `table'
	}
end

program csdid_calendar_alt, sortpreserve rclass
	syntax , [post estore(name)]
	display "Time Estimated Effects"
	** Verify Tlevel > glevel
	local mint:word 1 of `e(glev)'	
	foreach j in `e(tlev)' {
	    local cnj=`cnj'+1
		if `j' >= `mint' {
		    local cnt=0    
			local mcalendar   (t`j': ( ( 
			macro drop _wcl
*****************************************************************			
			foreach i in `e(glev)' {
				local time1 = `e(time0)'
				foreach t in `e(tlev)' {
					if (`i'<=`j' & `t'==`j') {
						local cnt=`cnt'+1    
						local mcalendar `mcalendar' [g`i']t_`time1'_`j'*[wgt]w`i'+
						local wcl      `wcl' 	  [wgt]w`i'+ 
					}					
					if `t'<`i' local time1 = `t'			
				}			    				
			}
*****************************************************************			
			local mcalendar `mcalendar' 0)/(`wcl'0)))
			if `cnt'>0 {
				nlcom `mcalendar', noheader
			}
		}
	}

end
 
 
program csdid_event, sortpreserve rclass
	syntax , [post estore(name) window(str)]

	** Define groups
	** G
	event_dist, glist(`e(glev)') tlist(`e(tlev)') 
	local elist `r(vlist)'
	** redefine windows
	if "`window'"!="" {
	    numlist "`window'", sort max(2) min(2)
		local aux `r(numlist)'
		local wmin:word 1 of `aux'
		local wmax:word 2 of `aux'
		
		foreach i of local elist {
		    if inrange(`i',`wmin',`wmax')   local eelist `eelist' `i'
		}
		local elist `eelist'			
	}
	
	/*local tt : word count   `e(glev)'
	local gmax: word `tt' of `e(glev)' 
	local gmin: word  1   of `e(glev)'
	** t
	local tt : word count   `e(tlev)'
	local tmax: word `tt' of `e(tlev)' 
	local tmin: word  1   of `e(tlev)'

	local emin= `tmin'-`gmax'
	local emax= `tmax'-`gmin'*/

	foreach e of local elist {
	 
		local e_t `=cond(sign(`e')<0,"_","")'`=abs(`e')'
		local wcl 
		local evnt0 `evnt0' (E`e_t': ( ( 
		
		foreach i in `e(glev)' {
		    local time1 = `e(time0)'
			foreach j in `e(tlev)' {
					if `i'+`e'==`j' {
						*display "g:`i' ; t: `time1' ; t1:`j'"
						local evnt0 `evnt0'    [g`i']t_`time1'_`j'*[wgt]w`i'+
						local wcl      `wcl' 	  [wgt]w`i'+				    
					}
					if `j'<`i' local time1 = `j'			
				}
			}
			local evnt0 `evnt0' 0)/(`wcl'0)))
		}
	display "Event Studies:Dynamic effects"
	if "`post'`estore'"=="" {
		nlcom `evnt0', noheader
		tempvar b V
		matrix `b' = r(b)
		matrix `V' = r(V)
		return matrix b_event = `b'
		return matrix V_event = `V'	
	}
	else if "`post'"!="" & "`estore'"=="" {
	    nlcom `evnt0', noheader post
	}
	else if "`estore'"!="" & "`post'"==""  {
	   	tempname lastreg
		tempvar b V table
		capture:est store `lastreg'
		nlcom `evnt0', noheader post
		est store `estore'
		display "Output store in `estore'"
		matrix `b' = e(b)
		matrix `V' = e(V)
		matrix `table' = r(table)
		qui:est restore `lastreg'
		return matrix b_event 	= `b'
		return matrix V_event 	= `V'
		return matrix table 	= `table'
	}
end 

program csdid_event_alt, sortpreserve rclass
	syntax , [post estore(name)]

	** Define groups
	** G
	event_dist, glist(`e(glev)') tlist(`e(tlev)') 
	local elist `r(vlist)'
	
	display "Event Studies:Dynamic effects"
	foreach e of local elist {
	 
		local e_t `=cond(sign(`e')<0,"_","")'`=abs(`e')'
		local wcl 
		local evnt0 (E`e_t': ( ( 
	 
		foreach i in `e(glev)' {
		    local time1 = `e(time0)'
			foreach j in `e(tlev)' {		    
					if `i'+`e'==`j' {
						*display "g:`i' ; t: `time1' ; t1:`j'"
						local evnt0 `evnt0'    [g`i']t_`time1'_`j'*[wgt]w`i'+
						local wcl      `wcl' 	  [wgt]w`i'+				    
					}
					if `j'<`i' local time1 = `j'
				
				}
			}
			local evnt0 `evnt0' 0)/(`wcl'0)))
			nlcom `evnt0', noheader
		}
end 

program event_dist, rclass
	syntax, glist(string) tlist(string)

	foreach i of local tlist {
		foreach j of local glist {
			local eve `eve' `=`i'-`j''
		}
	}
	numlist "`eve'", sort
	local eve `r(numlist)'
	local j .
	foreach i of local eve {
	    if `i'!=`j' {
		    local vlist `vlist' `i'
			local j `i'
		}
	}
	return local vlist `vlist'
end
 
program stuff
************ Estat
** estat Pretrend
qui{
test ([g2006]t_2003_2004=0 ) ( [g2006]t_2004_2005=0) ( [g2007]t_2003_2004=0) ( [g2007]t_2004_2005=0) ( [g2007]t_2005_2006=0)

local pretrend
foreach i in 2004 2006 2007 {		
	foreach j in 2004 2005 2006 2007 {
		local time1 = min(`i'-1, `j'-1)
		if `j'<`i' local pretrend `pretrend' ([g`i']t_`time1'_`j'=0)
	}
}
test `pretrend'
}
** estat simple 
qui{
local simple
local simple `simple' (simple: ( ( 
foreach j in 2004 2005 2006 2007 {
	foreach i in 2004 2006 2007 {		
		local time1 = min(`i'-1, `j'-1)
		if (`i'<=`j') {
			local simple `simple' [g`i']t_`time1'_`j'*[wgt]w`i'+
			local wcl      `wcl' 	  [wgt]w`i'+
		}
	}
}
local simple `simple' 0)/(`wcl'0)))
display "`simple'"
nlcom  `simple'
nlcom (Simple: ((_b[g2004:t_2003_2004]+_b[g2004:t_2003_2005]+_b[g2004:t_2003_2006]+_b[g2004:t_2003_2007])*_b[wgt:w2004]+ 	   (_b[g2006:t_2005_2006]+_b[g2006:t_2005_2007])*_b[wgt:w2006]+_b[g2007:t_2006_2007]*_b[wgt:w2007])/(_b[wgt:w2004]*4+_b[wgt:w2006]*2+_b[wgt:w2007]) )
}
** estat ** group
qui {
local group
foreach i in 2004 2006 2007 {		
    local group `group' (g`i': ( ( 
	local cnt=0
	foreach j in 2004 2005 2006 2007 {
		local time1 = min(`i'-1, `j'-1)
		if (`i'<=`j') {
		    		local cnt=`cnt'+1
 			local group `group' [g`i']t_`time1'_`j'+
		}
	}
	local group `group' 0)/`cnt'))
}
display "`group'"
nlcom `group'
}
** Calendar Year Needs to consider Weights
qui {
local calendar
** J if for Year i for G
foreach j in 2004 2005 2006 2007 {
    local calendar `calendar' (t`j': ( ( 
	macro drop _wcl
	foreach i in 2004 2006 2007 {		
		local cnt=0    
		local time1 = min(`i'-1, `j'-1)
		if (`i'<=`j') {
 			local calendar `calendar' [g`i']t_`time1'_`j'*[wgt]w`i'+
			local wcl      `wcl' 	  [wgt]w`i'+
 
		}
	}
	local calendar `calendar' 0)/(`wcl'0)))
}
nlcom `calendar'

nlcom 	(t2004: _b[g2004:t_2003_2004]) ///
		(t2005: _b[g2004:t_2003_2005]) ///
		(t2006: (_b[g2004:t_2003_2006]*_b[wgt:w2004] + _b[g2006:t_2005_2006]*_b[wgt:w2006])/(_b[wgt:w2004]+_b[wgt:w2006]))	 ///
		(t2007: (_b[g2004:t_2003_2007]*_b[wgt:w2004] + _b[g2006:t_2005_2007]*_b[wgt:w2006] + _b[g2007:t_2006_2007]*_b[wgt:w2007] )/(_b[wgt:w2004]+_b[wgt:w2006]+_b[wgt:w2007]))	 , noheader 
}
*** Events Study
qui {
local evnt0
local wcl
** J if for Year i for G

local emin `tmin'-`gmax'
local emax `tmax'-`gmin'
local emin -3
local emax 3
forvalues e = -3/3 {
 
	local e_t `=cond(sign(`e')<0,"_", )'`=abs(`e')'
	local wcl 
	local evnt0 `evnt0' (E`e_t': ( ( 
	display in red "E`e_t'"
	foreach j in 2004 2005 2006 2007 {
		foreach i in 2004 2006 2007 {	
		    
 			local time1 = min(`i'-1, `j'-1)

				if `i'+`e'==`j' {
				    *display "g:`i' ; t: `time1' ; t1:`j'"
					local evnt0 `evnt0'    [g`i']t_`time1'_`j'*[wgt]w`i'+
					local wcl      `wcl' 	  [wgt]w`i'+				    
				}
			
		}
	}
	local evnt0 `evnt0' 0)/(`wcl'0)))
}
 
nlcom `evnt0'
`evnt0'
 


nlcom (E_3: ( _b[g2007:t_2003_2004]*_b[wgt:w2007]) /// 
			/(_b[wgt:w2007])) ///  
	(E_2: ( _b[g2006:t_2003_2004]*_b[wgt:w2006]+ ///
	         _b[g2007:t_2004_2005]*_b[wgt:w2007]) /// 
			/(_b[wgt:w2006]+_b[wgt:w2007])) /// 
			(E_1: ( _b[g2006:t_2004_2005]*_b[wgt:w2006]+ ///
	         _b[g2007:t_2005_2006]*_b[wgt:w2007]) /// 
			/(_b[wgt:w2006]+_b[wgt:w2007])) ///   
(E0: ( _b[g2004:t_2003_2004]*_b[wgt:w2004]+ ///
	         _b[g2006:t_2005_2006]*_b[wgt:w2006]+ ///
	         _b[g2007:t_2006_2007]*_b[wgt:w2007]) /// 
			/(_b[wgt:w2004]+_b[wgt:w2006]+_b[wgt:w2007]))	///   
	(E1: ((_b[g2004:t_2003_2005])*_b[wgt:w2004]+ ///
	   (_b[g2006:t_2005_2007])*_b[wgt:w2006])/(_b[wgt:w2004]+_b[wgt:w2006]))	///
	(E2: ((_b[g2004:t_2003_2006])*_b[wgt:w2004]) /(_b[wgt:w2004]))	   ///
	(E3: ((_b[g2004:t_2003_2007])*_b[wgt:w2004]) /(_b[wgt:w2004]))	  
	
}
end
