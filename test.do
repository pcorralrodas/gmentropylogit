

clear all
do "C:\Users\wb378870\OneDrive - WBG\000.my_ados\gmentropylogit\gmelogit2.do"

sysuse auto

gen pr=0.5
gmentropylogit2 foreign price mpg weight trunk, priors(pr) gen(new1) mfx

