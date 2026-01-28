texdoc init getcleanDataExperiment.tex, logdir(getcleanDataExperimentlogfiles) replace

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
use rawDataExperiment, clear
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
Check that the ID is unique, after some fixes
tex*/

texdoc stlog, do
destring(id1), replace
destring(id2), replace

replace id2 = 241 if id1 == 241 // Mistake indicating id2
replace id1 = 619 if id2 == 619	// Mistake indicating id2

assert id1 == id2
drop id2
rename id1 id
order id, first
isid id
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
order treatment, after(id)
texdoc stlog close

/*tex
\section{Info choice}
tex*/

texdoc stlog, do
tab tinfochoice
tab wantinfo
destring(wantinfo), replace

drop tinfochoice
order wantinfo, after(treatment)
texdoc stlog close

/*tex
\section{Info received or not}
tex*/

texdoc stlog, do
tab getinfo
destring(getinfo), replace

order getinfo, after(wantinfo)
texdoc stlog close

/*tex
\section{Meal preferences}

Generate a variable \verb~tastyx~ that captures the tastiness of mealx

Note that the position of mealx varies by person due to menu-order randomization. 

\begin{enumerate}
  \item Get value of slider per meal for those who did not get information
  \item Get value of slider per meal for those who did get information
  \item Combine both into one variable per meal, since we know who got info
        from the \verb~getinfo~ variable
\end{enumerate}

The \verb~itemymeal~ variable stores the name of the mealy shown in positiony
of the menu that the subject saw:

\begin{figure}[H]
\centering\includegraphics[width=0.3\textwidth]{qualtrics/meals}
\end{figure}

\begin{figure}[H]
\centering\includegraphics[width=0.4\textwidth]{qualtrics/menulogic}
\end{figure}

tex*/

texdoc stlog, do

forvalues i = 1/4 {

        gen tasty_n`i' = "" 
    replace tasty_n`i' = slidern_1 if item1meal == "`i'"
    replace tasty_n`i' = slidern_2 if item2meal == "`i'" 
    replace tasty_n`i' = slidern_3 if item3meal == "`i'" 
    replace tasty_n`i' = slidern_4 if item4meal == "`i'" 

    destring(tasty_n`i'), replace

}

forvalues i = 1/4 {

        gen tasty_i`i' = "" 
    replace tasty_i`i' = slideri_1 if item1meal == "`i'"
    replace tasty_i`i' = slideri_2 if item2meal == "`i'" 
    replace tasty_i`i' = slideri_3 if item3meal == "`i'" 
    replace tasty_i`i' = slideri_4 if item4meal == "`i'" 

    destring(tasty_i`i'), replace

}

drop slideri_*

assert (!missing(tasty_n1) & getinfo == 0) | (!missing(tasty_i1) & getinfo == 1)

forvalues i = 1/4 {
    egen tasty`i' = rowtotal(tasty_*`i')
}

drop tasty_n* tasty_i*
order tasty*, after(wantinfo)
texdoc stlog close


/*tex
\section{Meal choice}

The data has a variable \verb~mealchoice~ that is relevant only to the dropped
treatment C. Drop it, and then generate it for the other treatments
tex*/

texdoc stlog, do
drop mealchoice

gen mealchoice = .
replace mealchoice = 1 if mealget == "Chicken/Salami Gnocchi"
replace mealchoice = 2 if mealget == "Red Rice/Fajita Chicken"
replace mealchoice = 3 if mealget == "Chicken Nicoise"
replace mealchoice = 4 if mealget == "Middle Eastern Pasta with Chicken"
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

order hungrylvl, after(mealchoice)
label var hungrylvl "Hunger level (in the lab)"
drop introhungry
texdoc stlog close

/*tex
\section{Keep only wanted variables}
tex*/

texdoc stlog, do
#delimit ;
local wantedvars "
id
treatment
wantinfo
getinfo
tniwta
tinwta
tasty*
mealchoice
hungrylvl
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
sort id
save cleanDataExperiment, replace
texdoc stlog close

if (`dorest') {
}


/*tex
\end{document}
tex*/

set more off
! /Library/TeX/Distributions/.DefaultTeX/Contents/Programs/texbin/pdflatex getcleanDataExperiment
