texdoc init getcleanDataMturk.tex, logdir(getcleanDataMturklogfiles) replace

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
\section{Load the raw experiment data saved by getrawdata.do}
tex*/

texdoc stlog, do
use rawDataMturk, clear
texdoc stlog close

/*tex
\section{Keep only valid observations}

``''

Valid observations (i) finished the whole survey, (ii) were not
vegetarian/vegan, and (iii) did not have food allergies

tex*/


texdoc stlog, do
count
tab progress
tab finished
count if finished == "False" & progress != "100"
drop if finished == "False"
drop progress finished

tab introveg
drop if introveg == "Yes, I am a vegetarian/vegan"
drop introveg

tab introallergy
drop if introallergy == "Yes, I have food allergies"
drop introallergy
count
texdoc stlog close

/*tex
We end up not doing anything with the \verb~C~ treatment or the associated
\verb~cswitch*~ variables, because this treatment just tried to get a sense of
subject's willingness to switch meals.
tex*/

texdoc stlog, do
tab treatment
drop if treatment == "C"
count
texdoc stlog close

/*tex
\section{Info choice}
tex*/

texdoc stlog, do
tab tinfochoice
tab wantinfo
destring(wantinfo), replace

drop tinfochoice
texdoc stlog close

/*tex
\section{Value of information}

For people who initially did not want information (\verb~tinfochoice~ = 0), the
variable \verb~tniwta~ captures the smallest amount at which they were willing
to switch to getting info. The variable was set to 666 if subjects preferred
sticking to no info even if offered \$5 to get info.

Set the value of info for subjects who were willing to switch for \$5 or less
to {\em minus} the halfway point between the highest amount at which they
did not yet want to switch and the smallest amount at which they did want to
switch.

For subjects willing to switch even for \$0.01, set the value of info to
-\$0.01.

For subjects unwilling to switch even for \$5, set the value of info to -\$5.
tex*/

texdoc stlog, do
gen valinfo = .

replace valinfo = -0.01             if strtrim(tniwta) == "$0.01"
replace valinfo = -(0.25 + 0.01)/2  if strtrim(tniwta) == "$0.25"
replace valinfo = -(0.5  + 0.25)/2  if strtrim(tniwta) == "$0.50"
replace valinfo = -(0.75 + 0.5 )/2  if strtrim(tniwta) == "$0.75"
replace valinfo = -(1    + 0.75)/2  if strtrim(tniwta) == "$1"
replace valinfo = -(1.5  + 1   )/2  if strtrim(tniwta) == "$1.50"
replace valinfo = -(2    + 1.5 )/2  if strtrim(tniwta) == "$2"
replace valinfo = -(2.5  + 2   )/2  if strtrim(tniwta) == "$2.50"
replace valinfo = -(3    + 2.5 )/2  if strtrim(tniwta) == "$3"
replace valinfo = -(5    + 3   )/2  if strtrim(tniwta) == "$5"
replace valinfo = -5                if strtrim(tniwta) == "666"
texdoc stlog close

/*tex For people who initially did want information (\verb~tinfochoice~ = 1),
the variable \verb~tinwta~ captures the smallest amount at which they were
willing to switch to giving up info. The variable was set to 666 if subjects
preferred sticking to info even if offered \$5 to give it up.

Set the value of info for subjects who were willing to switch for \$5 or less
to the halfway point between the highest amount at which they did not yet want
to switch and the smallest amount at which they did want to switch.

For subjects willing to switch even for \$0.01, set the value of info to
\$0.01.

For subjects unwilling to switch even for \$5, set the value of info to \$5.
tex*/

texdoc stlog, do
replace valinfo = 0.01              if strtrim(tinwta) == "$0.01"
replace valinfo = (0.25 + 0.01)/2   if strtrim(tinwta) == "$0.25"
replace valinfo = (0.5  + 0.25)/2   if strtrim(tinwta) == "$0.50"
replace valinfo = (0.75 + 0.5 )/2   if strtrim(tinwta) == "$0.75"
replace valinfo = (1    + 0.75)/2   if strtrim(tinwta) == "$1"
replace valinfo = (1.5  + 1   )/2   if strtrim(tinwta) == "$1.50"
replace valinfo = (2    + 1.5 )/2   if strtrim(tinwta) == "$2"
replace valinfo = (2.5  + 2   )/2   if strtrim(tinwta) == "$2.50"
replace valinfo = (3    + 2.5 )/2   if strtrim(tinwta) == "$3"
replace valinfo = (5    + 3   )/2   if strtrim(tinwta) == "$5"
replace valinfo = 5                 if strtrim(tinwta) == "666"

texdoc stlog close

/*tex
\section{Female}
tex*/

texdoc stlog, do
gen female = .
replace female = 1 if gender == "Female"
replace female = 0 if gender == "Male"
label var female "Female"
drop gender
texdoc stlog close

/*tex
\subsection{Age}
tex*/

texdoc stlog, do
destring(age), replace
label var age "Age"
texdoc stlog close

/*tex
\subsection{Education}
tex*/

texdoc stlog, do
gen education = .
replace education = 1 if educ == "Less than high school"
replace education = 2 if educ == "High school"
replace education = 3 if educ == "Professional degree"
replace education = 4 if educ == "Some college"
replace education = 5 if educ == "College degree"
drop educ
label var education "Education"
texdoc stlog close

/*tex
\section{Income}
tex*/

texdoc stlog, do

rename income tempIncome

gen incomec = .
replace incomec = 1  if tempIncome == "$10,000 or less"
replace incomec = 2  if tempIncome == "$10,001 - $12,500"
replace incomec = 3  if tempIncome == "$12,501 - $15,000"
replace incomec = 4  if tempIncome == "$15,001 - $17,500"
replace incomec = 5  if tempIncome == "$17,501 - $20,000"
replace incomec = 6  if tempIncome == "$20,001 - $25,000"
replace incomec = 7  if tempIncome == "$25,001 - $30,000"
replace incomec = 8  if tempIncome == "$30,001- $50,000"
replace incomec = 9  if tempIncome == "$50,001-$70,000"
replace incomec = 10 if tempIncome == "$70,001-$90,000"
replace incomec = 11 if tempIncome == "$90,001 or more"
replace incomec = .a if tempIncome == "I'd rather not say"


gen income = .
replace income =  5000  if tempIncome == "$10,000 or less"
replace income = 11250  if tempIncome == "$10,001 - $12,500"
replace income = 13750  if tempIncome == "$12,501 - $15,000"
replace income = 16250  if tempIncome == "$15,001 - $17,500"
replace income = 18750  if tempIncome == "$17,501 - $20,000"
replace income = 22500  if tempIncome == "$20,001 - $25,000"
replace income = 27500  if tempIncome == "$25,001 - $30,000"
replace income = 40000  if tempIncome == "$30,001- $50,000"
replace income = 60000  if tempIncome == "$50,001-$70,000"
replace income = 80000 if tempIncome == "$70,001-$90,000"
replace income = 90001 if tempIncome == "$90,001 or more"
replace income = .a if tempIncome == "I'd rather not say"

label var income "Income"
drop tempIncome
texdoc stlog close

/*tex
\section{Hungriness level}
tex*/

texdoc stlog, do
gen hungrylvl  = .
replace hungrylvl = 1 if introhungry == "Not hungry at all"
replace hungrylvl = 2 if introhungry == "Somewhat hungry"
replace hungrylvl = 3 if introhungry == "Hungry"
replace hungrylvl = 4 if introhungry == "Very hungry"
label var hungrylvl "Hunger level"
drop introhungry
texdoc stlog close

/*tex
\section{Preference for risk}
tex*/

texdoc stlog, do
rename riskpref tmp_riskpref
gen riskpref = substr(tmp_riskpref,8,1)
destring(riskpref), replace
label var riskpref "Risk preference"
drop tmp_riskpref
texdoc stlog close

/*tex
\section{Food self-control}

\begin{figure}[H]
\centering\includegraphics[width=\textwidth]{qualtrics/foodsc}
\end{figure}

Questions 2, 3, 4, 8, 9, 10 should be reverse coded.

tex*/

texdoc stlog, do
forvalues i = 1/10 {

    rename foodsc_`i' tempfood_sc_`i'
    gen foodsc_`i' = .
    replace foodsc_`i' = 1 if tempfood_sc_`i' == "Very much disagree"
    replace foodsc_`i' = 2 if tempfood_sc_`i' == "Disagree"
    replace foodsc_`i' = 3 if tempfood_sc_`i' == "Neither agree nor disagree"
    replace foodsc_`i' = 4 if tempfood_sc_`i' == "Agree"
    replace foodsc_`i' = 5 if tempfood_sc_`i' == "Very much agree"

}
drop tempfood_sc_*

* Invert ranking where needed
replace foodsc_2  = (-1) * foodsc_2  + 6
replace foodsc_3  = (-1) * foodsc_3  + 6
replace foodsc_4  = (-1) * foodsc_4  + 6
replace foodsc_8  = (-1) * foodsc_8  + 6
replace foodsc_9  = (-1) * foodsc_9  + 6
replace foodsc_10 = (-1) * foodsc_10 + 6 

* Create summary variable
egen foodsc = rowtotal(foodsc_*)
drop foodsc_*
label var foodsc "Food self-control"
texdoc stlog close

/*tex
\section{Keep only wanted variables}
tex*/

texdoc stlog, do
#delimit ;
local wantedvars "
treatment
wantinfo
valinfo
female
age
education
incomec
income
hungrylvl
riskpref
foodsc
";
#delimit cr

keep `wantedvars'
order `wantedvars' 
count
texdoc stlog close

/*tex
Save the data.
tex*/

texdoc stlog, do
save cleanDataMturk, replace
texdoc stlog close


if (`dorest') {
}


/*tex
\end{document}
tex*/

set more off
! /Library/TeX/Distributions/.DefaultTeX/Contents/Programs/texbin/pdflatex getcleanDataMturk
