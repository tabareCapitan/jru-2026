texdoc init getcleanDataWeight.tex, logdir(getcleanDataWeightlogfiles) replace

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
\section{Load the raw Weight data saved by getrawdata.do}
tex*/

texdoc stlog, do
use rawDataWeight, clear
texdoc stlog close

/*tex
Check that the ID is unique, after some fixes

Note in Tabaré's code on key replace key = 489 if key == 480:
\begin{small}
\begin{verbatim}
// Not conclusive. Body weight: 148.4 vs 154.4. Self reported: 140 vs 150. 
It's consistent when checking out end time and weight order as reported
\end{verbatim}
\end{small}\vspace*{-2.5ex}

tex*/

texdoc stlog, do
rename weightLeftovers leftovers
replace key = 123 if key == 125 & leftovers == 8.1 // 125 was repeated
replace key = 261 if key == 201 & leftovers == 0.9
replace key = 268 if key == 286 & leftovers == 0.9
replace key = 336 if key == 366 & leftovers == 2.9
replace key = 489 if key == 480 & leftovers == 1.2 // See note above 
replace key = 453 if key == 493 & leftovers == 1.1
replace key = 444 if key == 494
replace key = 550 if key == 540 & leftovers == 2.6
replace key = 589 if key == 580 & leftovers == 4.3
replace key = 624 if key == 629 & leftovers == 3.1
replace key = 824 if key == 829 & leftovers == 1.7
replace key = 842 if key == 892 & leftovers == 1
replace key = 935 if key == 983 & leftovers == 5.9
replace key = 649 if key == 249
replace key = 644 if key == 344
rename key id
rename weightBody weight
isid id
order id, first
count
texdoc stlog close

/*tex
\section{Keep only wanted variables}
tex*/

texdoc stlog, do
#delimit ;
local wantedvars "
id
weight
leftovers
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
save cleanDataWeight, replace
texdoc stlog close

if (`dorest') {
}

/*tex
\end{document}
tex*/

set more off
! /Library/TeX/Distributions/.DefaultTeX/Contents/Programs/texbin/pdflatex getcleanDataWeight
