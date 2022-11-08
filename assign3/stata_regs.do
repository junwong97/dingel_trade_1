*** Assignment 3 ***
*** 11/2/2022 ***

clear *

* Set paths
local main "/Users/junwong/Dropbox/Second Year/Dingel - Trade/assignments"
cd "`main'"

* Table options 
global general label replace se b(%9.3f) star(* 0.10 ** 0.05 *** .01) nonotes nogaps fragment nomtitles

* Import data
import delimited "data/Detroit.csv", varn(1) encoding("utf8")

gen log_flows = log(flows)
gen log_distance = log(distance_google_miles)
gen log_duration = log(duration_minutes)
lab var log_distance "Log(Driving Distance)"
lab var log_duration "Log(Driving Time)"

**************************************
*** Table 1: Log linear estimation ***
**************************************

foreach var of varlist log_distance log_duration {
	
	if "`var'"=="log_distance" {
		local panel "{\bf Panel A: Log(Driving Distance)}"
		local header "\toprule"
		local footer "\midrule"
	} 
	else {
		local panel "{\bf Panel B: Log(Driving Duration)}"
		local header ""
		local footer "\bottomrule"
	}
	
	est clear 
	timer clear 
	
	* reg
	timer on 1 
	qui eststo: reg log_flows `var' i.work_id i.home_id
	timer off 1
	estadd local workfe "Yes": est1 
	estadd local homefe "Yes": est1
	estadd local rtype "\texttt{reg}": est1 
	
	
	* xtreg
	xtset work_id home_id
	timer on 2
	qui eststo: xtreg log_flows `var' i.home_id, fe
	timer off 2
	estadd local workfe "Yes": est2
	estadd local homefe "Yes": est2
	estadd local rtype "\texttt{xtreg}": est2
	
	* areg 
	xtset, clear 
	timer on 3 
	qui eststo: areg log_flows `var' i.home_id, absorb(work_id)
	timer off 3
	estadd local workfe "Yes": est3
	estadd local homefe "Yes": est3
	estadd local rtype "\texttt{areg}": est3
	
	* reghdfe 
	timer on 4 
	qui eststo: reghdfe log_flows `var', absorb(home_id work_id)
	timer off 4 
	estadd local workfe "Yes": est4
	estadd local homefe "Yes": est4
	estadd local rtype "\texttt{reghdfe}": est4
	
	timer list 
	forvalues i=1/4 {
		local timed : di %9.3fc `r(t`i')'
		estadd local time "`timed'": est`i'
	}
	
	esttab est* using "output/table_1_`var'.tex", $general keep(`var') ///
	postfoot("`footer' \end{tabular} \\ ") ///
	stats(N r2 workfe homefe rtype time, fmt(%9.0fc %9.3fc) ///
	labels("N" "\$R^2\$" "Destination FE" "Origin FE" "Command" "Run Time")) ///
	prehead("\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} \begin{tabular}{l*{4}{>{\centering\arraybackslash}p{0.09\textwidth}}} `header' \\ \multicolumn{5}{c}{`panel'} \\ \\ \multicolumn{5}{l}{Dependent Variable: Log(Flows)} \\ ") 

}


**********************
*** Table 2: Zeros ***
**********************

* Make variables 
gen log_flows_plus1 = log(flows+1)
gen log_flows_plus001 = log(flows + 0.01)

* Get x_jj 
gen xjj = flows if home_id == work_id 
bys work_id: egen work_xjj = max(xjj) //103 pairs are 0 
replace work_xjj = work_xjj / 10000000000

gen flows_xjj = flows 
replace flows_xjj = work_xjj if flows_xjj==0 
gen log_flows_xjj = log(flows_xjj)

* Regressions 
est clear 
timer clear 

timer on 1 
eststo: reghdfe log_flows log_distance, absorb(home_id work_id)
timer off 1
estadd local workfe "Yes": est1 
estadd local homefe "Yes": est1
estadd local rtype "\texttt{reghdfe}": est1 

timer on 2
eststo: reghdfe log_flows_plus1 log_distance if flows!=0, absorb(home_id work_id)
timer off 2
estadd local workfe "Yes": est2
estadd local homefe "Yes": est2
estadd local rtype "\texttt{reghdfe}": est2

timer on 3
eststo: reghdfe log_flows_plus1 log_distance, absorb(home_id work_id)
timer off 3
estadd local workfe "Yes": est3
estadd local homefe "Yes": est3
estadd local rtype "\texttt{reghdfe}": est3

timer on 4
eststo: reghdfe log_flows_plus001 log_distance, absorb(home_id work_id)
timer off 4
estadd local workfe "Yes": est4
estadd local homefe "Yes": est4
estadd local rtype "\texttt{reghdfe}": est4

timer on 5
eststo: reghdfe log_flows_xjj log_distance, absorb(home_id work_id)
timer off 5
estadd local workfe "Yes": est5
estadd local homefe "Yes": est5
estadd local rtype "\texttt{reghdfe}": est5

timer on 6
eststo: poi2hdfe flows log_distance, id1(home_id) id2(work_id)
timer off 6
estadd local workfe "Yes": est6
estadd local homefe "Yes": est6
estadd local rtype "\texttt{poi2hdfe}": est6

timer on 7
eststo: ppmlhdfe flows log_distance, a(home_id work_id)
timer off 7
estadd local workfe "Yes": est7
estadd local homefe "Yes": est7
estadd local rtype "\texttt{ppmlhdfe}": est7

timer on 8
eststo: ppmlhdfe flows log_distance if flows!=0, a(home_id work_id)
timer off 8 
estadd local workfe "Yes": est8
estadd local homefe "Yes": est8
estadd local rtype "\texttt{ppmlhdfe}": est8

timer list 
forvalues i=1/8 {
	local timed : di %9.3fc `r(t`i')'
	estadd local time "`timed'": est`i'
}

esttab est* using "output/table_2_log_distance.tex", $general keep(log_distance) ///
	postfoot("\bottomrule \end{tabular} \\ ") ///
	stats(N r2 workfe homefe rtype time, fmt(%9.0fc %9.3fc) ///
	labels("N" "\$R^2\$" "Destination FE" "Origin FE" "Command" "Run Time")) ///
	prehead("\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} \begin{tabular}{l*{8}{>{\centering\arraybackslash}p{0.12\textwidth}}} \toprule \\ \\ Dependent Variable: & Log(\$x\$) & \multicolumn{2}{c}{Log(\$x+1\$)} & \multicolumn{1}{c}{Log(\$x+.001\$)} & \multicolumn{1}{c}{Log(\$\frac{x_{jj}}{1e^{10}}\$)} & \multicolumn{3}{c}{x} \\ \cmidrule(lr){2-2} \cmidrule(lr){3-4} \cmidrule(lr){5-5} \cmidrule(lr){6-6} \cmidrule(lr){7-9} ") 

***************************
*** Figure 1: Residuals ***
***************************
cap drop resids fitted 
qui reghdfe log_flows log_distance, absorb(home_id work_id) resid(resids)
predict fitted

qui reg log_flows log_distance i.home_id i.work_id
qui hettest
local bpchi2 : di %9.3fc `r(chi2)'

set scheme plotplain
binscatter resids fitted if flows!=0 & fitted <= 2.5, nq(100) linetype(none) ///
	xtitle("Residuals") ytitle("Fitted Values") text(0.02 1.35 "Breusch-Pagan test statistic: `bpchi2'",size(small)) ///
	color(edkblue%80)
gr export "output/residuals_bin.pdf", replace 

twoway scatter resids fitted if flows!=0 & fitted <= 2.5, ///
	xtitle("Residuals") ytitle("Fitted Values") ///
	color(edkblue%80)
gr export "output/residuals_scatter.pdf", replace 
	
******************************************
*** Table 3: Comparing across programs ***
******************************************

* Here, let's use robust errors 
est clear 
timer clear 

timer on 1
qui eststo: reghdfe log_flows log_distance, absorb(home_id work_id) vce(robust)
timer off 1
estadd local workfe "Yes": est1
estadd local homefe "Yes": est1
estadd local rtype "\texttt{reghdfe}": est1

timer on 2
qui eststo: reghdfe log_flows log_duration, absorb(home_id work_id) vce(robust)
timer off 2
estadd local workfe "Yes": est2
estadd local homefe "Yes": est2
estadd local rtype "\texttt{reghdfe}": est2

timer list 
forvalues i=1/2 {
	local timed : di %9.3fc `r(t`i')'
	estadd local time "`timed'": est`i'
}

esttab est* using "output/table_3_stata.tex", $general keep(log_distance log_duration) ///
	postfoot("\bottomrule \end{tabular} \\ ") ///
	stats(N r2 workfe homefe rtype time, fmt(%9.0fc %9.3fc) ///
	labels("N" "\$R^2\$" "Destination FE" "Origin FE" "Command" "Run Time")) ///
	prehead("\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} \begin{tabular}{l*{2}{>{\centering\arraybackslash}p{0.09\textwidth}}} \toprule \\ \multicolumn{2}{l}{Dependent Variable: Log(Flows)} \\ ") 



