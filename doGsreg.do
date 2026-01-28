texdoc init doGsreg.tex, logdir(doGsreglogfiles) replace

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

Drop subjects that don't have experiment data.
tex*/

texdoc stlog, do
use cleanDataAll, clear
texdoc stlog close

/*tex
Define treatment dummies
tex*/

texdoc stlog, do
mark TN if treatment == "TN"
mark TS if treatment == "TS"
mark TF if treatment == "TF"
label var TS "TS"
label var TF "TF"
texdoc stlog close

/*tex
Collect the covariates
tex*/

texdoc stlog, do
#delimit ;
local covariates "
    female
    hungrylvl
    foodsc
    BMI
    weightimp
    dieting
    healthlit
";

local covariatesT "
    female
    hungrylvl
    foodsc
    BMIT
    weightimp
    dieting
    healthlit
"
;
#delimit cr
texdoc stlog close

/*tex
Run \verb~gsreg~ for both dependent variables and treatments.
tex*/

texdoc stlog, nodo
set varabbrev on
foreach depvar in wantinfo valinfo {
    foreach trtvar in TS TF {
        preserve
        keep if TN | `trtvar'
        gsreg `depvar' `covariates', resultsdta("allRegs_`depvar'_`trtvar'") fixvar(`trtvar') cmdoptions(robust) nocount replace
        restore
    }
}
set varabbrev off
texdoc stlog close

/*tex
Generate the graphs
tex*/

texdoc stlog, do
foreach depvar in wantinfo valinfo {
    foreach trtvar in TS TF {

*local depvar = "wantinfo"
*local trtvar = "TS"

use allRegs_`depvar'_`trtvar', clear

// Set ylabel ranges based on depvar-trtvar combo
if "`depvar'" == "wantinfo" & "`trtvar'" == "TS" {
    local ylabel "0.05(0.01)0.11"
}    
else if "`depvar'" == "wantinfo" & "`trtvar'" == "TF" {
    local ylabel "0.04(0.01)0.07"
}
else if "`depvar'" == "valinfo" & "`trtvar'" == "TS" {
    local ylabel "0.20(0.01)0.34"
}
else if "`depvar'" == "valinfo" & "`trtvar'" == "TF" {
    local ylabel "0.24(0.01)0.34"
}

// Rename bars
gen stringUncond = "Unconditional"
rename v_1_b group_c
rename v_1_t group_t

// Calculate p-values
gen df = obs - nvar
gen group_p1T = ttail(df,abs(group_t))
gen group_p2T = 2*ttail(df,abs(group_t))
order group_p*, after(group_t)

// Get frequencies
count
count if group_c > 0
count if group_c > 0.05
count if group_c > 0.1
count if group_c > 0.15
count if group_c > 0.2
count if group_p1T < 0.01
count if group_p1T < 0.05
count if group_p1T < 0.1

// PREPARE GRAPH
sum group_c if nvar == 2  // unconditional estimate
local yline = `r(mean)'

sum group_p1T if nvar == 2
local xline = `r(mean)'

graph set window fontface "Times New Roman"

#delimit ;
// CENTER GRAPH: SCATTER PLOT;
twoway  (scatter group_c group_p1T,  msymbol(o) msize(small)  mcolor(gs10) )
        (scatter group_c group_p1T if nvar == 2,
        msymbol(s) msize(small) mcolor(red) mlabel(stringUncond) mlabpos(6))
        ,
        xline(`xline', lcolor(red) lwidth(vthin) lpattern(solid))
        yline(`yline', lcolor(red) lwidth(vthin) lpattern(solid))
        xline(0.01 0.05 0.1, lcolor(gs10) lwidth(thin) lpattern(solid))
        legend(off)
        yscale(alt)
        ylabel(`ylabel', ang(horizontal) nogrid)
        xscale(alt)
        xlabel(0.01 "0.01" 0.05 "0.05" 0.1 "0.1", nogrid)
        xtitle("pvalue")
        ytitle("Treatment effect", orientation(rvertical))
        plotregion(lcolor(black) lwidth(medium))
        saving("figures/middle_`depvar'_`trtvar'.gph", replace);

// LEFT: HISTOGRAM OF COEFFICIENTS;
twoway  hist group_c ,
        fcolor(gray) lcolor(black) lwidth(thin)
        ytitle("Treatment effect")
        yline(`yline', lcolor(red) lwidth(vthin) lpattern(solid))
        fraction
        xsca(alt reverse)
        horiz
        fxsize(25)
        xlabel( #3, ang(h) nogrid)
        ylabel(`ylabel', ang(h) nogrid)
        plotregion(lcolor(black) lwidth(medium))
        saving("figures/left_`depvar'_`trtvar'.gph", replace);


// BOTTOM: HISTOGRAM OF PVALUES;
twoway  histogram group_p1T,
        fcolor(gray) lcolor(black) lwidth(thin)
        xtitle("pvalue")
        xline(`xline', lcolor(red) lwidth(vthin) lpattern(solid))
        xline(0.01 0.05 0.1, lcolor(gs10) lwidth(thin) lpattern(solid))
        fysize(25)
        fraction
        yscale(alt reverse)
        ylabel(0(0.07)0.21, nogrid ang(h))
        ytitle(,orientation(rvertical))
        xlabel(0.01 "0.01" 0.05 "0.05" 0.1 "0.1", nogrid)
        plotregion(lcolor(black) lwidth(medium))
        saving("figures/bottom_`depvar'_`trtvar'.gph", replace);

// COMBINE ALL THREE GRAPHS
graph combine   "figures/left_`depvar'_`trtvar'.gph"
                "figures/middle_`depvar'_`trtvar'.gph"
                "figures/bottom_`depvar'_`trtvar'.gph"
                ,
                hole(3)
                imargin(0 0 0 0)
                graphregion(margin(l=22 r=22));

graph export "figures/oa_treatmentEffect_`depvar'_`trtvar'.pdf", replace;
#delimit cr

   } /* foreach trtvar in TS TF */
} /* foreach depvar in wantinfo valinfo */

texdoc stlog close

if (`dorest') {
}

/*tex
\end{document}
tex*/

set more off
! /Library/TeX/Distributions/.DefaultTeX/Contents/Programs/texbin/pdflatex doGsreg
