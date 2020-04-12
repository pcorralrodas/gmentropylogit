

clear all
do "C:\Users\wb378870\OneDrive - WBG\000.my_ados\gmentropylogit\gmentropylogit.ado"

sysuse auto

gen pr=0.5
gmentropylogit foreign price mpg weight trunk, priors(pr) gen(new1) 

