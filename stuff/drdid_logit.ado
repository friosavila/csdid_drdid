program drdid_logit
args lnf xb
qui replace `lnf'=($ML_y1==1)*(`xb')-(1-$ML_y1)*exp(`xb')
end