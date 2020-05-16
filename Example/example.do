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
mata: beta_np = st_matrix("e(b)")

//Priors
gmentropylogit `lhs' `rhs', prior(prsars) gen(pred_prior) 

/*
. gmentropylogit `lhs' `rhs', prior(prsars) gen(pred_prior) 
(0 real changes made)
Iteration 0:   log likelihood = -532.82696  
Iteration 1:   log likelihood =  -440.5778  
Iteration 2:   log likelihood = -429.99078  
Iteration 3:   log likelihood = -427.32517  
Iteration 4:   log likelihood =  -425.9924  
Iteration 5:   log likelihood = -425.94484  
Iteration 6:   log likelihood = -425.94479  
Iteration 7:   log likelihood = -425.94479  

Generalized Maximum Entropy (Logit)                Number of obs      =    485
                                                   Degrees of freedom =      8
                                                   Entropy for probs. =  154.1
                                                   Normalized entropy = 0.4583
                                                   Ent. ratio stat.   =  364.2
                                                   P Val for LR       = 0.0000
Criterion F (log L) = -425.94479                   Pseudo R2          = 0.5417
------------------------------------------------------------------------------
        died |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
        nsex |  -.4545328    .361278    -1.26   0.208    -1.162625     .253559
        nage |   .0524186   .0117026     4.48   0.000      .029482    .0753552
     bcg_nev |   5.990727   1.092034     5.49   0.000     3.850379    8.131075
    bcg_past |   2.647151   1.066435     2.48   0.013     .5569768    4.737326
       immsl |  -.0924968   .0492515    -1.88   0.060     -.189028    .0040344
       ihepb |   .1665755   .0472207     3.53   0.000     .0740246    .2591265
       phexp |  -.0018965   .0007301    -2.60   0.009    -.0033275   -.0004655
       diehh |   .0286866   .0074354     3.86   0.000     .0141134    .0432598
       _cons |  -10.92482   2.977509    -3.67   0.000    -16.76063   -5.089007
------------------------------------------------------------------------------
Percent correctly predicted:89.690722

*/
mata: beta_p = st_matrix("e(b)")

//Ratio of beta with prior to beta with no prior
mata beta_p:/beta_np

// You can also check the MFX which also differ...

export excel using "C:\Users\wb378870\OneDrive - WBG\000.my_ados\gmentropylogit\Example\Corona485_obs_sample.xlsx", sheet("Sheet2") sheetreplace first(var) 
