texdoc init newAnalysis.tex, logdir(newAnalysislogfiles) replace

/*tex
\documentclass[11pt,reqno]{amsart}
\usepackage{fullpage}
\usepackage{graphicx}
\usepackage{stata}
\usepackage{setspace}
\usepackage{float}
\usepackage{subfigure}
\usepackage{xcolor}
\usepackage[bookmarks]{hyperref}
\usepackage{booktabs}
\renewcommand{\arraystretch}{0.75}
\setlength{\parskip}{\baselineskip}
\setlength{\parindent}{0pt}
%\setlength{\parskip}{0pt}
%\setlength{\parindent}{2em}
\setlength{\footskip}{0.5in}
%\setstretch{1.2}
\usepackage[authoryear]{natbib}
\newcommand{\possessivecite}[1]{\citeauthor{#1}'s \citeyear{#1}}
\bibpunct{(}{)}{;}{;}{,}{,}
\usepackage{enumitem}
\setlist[itemize,1]{listparindent=0pt,parsep=11pt}
\setlist[enumerate,1]{listparindent=0pt,parsep=11pt}
\usepackage{dcolumn}    % aligning decimals
    \newcolumntype{d}[1]{D{.}{.}{#1}}
\makeatletter
\def\@fnsymbol#1{\ifcase#1\or *\or **\fi\relax}
\renewcommand{\section}{\@startsection%
  {section}%
  {1}%
  {0mm}%
  {-1.2\baselineskip}%
  {0.5\baselineskip}%
  {\centering\scshape\normalsize}}
\renewcommand{\subsection}{\@startsection%
  {subsection}%
  {1}%
  {0mm}%
  {-1.4\baselineskip}%
  {0.5em}%
  {\centering\bfseries\normalsize}}
\renewcommand{\subsubsection}{\@startsection%
  {subsubsection}%
  {2}%
  {0mm}%
  {-0em}%
  {0.5em}%
  {\itshape\normalsize}}
\makeatother
\setcounter{secnumdepth}{2}
\renewcommand{\floatpagefraction}{1.00}
\renewcommand{\topfraction}{1.00}
\renewcommand{\textfraction}{0.00}
\newcommand{\eqs}{\buildrel s \over =}
\let\IG\iffalse
\let\ENDIG\fi
\newcommand{\LR}{\Leftrightarrow}
\newcommand{\half}{\tfrac{1}{2}}
\newcommand{\thrd}{\tfrac{1}{3}}
\newcommand{\sxth}{\tfrac{1}{6}}
\newcommand{\xb}{\overline{x}}
\begin{document}

Initialize switch
tex*/

texdoc stlog, do
local dorest = 0
texdoc stlog close

/*tex
\section{Load the clean data saved by getcleanDataAll.do}
tex*/

texdoc stlog, do
use cleanDataAll, clear
texdoc stlog close

/*tex
Generate a dummy \verb~switched~ indicating if people were switched from their
intial \verb~wantinfo~ choice
tex*/

texdoc stlog, do
gen switched = getinfo != wantinfo
texdoc stlog close

/*tex
Plot the distribution of WTA across those switched from their initial
\verb~wantinfo~ choice and those not switched.
tex*/

texdoc stlog, nodo
summ valinfo if !wantinfo & !getinfo

summ valinfo if !wantinfo & getinfo

summ valinfo if wantinfo & !getinfo

summ valinfo if wantinfo & getinfo

summ valinfo if !switched 
local mean_n = round(r(mean), .01)

summ valinfo if switched
local mean_s = round(r(mean), .01)

gen valinfoh = valinfo
replace valinfoh = 0 if valinfo == -0.01 | valinfo == 0.01

#delimit ;
twoway 
  (histogram valinfoh if !switched, 
     density discrete width(0.5) start(-5) fcolor(red) color(red)) 
  (histogram valinfoh if switched, 
     density discrete width(0.5) start(-5) fcolor(none) lcolor(blue) lwidth(medthick)) 
  (scatteri 0 `mean_s' .86 `mean_s', 
     connect(l) msymbol(i) lcolor(red) lwidth(thick) lpattern(dash))  
  (scatteri 0 `mean_n' .86 `mean_n', 
     connect(l) msymbol(i) lcolor(blue) lwidth(thick) lpattern(dash))  
  , 
  yscale(range(0 0.9)) ylabel(0(0.2)1.4) ytitle("Density") 
  xscale(range(-5 5)) 
  xtitle("Value of information") 
  text(0.86 `mean_s' "`mean_s'", place(n)) 
  text(0.86 `mean_n' "`mean_n'", place(n)) 
  xlabel(-5(1)5) 
  legend(order(1 "Not switched" 2 "Switched") ring(0) pos(2) col(1)) 
  graphregion(color(white))
;
#delimit cr

graph export figures/valinfo_ns.pdf, replace
texdoc stlog close

*texdoc write \begin{figure}[H]
*texdoc write \centering\includegraphics[width=\textwidth]{figures/valinfo_ns}
*texdoc write \end{figure}

/*tex
Define a \verb~treatmenth~ variable that is labeled and ordered more
conveniently than the \verb~treatment~ one in the dataset.
tex*/

texdoc stlog, do
label define treatlbl 1 "Control" 2 "TSe" 3 "TFc"
gen treatmenth = "" 
replace treatmenth = "Control" if treatment == "TN"
replace treatmenth = "Self-efficacy" if treatment == "TS"
replace treatmenth = "Future concern" if treatment == "TF"
encode treatmenth, gen(treatcat) label(treatlbl)
texdoc stlog close

/*tex
Also define treatment dummies
tex*/

texdoc stlog, do
mark TN if treatment == "TN"
mark TS if treatment == "TS"
mark TF if treatment == "TF"
label var TS "TS"
label var TF "TH"
texdoc stlog close

/*tex
Plot the shares of meals chosen across treatments, separately
for subjects who neither wanted nor got info, and subjects who
both wanted and got info
tex*/

texdoc stlog, do
gen chosemeal1 = 0
gen chosemeal2 = 0
gen chosemeal3 = 0
gen chosemeal4 = 0
replace chosemeal1 = 1 if mealchoice == 1
replace chosemeal2 = 1 if mealchoice == 2
replace chosemeal3 = 1 if mealchoice == 3
replace chosemeal4 = 1 if mealchoice == 4
texdoc stlog close


texdoc stlog, nodo
#delimit ;
graph bar (mean)
    chosemeal1 chosemeal2 chosemeal3 chosemeal4 if !wantinfo & !getinfo,
    over(treatcat, gap(150))
    bargap(0)
    ytitle("Share of subjects that chose each meal", margin(medium))
    blabel(bar, size(vsmall) format(%4.2f))
    legend(
      label(1 "Gnocchi (980 cal)") 
      label(2 "RFajita (780 cal)") 
      label(3 "Nicoise (640 cal)") 
      label(4 "MiddleE (430 cal)") 
      symxsize(*.65) size(small) cols(4) position(6)
  )
  ylabel(0(0.1)0.55, labsize(small))
  graphregion(color(white))
  scheme(white_tableau)
;
#delimit cr

graph export figures/chosemeal_nn.pdf, replace

#delimit ;
graph bar (mean)
    chosemeal1 chosemeal2 chosemeal3 chosemeal4 if wantinfo & getinfo,
    over(treatcat, gap(150))
    bargap(0)
    ytitle("Share of subjects that chose each meal", margin(medium))
    blabel(bar, size(vsmall) format(%4.2f))
    legend(
      label(1 "Gnocchi (980 cal)") 
      label(2 "RFajita (780 cal)") 
      label(3 "Nicoise (640 cal)") 
      label(4 "MiddleE (430 cal)") 
      symxsize(*.65) size(small) cols(4) position(6)
  )
  ylabel(0(0.1)0.55, labsize(small))
  graphregion(color(white))
  scheme(white_tableau)
;
#delimit cr

graph export figures/chosemeal_ii.pdf, replace
texdoc stlog close

*texdoc write \begin{figure}[H]
*texdoc write \caption{Meal choices of deliberately uninformed subjects.\label{fig:ch_nn}}
*texdoc write \centering\includegraphics[width=\textwidth]{figures/chosemeal_nn}
*texdoc write \end{figure}
*
*texdoc write \begin{figure}[H]
*texdoc write \caption{Meal choices of deliberately informed subjects.\label{fig:ch_ii}}
*texdoc write \centering\includegraphics[width=\textwidth]{figures/chosemeal_ii}
*texdoc write \end{figure}

/*tex
Regress meal choices on treatment dummies
tex*/

texdoc stlog, do
forvalues i = 1/4 {
    reg chosemeal`i' TS TF if !wantinfo & !getinfo
    reg chosemeal`i' TS TF if wantinfo & getinfo
}
texdoc stlog close


/*tex
Regress full calories from meals chosen, ignoring how much the
subjects ate, on treatment dummies, only for those not switched from their info
choice
tex*/

texdoc stlog, do
reg calfull TS TF if !switched
texdoc stlog close

/*tex
Regress actual calories from meals chosen, accounting for how much the
subjects ate, on treatment dummies, only for those not switched from their info
choice
tex*/

texdoc stlog, do
reg calcons TS TF if !switched
texdoc stlog close

/*tex
Regress full calories from meals chosen, ignoring how much the
subjects ate, on treatment dummies, only for subjects not switched
tex*/

texdoc stlog, do

reg calfull TS TF if !wantinfo & !getinfo
estimates store cf_nn

reg calfull TS TF if !wantinfo &  getinfo
estimates store cf_ni

reg calfull TS TF if  wantinfo & !getinfo
estimates store cf_in

reg calfull TS TF if  wantinfo &  getinfo
estimates store cf_ii

#delimit ;
esttab cf_nn cf_ni cf_in cf_ii using tables/cf.tex, replace
  b(a3) se(a3)
  star( * 0.10 ** 0.05 *** 0.01)
  label booktabs noomitted notes
  mtitles("U $\rightarrow$ U" "U $\rightarrow$ I" "I $\rightarrow$ U" "I $\rightarrow$ I")
  alignment(
    D{.}{.}{1.3}
    D{.}{.}{1.3}
    D{.}{.}{1.3}
    D{.}{.}{1.3}
  )
  stats(
    r2 N, fmt(%6.3f %6.0fc) 
    layout("\multicolumn{1}{c}{@}"
           "\multicolumn{1}{c}{@}")
    labels(`"\$R^{2}\$"' `"\$N\$"')
  )
  width(1.0\hsize) 
  substitute(
  "1.03e-34" "0.000"
  "1.81e-57" "0.000"
  "6.86e-94" "0.000"
  "1.33e-73" "0.000"
  )
;
#delimit cr
texdoc stlog close

*texdoc write \begin{table}[H]
*texdoc write \caption{Treatment effects on calorie consumption, not
*texdoc write adjusted for share of meal consumed.\label{reg:cf}}
*texdoc write \input{tables/cf}
*texdoc write \end{table}

/*tex
Same, but only for non-switched subjects, so combining 
$U \rightarrow U$ and $I \rightarrow I$
tex*/

texdoc stlog, do

reg calfull TS TF if !switched
estimates store cf_ns

#delimit ;
esttab cf_ns using tables/cf_ns.tex, replace
  b(a3) se(a3)
  star( * 0.10 ** 0.05 *** 0.01)
  label booktabs noomitted notes
  mtitles("Not switched")
  alignment(
    D{.}{.}{1.3}
  )
  stats(
    r2 N, fmt(%6.3f %6.0fc) 
    layout("\multicolumn{1}{c}{@}"
           "\multicolumn{1}{c}{@}")
    labels(`"\$R^{2}\$"' `"\$N\$"')
  )
  width(0.3\hsize) 
;
#delimit cr
texdoc stlog close

*texdoc write \begin{table}[H]
*texdoc write \caption{Treatment effects on calorie consumption, not
*texdoc write adjusted for share of meal consumed.\label{reg:cf_ns}}
*texdoc write \input{tables/cf_ns}
*texdoc write \end{table}

/*tex
Regress calories actually consumed, taking account of how much the
subjects ate, on treatment dummies
tex*/

texdoc stlog, do

reg calcons TS TF if !wantinfo & !getinfo
estimates store cc_nn

reg calcons TS TF if !wantinfo &  getinfo
estimates store cc_ni

reg calcons TS TF if  wantinfo & !getinfo
estimates store cc_in

reg calcons TS TF if  wantinfo &  getinfo
estimates store cc_ii

#delimit ;
esttab cc_nn cc_ni cc_in cc_ii using tables/cc.tex, replace
  b(a3) se(a3)
  star( * 0.10 ** 0.05 *** 0.01)
  label booktabs noomitted notes
  mtitles("U $\rightarrow$ U" "U $\rightarrow$ I" "I $\rightarrow$ U" "I $\rightarrow$ I")
  alignment(
    D{.}{.}{1.3}
    D{.}{.}{1.3}
    D{.}{.}{1.3}
    D{.}{.}{1.3}
  )
  stats(
    r2 N, fmt(%6.3f %6.0fc) 
    layout("\multicolumn{1}{c}{@}"
           "\multicolumn{1}{c}{@}")
    labels(`"\$R^{2}\$"' `"\$N\$"')
  )
  width(1.0\hsize) 
  substitute(
  "1.03e-34" "0.000"
  "1.81e-57" "0.000"
  "6.86e-94" "0.000"
  "1.33e-73" "0.000"
  )
;
#delimit cr
texdoc stlog close

*texdoc write \begin{table}[H]
*texdoc write \caption{Treatment effects on calorie consumption,
*texdoc write adjusted for share of meal consumed.\label{reg:cc}}
*texdoc write \input{tables/cc}
*texdoc write \end{table}

/*tex
Same, but only for non-switched subjects, so combining 
$U \rightarrow U$ and $I \rightarrow I$
tex*/

texdoc stlog, do

reg calcons TS TF if !switched
estimates store cc_ns

#delimit ;
esttab cc_ns using tables/cc_ns.tex, replace
  b(a3) se(a3)
  star( * 0.10 ** 0.05 *** 0.01)
  label booktabs noomitted notes
  mtitles("Not switched")
  alignment(
    D{.}{.}{1.3}
  )
  stats(
    r2 N, fmt(%6.3f %6.0fc) 
    layout("\multicolumn{1}{c}{@}"
           "\multicolumn{1}{c}{@}")
    labels(`"\$R^{2}\$"' `"\$N\$"')
  )
  width(0.3\hsize) 
;
#delimit cr
texdoc stlog close

*texdoc write \begin{table}[H]
*texdoc write \caption{Treatment effects on calorie consumption,
*texdoc write adjusted for share of meal consumed.\label{reg:cc_ns}}
*texdoc write \input{tables/cc_ns}
*texdoc write \end{table}

/*tex
Effect on unadjusted calorie consumption of having information vs. not 
(so going from $U \rightarrow U$ to $U \rightarrow I$ or $I \rightarrow U$ to $I \rightarrow I$), 
separately for the two treatments.
tex*/

texdoc stlog, do

preserve
keep if TS
reg calfull getinfo 
estimates store cf_iS

#delimit ;
esttab cf_iS using tables/cf_iS.tex, replace
  b(a3) se(a3)
  star( * 0.10 ** 0.05 *** 0.01)
  label booktabs noomitted notes
  alignment(
    D{.}{.}{1.3}
  )
  stats(
    r2 N, fmt(%6.3f %6.0fc) 
    layout("\multicolumn{1}{c}{@}"
           "\multicolumn{1}{c}{@}")
    labels(`"\$R^{2}\$"' `"\$N\$"')
  )
  width(0.3\hsize) 
;
#delimit cr
restore
texdoc stlog close

*texdoc write \begin{table}[H]
*texdoc write \caption{Information effect on calorie consumption, not
*texdoc write adjusted for share of meal consumed, with self-efficacy
*texdoc write pre-nudge\label{reg:cf_iS}}
*texdoc write \input{tables/cf_iS}
*texdoc write \end{table}


/*tex
Mean value of information for the four groups
tex*/

texdoc stlog, do
label var valinfo "Mean value"
eststo m1: estpost summ valinfo if !wantinfo & !getinfo
eststo m2: estpost summ valinfo if !wantinfo &  getinfo
eststo m3: estpost summ valinfo if  wantinfo & !getinfo
eststo m4: estpost summ valinfo if  wantinfo &  getinfo

#delimit ;
esttab m1 m2 m3 m4 using tables/meanvalinfo.tex, replace
 cells("mean(fmt(2))")
 booktabs nonotes nonumbers
 mtitles("N $\rightarrow$ N" "N $\rightarrow$ I" "I $\rightarrow$ N" "I $\rightarrow$ I")
 collabels(none)
 varlabels(valinfo "Mean value")
 substitute(
    "-2.34" "--\\$2.34"
    "-0.70" "--\\$0.70"
    "0.97" "\\$0.97"
    "2.24" "\\$2.24"
 )
 width(0.6\hsize) 
;
#delimit cr

texdoc stlog close

*texdoc write \begin{table}[H]
*texdoc write \caption{Mean value of information across subgroups\label{tbl:meanvalinfo}}
*texdoc write \input{tables/meanvalinfo2}
*texdoc write \end{table}

/*tex
Regress share of meal consumed on treatment dummies, only for subjects not
switched 
tex*/

texdoc stlog, do
reg mealsh TS TF if !wantinfo & !getinfo
estimates store ms_nn

reg mealsh TS TF if !wantinfo &  getinfo
estimates store ms_ni

reg mealsh TS TF if  wantinfo & !getinfo
estimates store ms_in

reg mealsh TS TF if  wantinfo &  getinfo
estimates store ms_ii

#delimit ;
esttab ms_nn ms_ni ms_in ms_ii using tables/ms.tex, replace
  b(a3) se(a3)
  star( * 0.10 ** 0.05 *** 0.01)
  label booktabs noomitted notes
  mtitles("U $\rightarrow$ U" "U $\rightarrow$ I" "I $\rightarrow$ U" "I $\rightarrow$ I")
  alignment(
    D{.}{.}{1.3}
    D{.}{.}{1.3}
    D{.}{.}{1.3}
    D{.}{.}{1.3}
  )
  stats(
    r2 N, fmt(%6.3f %6.0fc) 
    layout("\multicolumn{1}{c}{@}"
           "\multicolumn{1}{c}{@}")
    labels(`"\$R^{2}\$"' `"\$N\$"')
  )
  width(0.7\hsize) 
  substitute(
  "1.10e-19" "0.000"
  "5.03e-65" "0.000"
  )
;
#delimit cr
texdoc stlog close

*texdoc write \begin{table}[H]
*texdoc write \caption{Treatment effects on share of meal consumed.\label{reg:ms}}
*texdoc write \input{tables/ms}
*texdoc write \end{table}

/*tex
\newpage
Regress probability of wanting information on treatment dummies with the main covariates
tex*/

texdoc stlog, do

label var female "Female"
label var hungrylvl "Hungrylvl"
label var foodsc "Foodsc"
label var weightimp "Weightimp"
label var dieting "Dieting"
label var healthlit "Healthlit"

reg valinfo TS TF `covariates'

#delimit ;
local covariates "
    female
    hungrylvl
    foodsc
    BMI
    weightimp
    dieting
    healthlit
"
;
#delimit cr
reg wantinfo TS TF `covariates' 
estimates store wantinfo_c

reg valinfo TS TF `covariates' 
estimates store valinfo_c

#delimit ;
esttab wantinfo_c valinfo_c using tables/covariates.tex, replace
  b(a3) se(a3)
  star( * 0.10 ** 0.05 *** 0.01)
  label booktabs noomitted notes
  mtitle("Information uptake" "Value of information")
  alignment(
    D{.}{.}{1.3}
    D{.}{.}{1.3}
  )
  stats(
    r2 N, fmt(%6.3f %6.0fc) 
    layout("\multicolumn{1}{c}{@}"
           "\multicolumn{1}{c}{@}")
    labels(`"\$R^{2}\$"' `"\$N\$"')
  )
  width(0.6\hsize) 
;
#delimit cr

test TS = TF
lincom TS - TF
texdoc stlog close

*texdoc write \begin{table}[H]
*texdoc write \caption{Conditional OLS.\label{reg:covariates}}
*texdoc write \input{tables/covariates}
*texdoc write \end{table}

/*tex
Do it for each of the covariates in turn
tex*/

texdoc stlog, do
local covariates "female hungrylvl foodsc BMI weightimp dieting healthlit"
local i = 1

foreach var of local covariates {
    local controls ""
    foreach control of local covariates {
        if "`control'" != "`var'" {
            local controls "`controls' `control'"
        }
    }
    if inlist("`var'", "female", "dieting", "healthlit") {
        regress wantinfo TS##i.`var' TF##i.`var' `controls'
    }
    else {
        regress wantinfo TS##c.`var' TF##c.`var' `controls'
    }
    estimates store model`i'
    local i = `i' + 1
}

#delimit ;
esttab model* using tables/interact.tex, replace
  b(a3) se(a3)
  star( * 0.10 ** 0.05 *** 0.01)
  label booktabs noomitted nobaselevels notes
  nomtitles 
  rename(1.TS TS 1.TF TF 1.female female 1.dieting dieting 1.healthlit healthlit)
  order(
    TS 
    TF
    1.TS#1.female
    1.TF#1.female
    1.TS#c.hungrylvl
    1.TF#c.hungrylvl
    1.TS#c.foodsc
    1.TF#c.foodsc
    1.TS#c.BMI
    1.TF#c.BMI
    1.TS#c.weightimp
    1.TF#c.weightimp
    1.TS#1.dieting
    1.TF#1.dieting
    1.TS#1.healthlit
    1.TF#1.healthlit
  )
  alignment(
    D{.}{.}{1.3}
    D{.}{.}{1.3}
    D{.}{.}{1.3}
    D{.}{.}{1.3}
    D{.}{.}{1.3}
    D{.}{.}{1.3}
    D{.}{.}{1.3}
  )
  stats(
    r2 N, fmt(%6.3f %6.0fc) 
    layout("\multicolumn{1}{c}{@}"
           "\multicolumn{1}{c}{@}")
    labels(`"\$R^{2}\$"' `"\$N\$"')
  )
  width(1.0\hsize) 
  substitute(
  "=1" ""
  )
;
#delimit cr
texdoc stlog close

*texdoc write \begin{footnotesize}
*texdoc write \begin{table}[H]
*texdoc write \caption{Interaction effects.\label{reg:interact}}
*texdoc write \input{tables/interact}
*texdoc write \end{table}
*texdoc write \end{footnotesize}

texdoc write \newpage
texdoc write \begin{figure}[H]
texdoc write \centering\includegraphics[width=\textwidth]{figures/valinfo_ns}
texdoc write \end{figure}


texdoc write \newpage
texdoc write \begin{figure}[H]
texdoc write \caption{Meal choices of \$U \rightarrow U\$ subjects.\label{fig:ch_nn}}
texdoc write \centering\includegraphics[width=\textwidth]{figures/chosemeal_nn}
texdoc write \end{figure}

texdoc write \newpage
texdoc write \begin{figure}[H]
texdoc write \caption{Meal choices of \$I \rightarrow I\$ subjects.\label{fig:ch_ii}}
texdoc write \centering\includegraphics[width=\textwidth]{figures/chosemeal_ii}
texdoc write \end{figure}

texdoc write \newpage
texdoc write \begin{table}[H]
texdoc write \caption{Treatment effects on calorie consumption, not
texdoc write adjusted for share of meal consumed.\label{reg:cf}}
texdoc write \input{tables/cf}
texdoc write \end{table}

texdoc write \newpage
texdoc write \begin{table}[H]
texdoc write \caption{Treatment effects on calorie consumption, not
texdoc write adjusted for share of meal consumed.\label{reg:cf_ns}}
texdoc write \input{tables/cf_ns}
texdoc write \end{table}

texdoc write \newpage
texdoc write \begin{table}[H]
texdoc write \caption{Treatment effects on calorie consumption,
texdoc write adjusted for share of meal consumed.\label{reg:cc}}
texdoc write \input{tables/cc}
texdoc write \end{table}

texdoc write \newpage
texdoc write \begin{table}[H]
texdoc write \caption{Treatment effects on calorie consumption,
texdoc write adjusted for share of meal consumed.\label{reg:cc_ns}}
texdoc write \input{tables/cc_ns}
texdoc write \end{table}

texdoc write \newpage
texdoc write \begin{table}[H]
texdoc write \caption{Information effect on calorie consumption, not
texdoc write adjusted for share of meal consumed, with self-efficacy
texdoc write pre-nudge\label{reg:cf_iS}}
texdoc write \input{tables/cf_iS}
texdoc write \end{table}

texdoc write \newpage
texdoc write \begin{table}[H]
texdoc write \caption{Mean value of information across subgroups\label{tbl:meanvalinfo}}
texdoc write \input{tables/meanvalinfo}
texdoc write \end{table}

texdoc write \newpage
texdoc write \begin{table}[H]
texdoc write \caption{Treatment effects on share of meal consumed.\label{reg:ms}}
texdoc write \input{tables/ms}
texdoc write \end{table}

texdoc write \newpage
texdoc write \begin{table}[H]
texdoc write \caption{Conditional OLS analysis.\label{reg:covariates}}
texdoc write \input{tables/covariates}
texdoc write \end{table}

texdoc write \newpage
texdoc write \begin{footnotesize}
texdoc write \begin{table}[H]
texdoc write \caption{Interaction effects.\label{reg:interact}}
texdoc write \input{tables/interact}
texdoc write \end{table}
texdoc write \end{footnotesize}

if (`dorest') {



}




/*tex
\end{document}
tex*/

set more off
! /Library/TeX/Distributions/.DefaultTeX/Contents/Programs/texbin/pdflatex newAnalysis
