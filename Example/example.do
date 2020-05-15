set more off
clear all

run "C:\Users\wb378870\OneDrive - WBG\000.my_ados\gmentropylogit\gmentropylogit.ado"

//Import data
import excel "C:\Users\wb378870\OneDrive - WBG\000.my_ados\gmentropylogit\Example\Corona485_obs_sample.xlsx", sheet("Sheet1") first clear

//sample 50, count
gen double prsars = .
//Prior for Males
replace prsars=0.077 if nsex==0 & nage<=44
replace prsars=0.326 if nsex==0 & nage>44 & nage<=74
replace prsars=0.647 if nsex==0 & nage>74

//Prior for Females
replace prsars=0.037 if nsex==1 & nage<=44
replace prsars=0.245 if nsex==1 & nage>44 & nage<=74
replace prsars=0.636 if nsex==1 & nage>74

sum prsar

//Locals for model
local lhs  died 
local rhs nsex nage bcg_nev bcg_past immsl ihepb phexp diehh

//Logit
//logit `lhs' `rhs'
//predict pred_logit, pr

//No priors
gmentropylogit `lhs' `rhs', gen(pred_noprior) 
sss
mata: beta_np = st_matrix("e(b)")

//Priors
gmentropylogit `lhs' `rhs', prior(prsars) gen(pred_prior) 
mata: beta_p = st_matrix("e(b)")

//Ratio of beta with prior to beta with no prior
mata beta_p:/beta_np

// You can also check the MFX which also differ...

export excel using "C:\Users\wb378870\OneDrive - WBG\000.my_ados\gmentropylogit\Example\Corona485_obs_sample.xlsx", sheet("Sheet2") sheetreplace first(var) 
