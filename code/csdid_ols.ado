/*
This is a very small program that will estimate something akin 
to a simultaneous OLS
The dep variables are all the IF's and the dummies for weights
The first Dep variable will be Weights, which are added manually
This is not meant to be used manually. Only within the CSDID
Weights are introduced manually.
This WAS a fun way to get all
*/
program csdid_ols
version 14
	syntax anything
	local my $ML_y
	gettoken wgt my:my
	gettoken lnf 1:0
	qui: {
		replace `lnf'=0
		while "`1'"!="" {
		    local cnt = `cnt'+1
			gettoken xx 1:1
			gettoken yy my:my
			*display in w "`lnf'-(`yy'-`xx')^2 if `yy' !=."
			replace `lnf'=`lnf'-`wgt'*(`yy'-`xx')^2 if `yy' !=. 
		}
	}
end