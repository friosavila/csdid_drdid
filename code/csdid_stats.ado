*! v1 Command for estimating estats from RIF file
program adde, eclass
        ereturn `0'
end

program addr, rclass
        return `0'
end

program csdid_stats, rclass
	syntax [anything],  [wboot] [estore(name) esave(name) replace]
	
	local  `:char _dta[note11]'
	
	if "`cmd'"!="csdid" {
	    display "This was not created after csdid"
		exit 10
	}
	
	forvalues i = 3/10 {
		local  `:char _dta[note`i']'
	}
	
	tempname b1 b2 b3 b4 b5 
	tempname s1 s2 s3 s4 s5 
	
	local agg `anything'
	
	if "`agg'"=="" local agg event
	
	if !inlist("`agg'","attgt","simple","group","calendar","event")  {
		display "Option `agg' not allowed"
		exit 10
	}
	
	
	** New idea. Hacerlo todo desde makerif	
	*mata:makerif("`rifgt'","`rifwt'","__wgt__","`b'","`v'","`cluster' ")

	noisily mata: makerif2("`rifgt'" , "`rifwt'","`agg'",  ///
						    "`glvls'","`tlvls'", ///
							"`b1'",  /// `b2' `b3' `b4' `b5' `b6'
							"`s1'",  ///  `s2' `s3' `s4' `s5' `s6'
							"`clvar' ", "`wboot' ")
	tempname b V
	matrix `b' = `b1'
	matrix `V' = `s1'
	
	if "`agg'"=="attgt" {
		matrix colname `b'=`colname'
		matrix coleq   `b'=`eqname'
		matrix colname `V'=`colname'
		matrix coleq   `V'=`eqname'
		matrix rowname `V'=`colname'
		matrix roweq   `V'=`eqname'
	}
	
	capture:est store `lastreg'	
	ereturn clear
	adde post `b' `V'
	adde local cmd 	   estat
	adde local cmdline estat `agg'
	if "`estore'"!="" est store `estore'
	if "`esave'" !="" est save  `esave', `replace'
	_coef_table
	matrix rtb=r(table)
	qui:est restore `lastreg'
	return matrix table = rtb
	return matrix b `b1'
	return matrix V `s1'

end			


mata:

 vector event_list(real matrix glvl, tlvl){
 	real matrix toreturn
	real scalar i,j
	toreturn=J(1,0,.)
	for(i=1;i<=cols(glvl);i++) {
		for(j=1;j<=cols(tlvl);j++) {
			toreturn=toreturn,(glvl[i]-tlvl[j])
		}
	}
	return(uniqrows(toreturn')')
 }
// Next task. 
// amek all elements separete RIF_siple RIF event, etc
// Think how to save all elements.
		
void makerif2(string scalar rifgt_ , rifwt_ , agg, 
				glvl_, tlvl_, bb_, ss_, clvar_, wboot_ ) {	
					
    real matrix rifgt , rifwt, wgt, t0, glvl, tlvl
	real scalar i,j,k,h
	rifgt	= st_data(.,rifgt_)
	rifwt  	= st_data(.,rifwt_)
	
	/// pg here is just a dummy
	// stp1 all together?? No
	//all=att_gt,pg
	// stp2 get Mean(RIF) 
	// This just rescales the IFs RIF's to make the statistics later.
	
	glvl = strtoreal(tokens(glvl_))	
	tlvl = strtoreal(tokens(tlvl_))	
	
    real matrix ag_rif, ag_wt
	real matrix bb, VV, aux
	real vector ind_gt, ind_wt
	string matrix coleqnm
	real scalar flag 
	/////////////////////////////////////////
	// Always make attgt, even if not shown. 
	if (agg=="attgt") {
		make_tbl( (rifgt,rifwt) ,bb,VV,clvar_,wboot_)
 	}
	/////////////////////////////////////////
	if (agg=="simple") {
		k=0
		ind_gt=J(1,0,.)
		ind_wt=J(1,0,.)
 
		for(i=1;i<=cols(glvl);i++) {
			for(j=1;j<=cols(tlvl);j++) {
				k++
				// G <= T
 				if (glvl[i]<=tlvl[j]) {
					//ag_rif=ag_rif, rifgt[.,k]
					//ag_wt =ag_wt , rifwt[.,i]
					ind_gt=ind_gt,k

				}
 			}
		}
		// Above gets the Right elements Below, aggregates them
		ag_rif = rifgt[.,ind_gt]
		ag_wt  = rifwt[.,ind_gt]
		aux = aggte(ag_rif, ag_wt)
		make_tbl(aux ,bb,VV,clvar_,wboot_)
		coleqnm = "ATT"
	}
	/////////////////////////////////////////
	
	if (agg=="group") {
		// i groups j time
		k=0
		
		aux    =J(rows(rifwt),0,.)
		coleqnm=""
		/// ag_wt=J(rows(rifwt),0,.)
		for(i=1;i<=cols(glvl);i++) {
			ind_gt=J(1,0,.)
		    flag=0
			ag_rif=J(rows(rifwt),0,.)
			for(j=1;j<=cols(tlvl);j++) {
				k++
 				if (glvl[i]<=tlvl[j]) {
					//ag_rif=ag_rif, rifgt[.,k]
					flag=1
					ind_gt=ind_gt,k
 				}
 			}
			if (flag==1)  {
				coleqnm=coleqnm+sprintf(" G%s",strofreal(glvl[i]))
				ag_rif = rifgt[.,ind_gt]
				ag_wt  = rifwt[.,ind_gt]
				aux = aux, aggte(ag_rif, ag_wt)
			}
		}
 
		// get table elements		
		make_tbl(aux ,bb,VV,clvar_,wboot_)
	}	
	/////////////////////////////////////////
	
	if (agg=="calendar") {
		// i groups j time
		aux =J(rows(rifwt),0,.)
		coleqnm=""
		
		for(h=1;h<=cols(tlvl);h++){
			k=0
			flag=0
			ind_gt=J(1,0,.)
			ind_wt=J(1,0,.)	
			/// ag_wt=J(rows(rifwt),0,.)
 
			for(i=1;i<=cols(glvl);i++) {
				for(j=1;j<=cols(tlvl);j++) {
					k++
					if ((glvl[i]<=tlvl[j]) & (tlvl[h]==tlvl[j]) ){
						//ag_rif=ag_rif, rifgt[.,k]
						//ag_wt =ag_wt , rifwt[.,i]
						ind_gt=ind_gt,k
						ind_wt=ind_wt,i						
						if (flag==0) coleqnm=coleqnm+sprintf(" T%s",strofreal(tlvl[h]))
						flag=1
					}
				}
				
			}
			ag_rif = rifgt[.,ind_gt]
			ag_wt  = rifwt[.,ind_gt]			
			aux = aux, aggte(ag_rif, ag_wt)
		}	
		// get table elements		
		make_tbl(aux ,bb,VV,clvar_,wboot_)
	}
	
	if (agg=="event") {
		// i groups j time
		real matrix evnt_lst
		evnt_lst=event_list(glvl,tlvl)
		coleqnm=""
		aux =J(rows(rifwt),0,.)
		for(h=1;h<=cols(evnt_lst);h++){
			k=0
			flag=0
			ind_gt=J(1,0,.)
			ind_wt=J(1,0,.)			
			/// ag_wt=J(rows(rifwt),0,.)
 
			for(i=1;i<=cols(glvl);i++) {
				for(j=1;j<=cols(tlvl);j++) {
					k++					
					if ( (glvl[i]+evnt_lst[h])==tlvl[j] ) {	
						//ag_rif=ag_rif, rifgt[.,k]
						//ag_wt =ag_wt , rifwt[.,i]
						ind_gt=ind_gt,k
						ind_wt=ind_wt,i							
						if (flag==0) {
							if (evnt_lst[h]< 0) coleqnm=coleqnm+sprintf(" T%s" ,strofreal(evnt_lst[h]))
							if (evnt_lst[h]==0) coleqnm=coleqnm+" T"
							if (evnt_lst[h]> 0) coleqnm=coleqnm+sprintf(" T+%s",strofreal(evnt_lst[h]))
						}
						flag=1
					}
				}
				
			}
			ag_rif = rifgt[.,ind_gt]
			ag_wt  = rifwt[.,ind_gt]			
			aux = aux, aggte(ag_rif, ag_wt)
		}	
		// get table elements		
		make_tbl(aux ,bb,VV,clvar_,wboot_)
	}
	
	st_matrix(bb_,bb)
	st_matrix(ss_,VV)
	
	if (agg!="attgt") {
		stata("matrix colname "+bb_+" ="+coleqnm)
		stata("matrix colname "+ss_+" ="+coleqnm)
		stata("matrix rowname "+ss_+" ="+coleqnm)
	}
	
}

void make_tbl(real matrix rif,bb,VV, clv , wboot ){
	real matrix aux, nobs, clvar
	real scalar cln
	bb=mean(rif)
	nobs=rows(rif)
	// simple
	if ((clv==" ") & (wboot==" ")) {	
		VV=quadcrossdev(rif,bb,rif,bb):/ (nobs^2) 
	}
	// cluster std
	if ((clv!=" ") & (wboot==" ")) {
		clvar=st_data(.,clv)
		clusterse((rif:-bb),clvar,VV,cln)
	}
	real matrix cband
	// wboot no cluster
	if ((clv==" ") & (wboot!=" ")) {
		mboot(rif,bb, VV, cband, clv)
	}
	// wboot with cluster
	if ((clv!=" ") & (wboot!=" ")) {
		mboot(rif,bb, VV, cband, clv)
	}
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
	// Esto es para ver como hacer clusters.
	//*nc/(nc-1)
	//st_matrix(V,    vv)
	//st_numscalar(ncl, nc)
	//        ^     ^
	//        |     |
	//      stata   mata
}

 

real colvector aggte(real matrix attg, wgt){
	real scalar atte, mn_attg, mn_wgt
	real vector wgtw, attw
	real matrix r1, r2, r3
	mn_attg = mean(attg)
	mn_wgt  = mean(wgt)
	atte = sum(mn_attg:*mn_wgt):/sum(mn_wgt)
	wgtw = (mn_wgt ) :/sum(mn_wgt)
	attw = (mn_attg) :/sum(mn_wgt)
	r1   = (wgtw:*(attg:-mn_attg))
	r2   = (attw:*(wgt :-mn_wgt ))
	r3   = (wgt :- mn_wgt) :* (atte :/ sum(mn_wgt) )
	return(rowsum(r1):+rowsum(r2):-rowsum(r3):+atte)
    
}


/////////////////////////////////////////////////////////
real matrix mboot_did(real matrix rif, mean_rif, real scalar reps, bwtype) {
	real matrix yy, bsmean
	yy=rif:-mean_rif
 	bsmean=J(reps,cols(yy),0)
	real scalar i,n, k1, k2
	n=rows(yy)
	k1=((1+sqrt(5))/(2*sqrt(5)))
	k2=0.5*(1+sqrt(5)) 
	// WBootstrap:Mammen 
	if (bwtype==1) {			
		for(i=1;i<=reps;i++){
			bsmean[i,]=mean(yy:*(k2:-sqrt(5)*(rbinomial(n,1,1,k1))) )	
		}
	}
	
	else if (bwtype==2) {
		for(i=1;i<=reps;i++){
			bsmean[i,]=mean(yy:*(1:-2*rbinomial(n,1,1,0.5) ) )	
		}
	}
	
	return(bsmean)
}

real matrix mboot_didc(real matrix rif, mean_rif, real scalar reps, bwtype, clv) {
	real matrix yy, bsmean
	yy=rif:-mean_rif
 	bsmean=J(reps,cols(yy),0)
	real scalar i,n, k1, k2, nn
	n=rows(yy)
	k1=((1+sqrt(5))/(2*sqrt(5)))
	k2=0.5*(1+sqrt(5)) 
	real matrix sclv, wmult
	sclv=uniqrows(clv)
	nn=rows(sclv)
	if (bwtype==1) {			
		for(i=1;i<=reps;i++){
		    wmult=(rbinomial(nn,1,1,k1))
			bsmean[i,]=mean(yy:*(k2:-sqrt(5)*wmult[clv] ) )	
		}
	}
	
	else if (bwtype==2) {
		for(i=1;i<=reps;i++){
		    wmult=(rbinomial(nn,1,1,0.5))
			bsmean[i,]=mean(yy:*(1:-2* wmult[clv] ) )	
		}
	}
	
	return(bsmean)
}
 
real matrix iqrse(real matrix y) {
    real scalar q25,q75
	q25=ceil((rows(y)+1)*.25)
	q75=ceil((rows(y)+1)*.75)
	real scalar j
	real matrix iqrs
	iqrs=J(1,cols(y),0)
	for(j=1;j<=cols(y);j++){
	    y=sort(y,j)
		iqrs[,j]=(y[q75,j]-y[q25,j]):/(invnormal(.75)-invnormal(.25) )
	}
	return(iqrs)
}

real vector qtp(real matrix y, real scalar p) {
    real scalar k, i, q
	real matrix yy, qq
	qq=J(1,0,.)
	k = cols(y)
	for(i=1;i<=k;i++){
		yy=sort(y[,i],1)
		q=ceil((rows(yy)+1)*p)    
		qq=qq,yy[q,]
	}
    
	return(qq)
}
 
void mboot(real matrix rif,mean_rif, vv, cband, string scalar clv) {
    //, real scalar reps, bwtype, ci 
    real matrix fr
	real scalar reps, wbtype
	reps   = 999
	wbtype =   1
	ci     = 0.95
	real matrix ifse , ccb
	// this gets the Bootstraped values
	if (clv ==" ") {
		fr=mboot_did(rif,mean_rif, reps, wbtype)
		ifse = iqrse(fr)
		// this gets Tvalue
		cband=( mean_rif':-qtp(abs(fr :/ ifse),ci)':* ifse' ,  
				mean_rif':+qtp(abs(fr :/ ifse),ci)':* ifse'   )
	}
	else {
		clvar=st_data(.,clv)
		fr=mboot_didc(rif,mean_rif, reps, wbtype, clvar)
		
		ifse = iqrse(fr)
		// this gets Tvalue
		
		cband=( mean_rif':-qtp(abs(fr :/ ifse),ci)':* ifse' ,  
				mean_rif':+qtp(abs(fr :/ ifse),ci)':* ifse'   )
	}
	vv=quadcross(ifse,ifse):*I(rows(ifse))
	//sqrt(variance(fr))
	//st_matrix(vv,iqrse(fr)^2)
	//st_matrix(cband,ccb)
}


end

