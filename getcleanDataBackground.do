texdoc init getcleanDataBackground.tex, logdir(getcleanDataBackgroundlogfiles) replace

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
\section{Load the raw Background data saved by getrawdata.do}
tex*/

texdoc stlog, do
use rawDataBackground, clear
texdoc stlog close

/*tex
\section{Keep only valid observations}
tex*/

texdoc stlog, do
gen valid = (progress == "100") & (finished == "True")
drop progress finished
drop if !valid
drop valid
count
texdoc stlog close

/*tex
Check that the ID is unique, after some fixes
tex*/

texdoc stlog, do
destring(q114), replace    // id1
destring(q115), replace    // id2
destring(q166), replace    // id3

corr q114 q115 q166   // 1 inconsistency

replace q115 = 740 if q114 == 740 & q166 == 740  // fix typo
corr q114 q115 q166
rename q114 id
drop q115 q166
order id, first
isid id
count
texdoc stlog close

/*tex
\section{Demographics}

\subsection{Gender}
tex*/

texdoc stlog, do
gen female = .
replace female = 1 if q117 == "Female"
replace female = 0 if q117 == "Male"
drop q117
label var female "Female"
texdoc stlog close

/*tex
\subsection{Age}
tex*/

texdoc stlog, do
rename q121 age
destring(age), replace
label var age "Age"
texdoc stlog close

/*tex
\subsection{Education}
tex*/

texdoc stlog, do
gen education = .
replace education = 1 if q119 == "Less than high school"
replace education = 2 if q119 == "High school"
replace education = 3 if q119 == "Professional degree"
replace education = 4 if q119 == "Some college"
replace education = 5 if q119 == "College degree"
drop q119
label var education "Education"
texdoc stlog close

/*tex
\subsection{Spending level}

\begin{figure}[H]
\centering\includegraphics[width=\textwidth]{qualtrics/expenses}
\end{figure}

tex*/

texdoc stlog, do
gen expensesc = .
replace expensesc = 1  if v83 == "$400 or less"
replace expensesc = 2  if v83 == "$401 - $600"
replace expensesc = 3  if v83 == "$601 - $800"
replace expensesc = 4  if v83 == "$801 - $1,000"
replace expensesc = 5  if v83 == "$1,001 - $1,200 "
replace expensesc = 6  if v83 == "$1,201 - $1,400"
replace expensesc = 7  if v83 == "$1,401 - $1,600"
replace expensesc = 8  if v83 == "$1601 - $1,800"
replace expensesc = 9  if v83 == "$1,801 - $2,000"
replace expensesc = 10 if v83 == "$2,000 or more"
replace expensesc = .a if v83 == "I'd rather not say"

gen expenses = .
replace expenses =  200   if v83 == "$400 or less"
replace expenses =  500   if v83 == "$401 - $600"
replace expenses =  700   if v83 == "$601 - $800"
replace expenses =  900   if v83 == "$801 - $1,000"
replace expenses = 1100  if v83 == "$1,001 - $1,200 "
replace expenses = 1300  if v83 == "$1,201 - $1,400"
replace expenses = 1500  if v83 == "$1,401 - $1,600"
replace expenses = 1700  if v83 == "$1601 - $1,800"
replace expenses = 1900  if v83 == "$1,801 - $2,000"
replace expenses = 2000  if v83 == "$2,000 or more"
replace expenses = .a if v83 == "I'd rather not say"

label var expenses "Expenses (monthly)"
drop v83
texdoc stlog close

/*tex
\subsection{Income}

\begin{figure}[H]
\centering\includegraphics[width=\textwidth]{qualtrics/expenses}
\end{figure}
tex*/

texdoc stlog, do
gen incomec = .
replace incomec = 1  if q139 == "$10,000 or less"
replace incomec = 2  if q139 == "$10,001 - $12,500"
replace incomec = 3  if q139 == "$12,501 - $15,000"
replace incomec = 4  if q139 == "$15,001 - $17,500"
replace incomec = 5  if q139 == "$17,501 - $20,000"
replace incomec = 6  if q139 == "$20,001 - $25,000"
replace incomec = 7  if q139 == "$25,001 - $30,000"
replace incomec = 8  if q139 == "$30,001- $50,000"
replace incomec = 9  if q139 == "$50,000 or more"
replace incomec = .a if q139 == "I'd rather not say"

gen income = .
replace income =  5000 if q139 == "$10,000 or less"
replace income = 11250 if q139 == "$10,001 - $12,500"
replace income = 13750 if q139 == "$12,501 - $15,000"
replace income = 16250 if q139 == "$15,001 - $17,500"
replace income = 18750 if q139 == "$17,501 - $20,000"
replace income = 22500 if q139 == "$20,001 - $25,000"
replace income = 27500 if q139 == "$25,001 - $30,000"
replace income = 40000 if q139 == "$30,001- $50,000"
replace income = 50000 if q139 == "$50,000 or more"
replace income = .a if q139 == "I'd rather not say"

label var income "Income (annual)"
drop q139
texdoc stlog close

/*tex
\section{Hunger level}

See \verb~getcleanDataExperiment~
tex*/

/*tex
\section{Preference for risk}

\begin{figure}[H]
\centering\includegraphics[width=\textwidth]{qualtrics/riskpref}
\end{figure}

tex*/

texdoc stlog, do
rename v25 riskpref
replace riskpref = substr(riskpref,8,1)
destring(riskpref), replace

label var riskpref "Preference for risk"
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

    gen foodsc_`i' = .
    replace foodsc_`i' = 1 if q125_`i' == "Very much disagree"
    replace foodsc_`i' = 2 if q125_`i' == "Disagree"
    replace foodsc_`i' = 3 if q125_`i' == "Neither agree nor disagree"
    replace foodsc_`i' = 4 if q125_`i' == "Agree"
    replace foodsc_`i' = 5 if q125_`i' == "Very much agree"

}
drop q125_*

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
\section{BMI}

See \verb~getcleanDataAll.do~
tex*/

/*tex
\section{Weight self-assessment}
tex*/

texdoc stlog, do
gen weightas = .

replace weightas = 1  if q148 == "I am underweight"
replace weightas = 2  if q148 == "I am normal weight"
replace weightas = 3  if q148 == "I am overweight"
replace weightas = 4  if q148 == "I am obese"
replace weightas = .a if q148 == "I do not know"

label var weightas "Weight self-assessment"
order weightas, after(foodsc)

gen underweight  = (weightas == 1) if !missing(weightas)
gen normalweight = (weightas == 2) if !missing(weightas)
gen overweight   = (weightas == 3) if !missing(weightas)
gen obese        = (weightas == 4) if !missing(weightas)

label var underweight  "Underweight (self-report)"
label var normalweight "Normal weight (self-report)"
label var overweight   "Overweight (self-report)"
label var obese        "Obese (self-report)"

drop q148
texdoc stlog close

/*tex
\section{Health self-assessment}

\begin{figure}[H]
\centering\includegraphics[width=\textwidth]{qualtrics/healthas}
\end{figure}

tex*/

texdoc stlog, do

forvalues i = 1(1)4{

    gen healthas_`i' = .
    replace healthas_`i' = 1 if q163_`i' == "Very much disagree"
    replace healthas_`i' = 2 if q163_`i' == "Disagree"
    replace healthas_`i' = 3 if q163_`i' == "Neither agree nor disagree"
    replace healthas_`i' = 4 if q163_`i' == "Agree"
    replace healthas_`i' = 5 if q163_`i' == "Very much agree"


  }
label var healthas_1 "Am in excellent health"
label var healthas_2 "Would benefit from eating healthier"
label var healthas_3 "Wish could eat healthier at home"
label var healthas_4 "Wish could eat healthier out"

drop q163_*
texdoc stlog close

/*tex
\section{Weight goals}

\begin{figure}[H]
    \centering\includegraphics[width=\textwidth]{qualtrics/weightgoals}
\end{figure}
tex*/

texdoc stlog, do

forvalues i = 1(1)3{

    gen goalimp_`i' = .
    replace goalimp_`i' = 1 if q159_`i' == "Not at all important"
    replace goalimp_`i' = 2 if q159_`i' == "Slightly important"
    replace goalimp_`i' = 3 if q159_`i' == "Moderately important"
    replace goalimp_`i' = 4 if q159_`i' == "Very important"
    replace goalimp_`i' = 5 if q159_`i' == "Extremely important"


}
label var goalimp_1 "Importance of eathing healthy food"
label var goalimp_2 "Importance of exercising regularly"
label var goalimp_3 "Importance of health body weight"

drop q159_*

gen weightimp = goalimp_3
label var weightimp "Weightimp"
texdoc stlog close

/*tex
\section{Dieting}

\begin{figure}[H]
    \centering\includegraphics[width=\textwidth]{qualtrics/wanttolose}
\end{figure}
tex*/

texdoc stlog, do

gen wanttolose = .
replace wanttolose = 1 if q161 == "Yes"
replace wanttolose = 0 if q161 == "No"

label var wanttolose "Want to lose weight"
drop q161

texdoc stlog close

/*tex
\begin{figure}[H]
    \centering\includegraphics[width=\textwidth]{qualtrics/dieting}
\end{figure}
tex*/

texdoc stlog, do
tab q153
gen dieting = .
replace dieting = 1 if q153 == "Yes"
replace dieting = 0 if q153 == "No"

label var dieting "Currently on a diet"
drop q153

texdoc stlog close

/*tex
\section{Frequency of encountering calorie info}
tex*/

texdoc stlog, do

gen freqinfo = .
replace freqinfo = 1 if q144 ==                                             ///
  "I do not recall ever seeing calories displayed on the menu or menu boards"
replace freqinfo = 2 if q144 ==                                             ///
  "I recall rarely seeing calories displayed on the menu or menu boards"
replace freqinfo = 3 if q144 ==                                             ///
  "I recall sometimes seeing calories displayed on the menu or menu boards"
replace freqinfo = 4 if q144 ==                                             ///
  "I recall often seeing calories displayed on the menu or menu boards"
replace freqinfo = 5 if q144 ==                                             ///
  "I recall always seeing calories displayed on the menu or menu boards"

label var freqinfo "Exposure to calorie info"
drop q144

texdoc stlog close

/*tex
\section{Health literacy}

\begin{figure}[H]
    \centering\includegraphics[width=\textwidth]{qualtrics/healthlit}
\end{figure}
tex*/

texdoc stlog, do

gen healthlit = 0
replace healthlit = 1 if q142 == "Around 2,500 calories"

label var healthlit "Knows recommended calorie intake"
drop q142

texdoc stlog close

/*tex
\section{Height}

\begin{figure}[H]
    \centering\includegraphics[width=\textwidth]{qualtrics/height_sr}
\end{figure}

This variable is needed to calculate BMI.

Unfortunately, the answer was open-ended, so constructing it takes some doing.

The \verb~sieve~ command used is a utility in the user-contributed
\verb~egenmore~ package
tex*/

texdoc stlog, do

gen heightstr = q150
gen feet = .
gen inches = .

* Some heights are given in inches only
gen only_inches = real(heightstr) >= 57 & real(height) <= 80
replace feet   = floor(real(heightstr)/12) if only_inches
replace inches = mod(real(heightstr),12)   if only_inches

replace feet = real(substr(heightstr, 1, 1)) if !only_inches              // get first character
replace heightstr = substr(heightstr,2,.)    if !only_inches           // delete first character
egen inchesstr = sieve(heightstr), keep(numeric)    // keep numeric characters of what remains
replace inches = real(inchesstr) if !only_inches
drop inchesstr

* Deal with special cases

replace feet   = 5      if q150 == "66 inches"
replace inches = 9.75   if q150 == "5' 9.75"
replace inches = 9.5    if q150 == "5 feet 9 1/2 inches"
replace inches = 11.5   if q150 == "5' 11.5"
replace inches = 0.5    if q150 == "6'1/2"
replace feet   = 6      if q150 == "six feet three inches"
replace inches = 3      if q150 == "six feet three inches"
replace inches = 4.5    if q150 == "5 feet 4.5 inches"
replace inches = 11.75  if q150 == "5'11.75"
replace inches = 10     if q150 == "50' 10"
replace inches = 11.5   if q150 == "5 feet 11.5 inches"
replace inches = 2.75   if q150 == "6 foot 2.75 inches"
replace inches = 8.5    if q150 == "5 feet 8.5 inches"
replace inches = 5.5    if q150 == "5 feet 5.5 inches"
replace inches = 9.5    if q150 == "5,9.5"
replace inches = 6.5    if q150 == "5' 6.5"
replace inches = 1.5    if q150 == "6 feet 1.5 inches"
replace inches = 8.5    if q150 == "5'8.5"
replace inches = 4      if q150 == "5.4 and 65"
replace inches = 6      if q150 == "5 feet 6 or 7 inches"
replace inches = 0      if missing(inches)

gen height = feet * 30.48 + inches * 2.54  // in meters

replace height = 165 if q150 == "165" //line 367
replace height = 162 if q150 == "162" //line 375
replace height = 160 if q150 == "62.9921" // line 784: 160 cm = 62.9921 in

* Iffy: 
* line 410 says 54'---interpreted as 5 feet 4 inches
* line 462 says 56'---interpreted as 5 feet 6 inches

list id q150 feet inches height only_inches

summ height, detail

drop heightstr feet inches

texdoc stlog close

/*tex
Do height exactly Tabaré's way too, for replicability
tex*/

texdoc stlog, do
gen temp = q150
gen feetT = substr(temp, 1, 1)            // get first character
replace  temp = substr(temp,2,.)          // delete first character
egen inchesT = sieve(temp), keep(numeric)  // keep numeric characters

* HANDLE SPECIAL CASES
replace inchesT = "9.75" if q150 == "5' 9.75"
replace inchesT = "9.5" if q150 == "5 feet 9 1/2 inches"
replace inchesT = "11.5" if q150 == "5' 11.5"
replace inchesT = "0.5" if q150 == "6'1/2"
replace feetT   = "6" if q150 == "six feet three inches"
replace inchesT = "3" if q150 == "six feet three inches"
replace inchesT = "4.5" if q150 == "5 feet 4.5 inches"
replace inchesT = "11.75" if q150 == "5'11.75"
replace feetT   = "" if q150 == "62.9921"                  // Fix? It's unclear
replace inchesT = "" if q150 == "62.9921"                  // Fix? It's unclear
replace inchesT = "10" if q150 == "50' 10"
replace inchesT = "11.5" if q150 == "5 feet 11.5 inches"
replace inchesT = "2.75" if q150 == "6 foot 2.75 inches"
replace inchesT = "8.5" if q150 == "5 feet 8.5 inches"
replace inchesT = "5.5" if q150 == "5 feet 5.5 inches"
replace feetT   = "" if q150 == "78.5"
replace inchesT = "" if q150 == "78.5"
replace inchesT = "9.5" if q150 == "5,9.5"
replace inchesT = "6.5" if q150 == "5' 6.5"
replace feetT   = "" if q150 == "73"
replace inchesT = "" if q150 == "73"
replace inchesT = "1.5" if q150 == "6 feet 1.5 inches"
replace inchesT = "8.5" if q150 == "5'8.5"
replace feetT   = "" if q150 == "71"
replace inchesT = "" if q150 == "71"
replace inchesT = "4" if q150 == "5.4 and 65"
replace inchesT = "6" if q150 == "5 feet 6 or 7 inches"
replace feetT   = "" if q150 == "75"
replace inchesT = "" if q150 == "75"
replace inchesT = "0" if missing(inchesT)

destring(feetT), replace
destring(inchesT), replace

gen heightT = feetT * 30.48 + inchesT * 2.54  // in meters
replace heightT = 165 if q150 == "165"
replace heightT = 162 if q150 == "162"

order heightT, after(height)

drop q150 temp feetT inchesT
texdoc stlog close

/*tex
\section{Self-reported weight}

\begin{figure}[H]
    \centering\includegraphics[width=\textwidth]{qualtrics/weight_sr}
\end{figure}
tex*/

texdoc stlog, do
destring(v65), gen(weight_sr)
drop v65
texdoc stlog close

/*tex
\section{Confidence in self-reported weight}
tex*/

texdoc stlog, do
destring(q138_1), gen(weight_sr_conf)
drop q138_1
texdoc stlog close

/*tex
\section{Last time weighed oneself}
tex*/

texdoc stlog, do
gen last_weighed = .
replace last_weighed = 1 if q136 == "More than a year ago"
replace last_weighed = 2 if q136 == "A year ago"
replace last_weighed = 3 if q136 == "A few months ago"
replace last_weighed = 4 if q136 == "A month ago"
replace last_weighed = 5 if q136 == "A few weeks ago"
replace last_weighed = 6 if q136 == "A week ago"
replace last_weighed = 7 if q136 == "A few days ago"
replace last_weighed = 8 if q136 == "Yesterday"
replace last_weighed = 9 if q136 == "Today"

drop q136
texdoc stlog close


/*tex
\section{Keep only wanted variables}
tex*/

texdoc stlog, do
#delimit ;
local wantedvars "
id
female
age
education
expensesc
expenses
incomec
income
riskpref
foodsc
underweight
normalweight
overweight
obese
healthas_*
goalimp_*
weightimp
wanttolose
dieting
freqinfo
healthlit
height
heightT
weight_sr
weight_sr_conf
last_weighed
";
#delimit cr

keep `wantedvars'
order `wantedvars' 
count
texdoc stlog close

/*tex
Save the data
tex*/

texdoc stlog, do
sort id
save cleanDataBackground, replace
texdoc stlog close

if (`dorest') {
}


/*tex
\end{document}
tex*/

set more off
! /Library/TeX/Distributions/.DefaultTeX/Contents/Programs/texbin/pdflatex getcleanDataBackground
