** Estat command for aggregators
 program csdid_estat, sortpreserve rclass
version 14
        if "`e(cmd)'" != "csdid" {
                error 301
        }
		gettoken key rest : 0, parse(", ")
		 
		if inlist("`key'","simple","pretrend","group","calendar","event","all") {
			csdid_`key'
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
		foreach j in `e(tlev)' {
			local time1 = min(`i'-1, `j'-1)
			if `j'<`i' local pretrend `pretrend' ([g`i']t_`time1'_`j'=0)
		}
	}
	display "Pretrend Test. H0 All Pre-treatment are equal to 0"
	test `pretrend'
end

program csdid_simple, sortpreserve rclass

	local simple `simple' (simple: ( ( 
	foreach j in `e(tlev)' {
		foreach i in `e(glev)' {		
			local time1 = min(`i'-1, `j'-1)
			if (`i'<=`j') {
				local simple `simple' [g`i']t_`time1'_`j'*[wgt]w`i'+
				local wcl      `wcl' 	  [wgt]w`i'+
			}
		}
	}
	local simple `simple' 0)/(`wcl'0)))
	display "Simple Average Treatment"
	nlcom  `simple', noheader

end

program csdid_group, sortpreserve rclass
	foreach i in `e(glev)'  {		
		local group `group' (g`i': ( ( 
		local cnt=0
		foreach j in `e(tlev)' {
			local time1 = min(`i'-1, `j'-1)
			if (`i'<=`j') {
						local cnt=`cnt'+1
				local group `group' [g`i']t_`time1'_`j'+
			}
		}
		local group `group' 0)/`cnt'))
	}
	display "Group Effects"
	nlcom `group', noheader
end

program csdid_calendar, sortpreserve rclass
	foreach j in `e(tlev)' {
		local calendar `calendar' (t`j': ( ( 
		macro drop _wcl
		foreach i in `e(glev)' {		
			local cnt=0    
			local time1 = min(`i'-1, `j'-1)
			if (`i'<=`j') {
				local calendar `calendar' [g`i']t_`time1'_`j'*[wgt]w`i'+
				local wcl      `wcl' 	  [wgt]w`i'+
	 
			}
		}
		local calendar `calendar' 0)/(`wcl'0)))
	}
	display "Time Estimated Effects"
	nlcom `calendar', noheader
end
 
program csdid_event, sortpreserve rclass
	** Define groups
	** G
	local tt : word count   `e(glev)'
	local gmax: word `tt' of `e(glev)' 
	local gmin: word  1   of `e(glev)'
	** t
	local tt : word count   `e(tlev)'
	local tmax: word `tt' of `e(tlev)' 
	local tmin: word  1   of `e(tlev)'

	local emin= `tmin'-`gmax'
	local emax= `tmax'-`gmin'

	forvalues e = `emin'/`emax' {
	 
		local e_t `=cond(sign(`e')<0,"_","")'`=abs(`e')'
		local wcl 
		local evnt0 `evnt0' (E`e_t': ( ( 
	 
		foreach j in `e(tlev)' {
			foreach i in `e(glev)' {		    
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
	display "Event Studies:Dynamic effects"
	nlcom `evnt0', noheader
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
