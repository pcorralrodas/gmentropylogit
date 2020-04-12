*! gmentropylogit 2.0 April 10, 2020 PC & MT
cap program drop gmentropylogit2
program define gmentropylogit2, eclass byable(recall)
	version 13, missing
#delimit;
	syntax varlist(min=2 numeric fv) [if] [in],
	[
		Mfx 
		GENerate(string)
		Priors(varlist numeric max=1)
	];
#delimit cr
set more off

qui{
	// Check to see if first variable is binary
	tokenize `varlist'	
	qui: tab `1' if `touse'
	if r(r)!=2{
		display as error "You must specify a binary variable"
		error 498
	}  
	
	// Local for dependent variable
	local dep1 `1'
	tempvar dep2
	qui:gen byte `dep2'=`dep1'==0 if `touse'
	
	local depvars `dep1' `dep2'
	
	// obtain the independent variables
	macro shift 
	local indeps `*'
	
	//Remove collinear exolanatory vars
	_rmcoll `indeps' if `touse', forcedrop
	local indeps  `r(varlist)'
	
	if "`mfx'"=="mfx" {
		//Indicate dummy variables for MFX
		local words=wordcount("`indeps'")
		tempname dummy
		matrix `dummy'=J(1,`words',0)
		
		forvalues x= 1/`words'{		
			capture assert ``x''==1 | ``x''==0
			if  _rc==0 {
				qui: tab ``x''
				if r(r)==2{
					matrix `dummy'[1,`x']=1
				}
			}
		}
				
		mata: gme_discretemfx("`depvars'", "`indeps'", "`dummy'", "`touse'")
	}
	else{
		mata: gme_discrete("`depvars'", "`indeps'", "`dummy'", "`touse'")
	}

	tempname b b2 V
	mat `b' = r(beta)
	mat `V' = r(V)
	mat `b2'= r(beta2)
	
	// Predicted values
	if "`generate'"!=""{
		tokenize `generate'			
		local wc=wordcount("`generate'")
		if `wc'!=1{
			display as error "You must specify a name for predicted variable, only one"
		}
		else{
			capture confirm name `1'
			if _rc!=0{
				display as error "Invalid name for new variable"
			}
			else{
				capture confirm variable `1'
				if _rc==0{
					display as error "For predicted values, specify variable not already in use"
				}
				else{
					qui: gen `generate'=. if `touse'
				
					if "`mfx'"==""{
						mata:predict_gme("`indeps'", "`b'", "`generate'", "`touse'")
					}
					else{
						mata:predict_gme("`indeps'", "`b2'", "`generate'", "`touse'")
					}
				}
			}
		}
	}
	
	//  Matrix for  results
	mat colnames `b'  = `indeps' _cons
	mat colnames `V'  = `indeps' _cons
	mat rownames `V'  = `indeps' _cons
	
	// Number of observations
	local N = r(N)
		
	ereturn post `b' `V', depname(`dep1') obs(`N') esample(`touse')
	
	// Statistics
	
	//Number of observations
	ereturn scalar N = r(N)
	//Degs of freedom
	ereturn scalar d_fm = (r(K)-1)
	//Log likelihood 
	ereturn scalar lnf = r(lnf)
	//Log likelihood 
	ereturn scalar lnf0 = r(lnf0) 
	//Normalized entropy
	ereturn scalar Sp = r(Sp)
	//Pseudo R2
	ereturn scalar R2 = (1- r(Sp))
	//Entropy for probs.
	ereturn scalar S = r(S)
	//Entropy ratio statistic
	ereturn scalar ERS = 2*r(N)*ln(2)*(1- r(Sp))
	// P value for LR
	ereturn scalar pv = chiprob(e(d_fm),e(ERS))
	
	//	 Generate correct prediction percent
	
	if "`generate'"!=""	{
		tempvar correct  predicted
		qui: gen byte `predicted' = `generate'>=0.5
		qui: gen byte `correct' = (`predicted'==1 & `dep1'==1) | (`predicted'==0 & `dep1'==0)
		qui: sum `correct'
		ereturn scalar pred = r(mean)*100
	}
	
	/// Result table
	if "`mfx'"!=""{
		display _newline in gr "Generalized Maximum Entropy (Logit), dF/dx" _col(52) in gr "Number of obs" _col(71) in gr "=" _col(72) in ye %7.0f e(N)
	}
	else{
		display _newline in gr "Generalized Maximum Entropy (Logit)" _col(52) in gr "Number of obs" _col(71) in gr "=" _col(72) in ye %7.0f e(N)
	}

	display _col(52) in gr "Degrees of freedom" _col(71) in gr "=" _col(72) in ye %7.0f e(d_fm)
	display _col(52) in gr "Entropy for probs." _col(71) in gr "=" _col(72) in ye %7.1f e(S)
	display _col(52) in gr "Normalized entropy" _col(71) in gr "="  _col(72) in ye %7.4f e(Sp)
	display _col(52) in gr "Ent. ratio stat." _col(71) in gr "="  _col(72) in ye %7.1f e(ERS)
	display _col(52) in gr "P Val for LR" _col(71) in gr "="  _col(72) in ye %7.4f e(pv)
	display _col(1) in gr "Criterion F (log L) = "  in ye e(lnf) _col(52) in gr "Pseudo R2" _col(71) in gr "=" _col(72)  in ye %7.4f e(R2)
	ereturn display
	if "`mfx'"!=""{
		display _col(1) in gr "Partial effect for dummy is E[y|x,d=1] - E[y|x,d=0]"
	}
	if "`generate'"!=""{
		display _col(1) in gr "Percent correctly predicted:"  in ye e(pred)
	}

}

end
