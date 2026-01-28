texdoc init getrawData.tex, logdir(getrawDatalogfiles) replace

/*tex
\documentclass[11pt,reqno]{amsart}
\usepackage{fullpage}
\usepackage{graphicx}
\usepackage{stata}
\usepackage{setspace}
\usepackage{float}
\usepackage{subfigure}
\usepackage{color}
\usepackage[bookmarks]{hyperref}
\setlength{\parskip}{\baselineskip}
\setlength{\parindent}{0pt}
%\setlength{\parskip}{0pt}
%\setlength{\parindent}{2em}
\setlength{\footskip}{0.5in}
%\setstretch{1.2}
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
\setcounter{secnumdepth}{0}
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

\section{Load the raw data and save to Stata format}

Load and save the choice data from file \verb~USDA2018-LIVE-KLAAS_March 8, 2018_13.28.csv~ 
saved out of Qualtrics 
tex*/ 

texdoc stlog, do
clear all
import delimited ///
	"raw/USDA2018-LIVE-KLAAS_March 8, 2018_13.28.csv", clear ///
	delimiter(comma) bindquote(strict) varnames(1) stripquote(yes) rowrange(4) ///
    maxquotedrows(unlimited)

drop if _n < 3 // rowrange(4) somehow doesn't work

save "rawDataExperiment.dta", replace
texdoc stlog close

/*tex
Load and save the background data from file \verb~USDA2018-LIVE-Background_July 29, 2018_21.41.csv~ 
saved out of Qualtrics 
tex*/

texdoc stlog, do
import delimited ///
    "raw/USDA2018-LIVE-Background_July 29, 2018_21.41.csv", clear ///
    delimiter(comma) bindquote(strict) varnames(1) stripquote(yes) rowrange(4) ///
    maxquotedrows(unlimited)

drop if _n < 3 // rowrange(4) somehow doesn't work

save "rawDataBackground.dta", replace
texdoc stlog close

/*tex
Load and save the data on weights and leftovers from file \verb~WEIGHTS.xlsx~

Drop the empty columns H and I
tex*/

texdoc stlog, do
import excel using "raw/WEIGHTS.xlsx", clear firstrow

drop H I

save "rawDataWeight.dta", replace
texdoc stlog close

/*tex
\end{document}
tex*/

set more off
! /Library/TeX/Distributions/.DefaultTeX/Contents/Programs/texbin/pdflatex getrawData
