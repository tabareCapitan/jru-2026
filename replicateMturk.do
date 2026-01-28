texdoc init replicateMturk.tex, logdir(replicateMturklogfiles) replace

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
\section{Load the data}
tex*/

texdoc stlog, do
use cleandataMturk, clear
texdoc stlog close

/*tex
``We collected data from 473 valid participants''
tex*/

texdoc stlog, do
count
texdoc stlog close

/*tex
\section{Descriptive statistics}

``As shown in Table~E.1,''

tex*/

texdoc stlog, do

#delimit ;
local varlistdesc "
female
age
education
income
hungrylvl
riskpref
foodsc
"
;

estpost summ `varlistdesc';
eststo descstats;

estout descstats, 
  cells("
  count(fmt(0))
  mean(fmt(2))
  sd(fmt(2))
  min(fmt(a2)) 
  max(fmt(a2))
 ")
;

esttab descstats using tables/descstats_mturk.tex,
  replace
  cells("
  count(fmt(0))
  mean(fmt(2))
  sd(fmt(2))
  min(fmt(a2))
  max(fmt(a2))
  ")
  collabels("N" "Mean" "SD" "Min" "Max")
  label nonumber nonote noobs
  booktabs
  mlabels(none)
;
#delimit cr
texdoc stlog close

texdoc write \begin{table}[H]
texdoc write \caption{Descriptive statistics: Online experiment\label{tbl:descstats_mturk}}
texdoc write \input{tables/descstats_mturk}
texdoc write \end{table}

/*tex

``about 46\% of the participants were female, which is similar to the share of
females in the laboratory experiment (47\%).''

tex*/

texdoc stlog, do
summ female
texdoc stlog close

/*tex
``They were also more
educated and had a higher income, with over 50\% of the participants having a
college degree''

\begin{figure}[H]
\centering\includegraphics[width=0.4\textwidth]{qualtrics/education}
\end{figure}
tex*/

texdoc stlog, do
tab education

/*tex
`` and 55\% an annual pre-tax salary over \$30,000. 
tex*/


tab income
count if income > 30000
local N_incgt30000 = r(N)
count if !missing(income)
local N_inc = r(N)
local perc_incgt30000 = 100*`N_incgt30000'/`N_inc'
disp "Percent with income greater than $30,000: " %4.0f `perc_incgt30000'
texdoc stlog close

/*tex

In general, participants in the online experiment were slightly more risk
averse [mean 3.47 in lab experiment]
tex*/

texdoc stlog, do
sum riskpref
texdoc stlog close

/*tex
``and had a similar average level of food self-control (30 in both
experiments), although the variance of the latter was higher in the online experiment''
[SD 6.70 in the Lab experiment]
tex*/

texdoc stlog, do
summ foodsc
texdoc stlog close

/*tex
(see Figure E.1)
tex*/

/*tex
Food self-control histogram
tex*/

texdoc stlog, do
set graphics off
#delimit ;
twoway  histogram foodsc,  fraction
                  fcolor(gray) lcolor(black) lwidth(thin)
                  xlabel(, nogrid)
                  ylabel(,ang(h) nogrid)
                  plotregion(lcolor(black) lwidth(thin))
                  xtitle("Food self-control")
;
#delimit cr

graph export "figures/oa_selfControl_mturk.pdf", replace
texdoc stlog close

texdoc write \begin{figure}[H]
texdoc write \centering\includegraphics[width=0.7\textwidth]{figures/oa_selfControl_mturk}
texdoc write \end{figure}


/*tex
``Participants were randomized into one of five experimental
groups: pre-nudge~1 ($N=92$), pre-nudge~2 ($N=97$), pre-nudge~3 ($N=96$),
pre-nudge~4 ($N=95$), and a control with no pre-nudge ($N=93$).'' 

\begin{small}
\begin{verbatim}
prenudge1 = TS
prenudge2 = TF
prenudge3 = TU
prenudge4 = TA
control   = TN
\end{verbatim}
\end{small}\vspace*{-2.5ex}

tex*/

texdoc stlog, do
gen prenudge = 0
replace prenudge = 1 if treatment == "TS"
replace prenudge = 2 if treatment == "TF"
replace prenudge = 3 if treatment == "TU"
replace prenudge = 4 if treatment == "TA"
label define prenudge_lbl 0 "TN" 1 "TS" 2 "TF" 3 "TU" 4 "TA"
label values prenudge prenudge_lbl
tab prenudge
texdoc stlog close

/*tex
``\textbf{Information uptake.} In the control group, 71.0\% of the
participants chose to receive a menu with calorie information. The baseline
level of information avoidance was therefore 29.0\%, bounding the maximum
potential treatment effect of the pre-nudges.''
tex*/

texdoc stlog, do
tab wantinfo if treatment == "TN"
texdoc stlog close

/*tex
Table~E.2 shows the treatment effect of each pre-nudge
in the online experiment and, for reference, the laboratory experiment. The
fourth and fifth columns show $p$-values from a $t$-test and a Fisher's exact test,
both one-sided. The pre-nudges achieved between 13\% and 50\% of the maximum
potential treatment effect.

\begin{tabular}{@{}lcd{-1}cc@{}}
\toprule
& & \multicolumn{1}{c}{\textbf{Effect}} & \textbf{$t$-test} & \textbf{FE test} \\
\textbf{Experiment}& \textbf{Treatment} & \multicolumn{1}{c}{\textbf{(p.p.)}} &
\textbf{($p$-value)} & \textbf{($p$-value)} \\ \midrule
Online              & Pre-nudge 1         & 6.2           & .1691           & .2176        \\
Laboratory          & Pre-nudge 1         & 8.0           & .0275           & .0346        \\
Online              & Pre-nudge 2         & 14.6          & .0072           & .0104        \\
Laboratory          & Pre-nudge 2         & 5.9           & .0813           & .0944        \\
Online              & Pre-nudge 3         & 12.4          & .0214           & .0342        \\
Online              & Pre-nudge 4         & 3.8           & .2818           & .3372        \\ \bottomrule
\end{tabular}

tex*/

texdoc stlog, do
foreach pn of numlist 1/4 {
  quietly ttest wantinfo if prenudge == 0 | prenudge == `pn', by(prenudge)
  local diff = r(mu_2) - r(mu_1)
  display "Prenudge `pn' Effect: " %4.3f `diff' ", t-test: " %5.4f r(p_l)
}
texdoc stlog close

texdoc stlog, nodo
foreach pn of numlist 1/4 {
  mark prenudgec if prenudge == `pn'
  preserve
  keep if prenudge == 0 | prenudgec == 1
  quietly ritest prenudgec _b[prenudgec], right seed(0.5) dots reps(5000): ///
    reg wantinfo prenudgec
  display "Prenudge `pn' FE ritest: " %5.4f r(p)[1,1]
  restore
  drop prenudgec
}

texdoc stlog close

/*tex
The average value of information was \$0.47 in
the control group. 
tex*/

texdoc stlog, do
summ valinfo if treatment == "TN"
texdoc stlog close

/*tex

``Table~E.3 shows the treatment effect
of each pre-nudge on that value in the online experiment and, for reference,
the laboratory experiment. The fourth and fifth columns show $p$-values from
a $t$-test and a Fisher's exact test, both one-sided. We do
not have an explanation for why, in the online experiment, the treatment effect
is negative (though insignificant) for pre-nudge~1.''


\begin{tabular}{@{}lcd{3}cc@{}}
\toprule
 & & \multicolumn{1}{c}{\textbf{Effect}} & \textbf{$t$-test} & \textbf{FE test} \\
\textbf{Experiment}& \textbf{Treatment} & \multicolumn{1}{c}{\textbf{(\$)}} &
\textbf{($p$-value)} & \textbf{($p$-value)} \\ \midrule
Online              & Pre-nudge 1         & -0.082         & .6400           & .6534        \\
Laboratory          & Pre-nudge 1         &  0.318         & .0396           & .0398        \\
Online              & Pre-nudge 2         &  0.345         & .0582           & .0540        \\
Laboratory          & Pre-nudge 2         &  0.323         & .0518           & .0516        \\
Online              & Pre-nudge 3         &  0.362         & .0640           & .0636        \\
Online              & Pre-nudge 4         &  0.218         & .1908           & .1906        \\ \bottomrule
\end{tabular}
tex*/

texdoc stlog, do
foreach pn of numlist 1/4 {
  quietly ttest valinfo if prenudge == 0 | prenudge == `pn', by(prenudge)
  local diff = r(mu_2) - r(mu_1)
  display "Prenudge `pn' Effect: " %6.3f `diff' ", t-test: " %5.4f r(p_l)
}
texdoc stlog close

texdoc stlog, nodo
foreach pn of numlist 1/4 {
  mark prenudgec if prenudge == `pn'
  preserve
  keep if prenudge == 0 | prenudgec == 1
  quietly ritest prenudgec _b[prenudgec], right seed(0.5) dots reps(5000): ///
    reg valinfo prenudgec
  display "Prenudge `pn' FE ritest: " %5.4f r(p)[1,1]
  restore
  drop prenudgec
}
texdoc stlog close



if (`dorest') {

}

/*tex
\end{document}
tex*/

set more off
! /Library/TeX/Distributions/.DefaultTeX/Contents/Programs/texbin/pdflatex replicateMturk
