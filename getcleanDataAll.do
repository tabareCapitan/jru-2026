texdoc init getcleanDataAll.tex, logdir(getcleanDataAlllogfiles) replace

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

\section{Merge all data}

Load the cleaned data from the Experiment
tex*/

texdoc stlog, do
use cleanDataExperiment, clear
texdoc stlog close

/*tex
Merge in the Background data

3 people completed the experiment but not the background questions
tex*/

texdoc stlog, do
merge 1:1 id using "cleanDataBackground"

count if _merge == 1
assert r(N) == 3
rename _merge mergeEB
*drop _merge
texdoc stlog close

/*tex
Merge in the weight data

21 people lack weight data
tex*/

texdoc stlog, do
merge 1:1 id using "cleanDataWeight" 

count if _merge == 1
assert r(N) == 21
rename _merge mergeEW
*drop _merge
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

order valinfo, after(getinfo)
texdoc stlog close


/*tex
\section{BMI}

\verb~BMI = weight (kg) / (height (m))^2~

tex*/

texdoc stlog, do
gen weight_kg = weight * 0.453592
gen height_m  = height / 100
gen BMI = weight_kg / height_m^2 
sum BMI if mergeEB == 3 & mergeEW == 3, detail
texdoc stlog close

/*tex
Subject \verb~872~ has an implausibly low BMI of 13.2. There seems to be an
error in the reported height \verb~(6'6)~, because the measured and
self-reported weights are consistent. Assign this subject the predicted BMI for
weight 114.

A scatterplot shows that the relationship is quite close to linear.
tex*/

texdoc stlog, do
reg BMI weight if id != 872
predict BMIhat
list id BMI BMIhat if id == 872
replace BMI = BMIhat if id == 872
drop BMIhat
label var BMI "BMI (measured)"
texdoc stlog close

/*tex
Also generate BMI using Tabaré's heightT variable
tex*/

texdoc stlog, do
gen heightT_m  = heightT / 100
gen BMIT = weight_kg / heightT_m^2 
sum BMIT if mergeEB == 3 & mergeEW == 3, detail
texdoc stlog close

/*tex
And generate it using self-reported weight, both ways
tex*/

texdoc stlog, do
gen weight_sr_kg = weight_sr * 0.453592
gen BMI_sr = weight_sr_kg / height_m^2 
sum BMI_sr if mergeEB == 3 & mergeEW == 3, detail

gen BMI_srT = weight_sr_kg / heightT_m^2 
sum BMI_srT if mergeEB == 3 & mergeEW == 3, detail
label var BMI_sr "BMI (self-report)"
texdoc stlog close

/*tex
\section{Calorie consumption}
tex*/

texdoc stlog, do
gen mealcal1 = 980
gen mealcal2 = 782
gen mealcal3 = 638
gen mealcal4 = 429

gen mealwt1 =  9.7
gen mealwt2 =  9.1 
gen mealwt3 = 10.7 
gen mealwt4 =  9.0 

texdoc stlog close

/*tex
\subsection{Calories consumed if ate entire meal}
tex*/

texdoc stlog, do
gen calfull = .
replace calfull = mealcal1 if mealchoice == 1
replace calfull = mealcal2 if mealchoice == 2
replace calfull = mealcal3 if mealchoice == 3
replace calfull = mealcal4 if mealchoice == 4
texdoc stlog close

/*tex
\subsection{Leftovers}
Truncate leftover weight to weight of meal.
tex*/

texdoc stlog, do
disp "mealwt1 = 9.7"
summ leftovers if mealchoice == 1, detail
replace leftovers = mealwt1 if !missing(leftovers) & leftovers > mealwt1 & mealchoice == 1

disp "mealwt2 = 9.1"
summ leftovers if mealchoice == 2, detail
replace leftovers = mealwt2 if !missing(leftovers) & leftovers > mealwt2 & mealchoice == 2

disp "mealwt3 = 10.7"
summ leftovers if mealchoice == 3, detail
replace leftovers = mealwt3 if !missing(leftovers) & leftovers > mealwt3 & mealchoice == 3

disp "mealwt4 =  9.0"
summ leftovers if mealchoice == 4, detail
replace leftovers = mealwt4 if !missing(leftovers) & leftovers > mealwt4 & mealchoice == 4
texdoc stlog close

/*tex
\subsection{Share of meal consumed}
tex*/

texdoc stlog, do
gen mealsh = .
replace mealsh = 1 - leftovers / mealwt1 if mealchoice == 1
replace mealsh = 1 - leftovers / mealwt2 if mealchoice == 2
replace mealsh = 1 - leftovers / mealwt3 if mealchoice == 3
replace mealsh = 1 - leftovers / mealwt4 if mealchoice == 4
summ mealsh if mealchoice == 1, detail
summ mealsh if mealchoice == 2, detail
summ mealsh if mealchoice == 3, detail
summ mealsh if mealchoice == 4, detail
summ mealsh, detail
texdoc stlog close

/*tex
\subsection{Calories actually consumed}
tex*/

texdoc stlog, do
gen calcons = calfull * mealsh 

disp "mealcal1 = 980"
summ calcons if mealchoice == 1, detail

disp "mealcal2 = 782"
summ calcons if mealchoice == 2, detail

disp "mealcal3 = 638"
summ calcons if mealchoice == 3, detail

disp "mealcal4 = 429"
summ calcons if mealchoice == 4, detail
texdoc stlog close

/*tex
Save the data, after dropping subjects that don't have experiment data.
tex*/

texdoc stlog, do
sort id
order mergeEB mergeEW, last
drop if missing(treatment)
save cleanDataAll, replace
texdoc stlog close

if (`dorest') {
}

/*tex
\end{document}
tex*/

set more off
! /Library/TeX/Distributions/.DefaultTeX/Contents/Programs/texbin/pdflatex getcleanDataAll
