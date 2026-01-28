texdoc init replicateExperiment.tex, logdir(replicateExperimentlogfiles) replace

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
use cleanDataAll, clear
texdoc stlog close

/*tex
``Participants were randomized into one of three
experimental groups. One group ($N=242$) received the first pre-nudge, another
group ($N=245$) received the second pre-nudge, and the final group ($N=244$),
our control group, received no information at this stage.''

\begin{tabbing}
Prenudge 1 \= TN\kill
Prenudge 1 \> TS (self-efficacy)\\
Prenudge 2 \> TF (future risks)\\
Control    \> TN (no nudge)
\end{tabbing}

tex*/

texdoc stlog, do
gen prenudge = 0
replace prenudge = 1 if treatment == "TS"
replace prenudge = 2 if treatment == "TF"
label define prenudge_lbl 0 "TN" 1 "TS" 2 "TF"
label values prenudge prenudge_lbl
tab prenudge
texdoc stlog close

/*tex
``Of the 244 participants in the control group, 161, or 66.0\%, chose a menu
with calorie information. The baseline level of information avoidance was
therefore 34.0\%, bounding the maximum potential treatment effect of the
pre-nudges.''
tex*/

texdoc stlog, do
sum wantinfo if prenudge == 0
local wantinfo0 = 100*r(mean)
disp `wantinfo0'
local avinfo0 = 100 - `wantinfo0'
disp `avinfo0'
disp "Control: Avoidance: " %4.1f `avinfo0'
texdoc stlog close

/*tex
``The first pre-nudge, which aimed to increase participants' self-efficacy,
reduced information avoidance to 26.0\%, implying a treatment effect of 8.0
percentage points ($p = 0.0275$ and $p=0.0346$ from a \emph{t}-test and a
Fisher's exact test, both one-sided).''

According to
\href{https://www.langsrud.com/stat/fisher.htm}{https://www.langsrud.com/stat/fisher.htm},
a right-tailed test is appropriate ``when the alternative to independence is
that there is positive association between the variables.'' Here we expect the
prenudge (\verb~prenudge~ = 1 rather than 0) to increase information uptake
(\verb~wantinfo~ = 1 rather than 0).
tex*/

texdoc stlog, do
sum wantinfo if prenudge == 1
local wantinfo1 = 100*r(mean)
local avinfo1 = 100 - `wantinfo1'
local diff1 = `avinfo0' - `avinfo1'
quietly ttest wantinfo if prenudge == 0 | prenudge == 1, by(prenudge)
disp "Prenudge 1: Avoidance: " %4.1f `avinfo1' "; Effect: " %4.1f `diff1' "% t-test: " %5.4f r(p_l)
texdoc stlog close

texdoc stlog, nodo /**/
preserve
keep if prenudge == 0 | prenudge == 1
quietly ritest prenudge _b[prenudge], right seed(0.5) dots reps(5000): ///
    reg wantinfo prenudge
display "FE ritest: " %5.4f r(p)[1,1]
restore
texdoc stlog close

/*tex
``The second pre-nudge, which aimed to focus participants' attention on health
risks from overeating, reduced information avoidance to 28.1\%, implying a
treatment effect of 5.9 percentage points ($p=0.0813$ and
$p=0.0944$)'' 
tex*/

texdoc stlog, do
sum wantinfo if prenudge == 2
local wantinfo2 = 100*r(mean)
disp `wantinfo2'
local avinfo2 = 100 - `wantinfo2'
disp `avinfo2'
local diff2 = `avinfo0' - `avinfo2'
disp `diff2'
quietly ttest wantinfo if prenudge == 0 | prenudge == 2, by(prenudge)
disp "Prenudge 2: Avoidance: " %4.1f `avinfo2' "; Effect: " %4.1f `diff2' "% t-test: " %5.4f r(p_l)
texdoc stlog close

texdoc stlog, nodo /**/
preserve
keep if prenudge == 0 | prenudge == 2
quietly ritest prenudge _b[prenudge], right seed(0.5) dots reps(5000): ///
    reg wantinfo prenudge
display "FE ritest: " %5.4f r(p)[1,1]
restore
texdoc stlog close

/*tex
''The slight difference in the two pre-nudges' effects is not statistically
  significant (F-test $p = 0.606$).''
tex*/

texdoc stlog, do
mark TS if treatment == "TS"
mark TF if treatment == "TF"
reg wantinfo TS TF
test TS = TF
texdoc stlog close


/*tex The pre-nudges therefore achieved respectively 23\% and 17\% of the
maximum potential treatment effect. tex*/

texdoc stlog, do
local pct_change1 = 100*`diff1'/`avinfo0'
disp `pct_change1'

local pct_change2 = 100*`diff2'/`avinfo0'
disp `pct_change2'

texdoc stlog close


/*tex
\setcounter{figure}{2}
``Figure \ref{fig:wtaHistogram} shows the distribution of the monetary value of
calorie information by experimental group. Participants who chose to receive
the menu with information had to be paid to give it up, so their valuation is
positive. Conversely, those who chose the menu without information had to be
paid to receive it, so their valuation is negative.''

tex*/

texdoc stlog, nodo /**/

// Generate valinfo categories
gen valinfo_remap = .
replace valinfo_remap = 0  if valinfo == -5
replace valinfo_remap = 1  if valinfo == -4
replace valinfo_remap = 2  if valinfo == -2.75
replace valinfo_remap = 3  if valinfo == -2.25
replace valinfo_remap = 4  if valinfo == -1.75
replace valinfo_remap = 5  if valinfo == -1.25
replace valinfo_remap = 6  if valinfo == -0.875
replace valinfo_remap = 7  if valinfo == -0.625
replace valinfo_remap = 8  if valinfo == -0.375
replace valinfo_remap = 9  if round(valinfo,0.01) == -0.13 
replace valinfo_remap = 10 if round(valinfo,0.01) == -0.01
replace valinfo_remap = 11 if round(valinfo,0.01) == 0.01
replace valinfo_remap = 12 if round(valinfo,0.01) == 0.13
replace valinfo_remap = 13 if valinfo == 0.375
replace valinfo_remap = 14 if valinfo == 0.625
replace valinfo_remap = 15 if valinfo == 0.875
replace valinfo_remap = 16 if valinfo == 1.25
replace valinfo_remap = 17 if valinfo == 1.75
replace valinfo_remap = 18 if valinfo == 2.25
replace valinfo_remap = 19 if valinfo == 2.75
replace valinfo_remap = 20 if valinfo == 4
replace valinfo_remap = 21 if valinfo == 5

// Generate x-axis labels
#delimit ;
label define valinfo_labels
    0  "-5"
    1  "-4"
    2  "-2.75" 
    3  "-2.25" 
    4  "-1.75" 
    5  "-1.25" 
    6  "-0.875"
    7  "-0.625"
    8  "-0.375"
    9  "-0.13" 
    10 "-0.01"
    11  "0.01" 
    12  "0.13" 
    13  "0.375"
    14  "0.625"
    15  "0.875"
    16  "1.25" 
    17  "1.75" 
    18  "2.25" 
    19  "2.75" 
    20  "4"
    21  "5"
    ;

#delimit cr

// Nudge the TS values a bit to the left and the TF ones a bit to the right
gen valinfo_remap_TS = valinfo_remap - 0.2 if treatment == "TS"
gen valinfo_remap_TN = valinfo_remap       if treatment == "TN"
gen valinfo_remap_TF = valinfo_remap + 0.2 if treatment == "TF"

// Attach the labels
label values valinfo_remap_TS valinfo_labels
label values valinfo_remap_TN valinfo_labels
label values valinfo_remap_TF valinfo_labels

by valinfo treatment, sort: gen freq = _N

// Generate the bar graph
#delimit ; 
twoway  (bar freq valinfo_remap_TS if treatment == "TS", 
            barwidth(0.2) fcolor(maroon%50) lcolor(none)) 
        (bar freq valinfo_remap_TN if treatment == "TN", 
            barwidth(0.2) fcolor(gs10%30) lcolor(none)) 
        (bar freq valinfo_remap_TF if treatment == "TF", 
            barwidth(0.2) fcolor(forest_green%50) lcolor(none))
        , 
        xline(10.5, lpattern(dash))
        ylabel(,ang(h))
        ytitle(Frequency)
        xlabel(0(1)21, valuelabel ang(v)) 
        xtitle("WTA (in USD)")
        legend(order(1 "Prenudge 1 (Self-efficacy)" 2 "Control" 3 "Prenudge 2 (Health risks)") ///
                position(11) ring(0) cols(1) ///
               region(lstyle(none))) 
        ;

#delimit cr

graph export "figures/wta_histogram.pdf", replace              ///
        width(10) height(5)

texdoc stlog close

texdoc write \begin{figure}[H]
texdoc write \caption{Distribution of the monetary value of calorie information.\label{fig:wtaHistogram}}
texdoc write \centering\includegraphics[width=\textwidth]{figures/wta_histogram.pdf}
texdoc write \end{figure}


/*tex 

``For participants in the control group, the average value was \$0.48.''
tex*/

texdoc stlog, do
summ valinfo if prenudge == 0
local valinfo0 = r(mean)
disp "Control Value: " %4.2f `valinfo0'
texdoc stlog close

/*tex
Both pre-nudges increased the average value to \$0.80,
tex*/

texdoc stlog, do
summ valinfo if prenudge == 1
local valinfo1 = r(mean)
disp "Prenudge 1 Value: " %4.2f `valinfo1'
summ valinfo if prenudge == 2
local valinfo2 = r(mean)
disp "Prenudge 2 Value: " %4.2f `valinfo2'
texdoc stlog close

/*tex
which implies a treatment effect of \$0.32 
tex*/

texdoc stlog, do
local diff1 = `valinfo1' - `valinfo0'
disp "Prenudge 1 Effect: " %4.2f `diff1'
local diff2 = `valinfo2' - `valinfo0'
disp "Prenudge 2 Effect: " %4.2f `diff2'
texdoc stlog close

/*tex
``($p=0.0396$ and $p=0.0362$ for the first, self-efficacy pre-nudge,''

Again, a right-tailed FE test is appropriate, because we expect the
prenudge (\verb~prenudgec~ = 1 rather than 0) to increase the value of
information (\verb~valinfo~ increases).
tex*/

texdoc stlog, nodo /**/
quietly ttest valinfo if prenudge == 0 | prenudge == 2, by(prenudge)
disp "Prenudge 1 t-test: " %5.4f r(p_l)

preserve
keep if prenudge == 0 | prenudge == 1
quietly ritest prenudge _b[prenudge], right seed(0.5) dots reps(5000): ///
    reg valinfo prenudge
display "FE ritest: " %5.4f r(p)[1,1]
restore
texdoc stlog close

/*tex
``and $p=0.0518$ and $p=0.0538$ for the second, health-risk pre-nudge).''
tex*/

texdoc stlog, nodo /**/
quietly ttest valinfo if prenudge == 0 | prenudge == 2, by(prenudge)
disp "Prenudge 2 t-test: " %5.4f r(p_l)

preserve
keep if prenudge == 0 | prenudge == 2
quietly ritest prenudge _b[prenudge], right seed(0.5) dots reps(5000): ///
    reg valinfo prenudge
display "FE ritest: " %5.4f r(p)[1,1]
restore
texdoc stlog close

/*tex
``about 24\% of subjects expressed essential indifference about
getting information or not by indicating willingness to switch at any payment
offered, including \$0.01.''
tex*/

texdoc stlog, do
count if round(valinfo,0.01) == -0.01 | round(valinfo,0.01) == 0.01
local N_indiff = r(N)
count
local N_total = r(N)
local perc_indiff = 100*`N_indiff'/`N_total'
disp %4.0f `perc_indiff' "%"
texdoc stlog close

/*tex

``At the other extreme, about 9\% of subjects expressed strong preferences for
getting information or not by indicating {\em un}willingness to switch at any
payment offered, including \$5.''

tex*/

texdoc stlog, do
count if round(valinfo,0.01) == -5 | round(valinfo,0.01) == 5
local N_extrem = r(N)
local perc_extrem = 100*`N_extrem'/`N_total'
disp %4.0f `perc_extrem' "%"
texdoc stlog close

/*tex
\section{Appendix B. Background questions and descriptive statistics}

Table B.1
tex*/

texdoc stlog, do

#delimit ;
local varlistdesc "
female
age
education
expenses
income
hungrylvl
riskpref
foodsc
BMI
BMI_sr
underweight
normalweight
overweight
obese
healthas_1
healthas_2
healthas_3
goalimp_1
goalimp_2
goalimp_3
wanttolose
dieting
freqinfo
healthlit
"
;

estpost summ `varlistdesc';
eststo descstats;

esttab descstats using tables/descstats.tex,
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
texdoc write \caption{Descriptive statistics: Laboratory experiment\label{tbl:descstats}}
texdoc write \input{tables/descstats}
texdoc write \end{table}

/*tex
\subsection{B.1 Demographic characteristics}

``About half of the participants (47\%) were female."
tex*/

texdoc stlog, do
tab female
texdoc stlog close

/*tex
``The average age of the participants was 22.67.''
tex*/

texdoc stlog, do
summ age
texdoc stlog close

/*tex
``As expected, most of our participants had either some
college education (64\%) or a college degree (27\%), the latter likely driven
by graduate students.''

\begin{figure}[H]
\centering\includegraphics[width=0.4\textwidth]{qualtrics/education}
\end{figure}

tex*/

texdoc stlog, do
tab education
texdoc stlog close

/*tex
``Being students, our participants were relatively poor
compared to average individuals in the US. Most of them (85\%) reported expenses
under \$1,000 per month''
tex*/

texdoc stlog, do
tab expenses
count if expenses <= 1000
local N_explt100 = r(N)
count if !missing(expenses)
local N_exp = r(N)
local perc_explt100 = 100*`N_explt100'/`N_exp'
disp "Percent with expenses less than $1000: " %4.0f `perc_explt100'
texdoc stlog close

/*tex

``which is consistent with the reported pre-tax annual income of less than
\$20,000 for most participants (86\%)''

tex*/

texdoc stlog, do
tab income
count if income < 20000
local N_inclt20000 = r(N)
count if !missing(income)
local N_inc = r(N)
local perc_inclt20000 = 100*`N_inclt20000'/`N_inc'
disp "Percent with income less than $20,000: " %4.0f `perc_inclt20000'
texdoc stlog close

/*tex
\subsection{Psychological factors}

``Only 6\% of the participants reported being \emph{not hungry at
all}, 44\% were \emph{somewhat hungry}, 40\% \emph{hungry}, and 9\% \emph{very
hungry}.''

Code in \verb~getcleanDataExperiment:~

\begin{scriptsize}
\begin{verbatim}
gen hungrylvl  = .
replace hungrylvl = 1 if introhungry == "Not hungry at all"
replace hungrylvl = 2 if introhungry == "Somewhat hungry"
replace hungrylvl = 3 if introhungry == "Hungry"
replace hungrylvl = 4 if introhungry == "Very hungry"
\end{verbatim}
\end{scriptsize}\vspace*{-2.5ex}

tex*/

texdoc stlog, do
tab hungrylvl
texdoc stlog close

/*tex
``To elicit their risk preferences, we used a simple, non-incentivized measure
based on Eckel and Grossman (2002), asking participants to choose
between six lotteries with increasingly risky prospects:

\begin{small}
\begin{itemize}[itemsep=0ex, parsep=0ex]
\item Gamble 1: low \$28, high \$28
\item Gamble 2: low \$24, high \$36
\item Gamble 3: low \$20, high \$44
\item Gamble 4: low \$16, high \$52
\item Gamble 5: low \$12, high \$60
\item Gamble 6: low \,\;\$2, high \$70
\end{itemize}
\end{small}

Starting from Gamble 1, the shares of participants choosing each
gamble were 6\%, 17\%, 36\%, 17\%, 14\%, and 11\%.
''
tex*/

texdoc stlog, do
tab riskpref
texdoc stlog close

/*tex
``We also measured food self-control, using a scale developed by
Haws et al. (2016), which modifies the frequently used general self-control
measure by Tangney et al. (2004). This food self-control scale has been
shown to better explain behavioral responses to nutritional information than do
more general self-control measures Haws et al. (2016). The scale consists of
ten statements, with which participants were asked to state their agreement, from ``very much
disagree'' (1) to ``very much agree'' (5):

\begin{small}
\begin{enumerate}[itemsep=0ex,parsep=0ex] 

\item ``I'm very good at resisting tempting food''
\item ``I have a hard time breaking bad eating habits''
\item ``I eat inappropriate things''
\item ``I eat certain things that are bad for my health, if they are delicious''
\item ``I refuse to overindulge on foods that are bad for me''
\item ``People would say that I have iron self-discipline with my eating''
\item ``I am able to work effectively toward long-term health goals''
\item ``Sometimes I can't stop myself from eating, even if I know it's bad for me''
\item ``I often eat without thinking through the health consequences''
\item ``I wish I had more self-discipline in food consumption''

\end{enumerate}
\end{small}

Our summary measure of food self-control is the sum of the
agreement levels for each statement, flipping the scale for statements 2, 3, 4,
8, 9, and 10. Thus, 50 is the highest level of
food self-control and 10 is the lowest level. Figure~B.1 
shows the distribution.''

tex*/

texdoc stlog, nodo /**/
#delimit ;
twoway  histogram foodsc,  fraction
                  fcolor(gray) lcolor(black) lwidth(thin)
                  xlabel(, nogrid)
                  ylabel(,ang(h) nogrid)
                  plotregion(lcolor(black) lwidth(thin))
                  xtitle("Food self-control")
;
#delimit cr

graph export "figures/oa_selfControl.pdf", replace
texdoc stlog close

texdoc write \begin{figure}[H]
texdoc write \caption{Distribution of levels of food self-control.}
texdoc write \centering\includegraphics[width=0.7\textwidth]{figures/oa_selfControl.pdf}
texdoc write \end{figure}

/*tex
``The average level is 30''
tex*/

texdoc stlog, do
summ foodsc
texdoc stlog close

/*tex
\subsection{B.3 Body weight and Body Mass Index}

``In Figure~B.2 we show weight distributions for female and
male participants. The measured and self-reported distributions are similar,''
tex*/


texdoc stlog, do

#delimit ;

twoway (kdensity weight    if female == 1, lpattern(solid) lcolor(black) lwidth(thick))
       (kdensity weight_sr if female == 1, lpattern(dash) lcolor(gs8) lwidth(thick))
    ,
    ylabel(,ang(h) nogrid)
    xlabel(, nogrid)
    ytitle("Density")
    xtitle("Pounds")
    aspectratio(0.75)
    legend(on order(1 "Measured" 2 "Self-reported")
        textfirst cols(1) ring(0) pos(2) region(lstyle(none)))
    title("Women")
    note("Epanechnikov kernel function")
    plotregion(lstyle(solid) lcolor(black))
    saving("figures/weight_f.gph", replace);

twoway  (kdensity weight    if female == 0, lpattern(solid) lcolor(black) lwidth(thick))
        (kdensity weight_sr if female == 0, lpattern(dash) lcolor(gs8) lwidth(thick)),
    ylabel(,ang(h) nogrid)
    xlabel(, nogrid)
    ytitle("Density")
    xtitle("Pounds")
    aspectratio(0.75)
    legend(on order(1 "Measured" 2 "Self-reported")
        textfirst cols(1) ring(0) pos(2) region(lstyle(none)))
    title("Men")
    note("Epanechnikov kernel function")
    plotregion(lstyle(solid) lcolor(black))
    saving("figures/weight_m.gph", replace);

graph combine "figures/weight_f.gph"
              "figures/weight_m.gph"
              ,
              cols(2) xsize(8) ysize(3);

graph export "figures/oa_weight.pdf", replace;
;
#delimit cr

texdoc stlog close

texdoc write \begin{figure}[H]
texdoc write \caption{Measured and self-reported body weight}
texdoc write \centering\includegraphics[width=\textwidth]{figures/oa_weight.pdf}
texdoc write \end{figure}

/*tex
``On average, participants reported a level of confidence of 71\% in
  their report''
tex*/

texdoc stlog, do
summ weight_sr_conf
texdoc stlog close

/*tex
``and over 80\% of the participants said the last time they
  weighed themselves was a month ago or less.''

Code in \verb~getcleanDataBackground.do~

\begin{scriptsize}
\begin{verbatim}
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
\end{verbatim}
\end{scriptsize}\vspace*{-2.5ex}

tex*/

texdoc stlog, do
tab last_weighed
count if last_weighed >= 4 
local N_last_weighedgt4 = r(N)
count if !missing(last_weighed)
local N_last_weighed = r(N)
local perc_last_weighedgt4 = 100*`N_last_weighedgt4'/`N_last_weighed'
disp "Percent last weighed a month ago or less: " %4.0f `perc_last_weighedgt4'
texdoc stlog close

/*tex
``4\% described themselves as underweight, 75\% as normal weight, 19\% as
overweight, and 2\% as obese.''
tex*/

texdoc stlog, do
summ underweight
summ normalweight
summ overweight
summ obese
texdoc stlog close

/*tex
``People who consider themselves healthy or aspire to better health might respond
differently to calorie information or pre-nudges. We therefore elicited
measures of self-assessed health and health aspirations using four statements,
with which participants were asked to state their agreement, from ``very much
disagree'' (1) to ``very much agree'' (5):

\begin{small}
\begin{enumerate}[itemsep=0ex,parsep=0ex]
\item ``I am in excellent health''
\item ``I would benefit from eating healthier''
\item ``I wish I could make healthier food choices at home''
\item ``I wish I could make healthier food choices when eating out''
\end{enumerate} 
\end{small}

The average level of agreement with each statement was 3.5, 4.3, 3.5, and
3.5.''
tex*/

texdoc stlog, do
summ healthas_1
summ healthas_2
summ healthas_3
summ healthas_4
texdoc stlog close

/*tex
``Some people care a lot about eating well, exercising regularly, and maintaining
a healthy body weight, while others do not care at all. Since this might affect
their response to calorie information, we elicited their opinions using three
questions, to which participants could answer either ``not at all important'' (1),
``slightly important'' (2), ``moderately important'' (3), ``very important''
(4), or ``extremely important'' (5).

\begin{small}
\begin{enumerate}[itemsep=0ex,parsep=0ex]
\item ``How important is it to you that the food you eat is healthy?''
\item ``How important is it to you to exercise regularly?''
\item ``How important is it to you to be of a healthy body weight?''
\end{enumerate}
\end{small}

The average answer to each question was 3.5, 3.9, and 4.0.''
tex*/

texdoc stlog, do
summ goalimp_1
summ goalimp_2
summ goalimp_3
texdoc stlog close

/*tex
``51\% of participants said they wanted to lose weight, a result that was driven by females
(67\%) as opposed to males (37\%).''
tex*/

texdoc stlog, do
summ wanttolose
summ wanttolose if female == 1
summ wanttolose if female == 0
texdoc stlog close

/*tex

few participants reported actively following any diet (16\% of females and 13\% of males)

tex*/

texdoc stlog, do
summ dieting if female == 1
summ dieting if female == 0
texdoc stlog close

/*tex
``Despite the mandatory availability of calorie information in all
fast-food chains in Laramie, the town where the University of Wyoming is
located, only 32\% of participants recalled seeing such information often or
always, another 46\% recalled seeing it sometimes, and the rest recalled seeing
it rarely or never.''

Code in \verb~getcleanDataBackground.do~

\begin{scriptsize}
\begin{verbatim}
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
\end{verbatim}
\end{scriptsize}\vspace*{-2.5ex}

tex*/

texdoc stlog, do
tab freqinfo
count if freqinfo >= 4 
local N_freqinfogt4 = r(N)
count if !missing(freqinfo)
local N_freqinfo = r(N)
local perc_freqinfogt4 = 100*`N_freqinfogt4'/`N_freqinfo'
disp "Percent see often or always: " %4.0f `perc_freqinfogt4'
texdoc stlog close

/*tex

``most participants (70\%) knew that the common recommendation for calorie
intake for an average adult per day is 2500 calories''

tex*/

texdoc stlog, do
summ healthlit
texdoc stlog close


/*tex
``Table \ref{tab:mturk_valueInfo}~shows the treatment effect
of each pre-nudge on that value in the online experiment and, for reference,
the laboratory experiment. The fourth and fifth columns shows $p$-values from
respectively a $t$-test and a Fisher's exact test, both one-sided. We do
not have an explanation for why, in the online experiment, the treatment effect
is negative for prenudge~1.''

\begin{table}[h]
\centering
\begin{tabular}{@{}lcd{3}cc@{}}
\toprule
 & & \multicolumn{1}{c}{\textbf{Effect}} & \textbf{$t$-test} & \textbf{FE test} \\
\textbf{Experiment}& \textbf{Treatment} & \multicolumn{1}{c}{\textbf{(\$)}} &
\textbf{($p$-value)} & \textbf{($p$-value)} \\ \midrule
Online              & Prenudge 1         & -0.082         & .6400           & .6534        \\
Laboratory          & Prenudge 1         &  0.318         & .0396           & .0362        \\
Online              & Prenudge 2         &  0.345         & .0582           & .0540        \\
Laboratory          & Prenudge 2         &  0.323         & .0518           & .0538        \\
Online              & Prenudge 3         &  0.362         & .0640           & .0636        \\
Online              & Prenudge 4         &  0.218         & .1908           & .1906        \\ \bottomrule
\end{tabular}
\caption{Effect of pre-nudges on the value of information}
\label{tab:mturk_valueInfo}
\end{table}

tex*/

texdoc stlog, do
foreach pn of numlist 1/2 {
  quietly ttest valinfo if prenudge == 0 | prenudge == `pn', by(prenudge)
  local diff = r(mu_2) - r(mu_1)
  display "Prenudge `pn' Effect: " %6.3f `diff' ", t-test: " %5.4f r(p_l)
}
texdoc stlog close



/*tex

``Table~\ref{tab:mturk_mainEffects} shows the treatment effect of each prenudge
in the online experiment and, for reference, the laboratory experiment.''

\begin{table}[h]
\centering
\begin{tabular}{@{}lcd{-1}cc@{}}
\toprule
& & \multicolumn{1}{c}{\textbf{Effect}} & \textbf{$t$-test} & \textbf{FE test} \\
\textbf{Experiment}& \textbf{Treatment} & \multicolumn{1}{c}{\textbf{(p.p.)}} &
\textbf{($p$-value)} & \textbf{($p$-value)} \\ \midrule
Online              & Prenudge 1         & 6.2           & .1691           & .2176        \\
Laboratory          & Prenudge 1         & 8.0           & .0275           & .0346        \\
Online              & Prenudge 2         & 14.6          & .0072           & .0104        \\
Laboratory          & Prenudge 2         & 5.9           & .0813           & .0944        \\
Online              & Prenudge 3         & 12.4          & .0214           & .0342        \\
Online              & Prenudge 4         & 3.8           & .2818           & .3372        \\ \bottomrule
\end{tabular}
\caption{Effect of pre-nudges on information avoidance}
\label{tab:mturk_mainEffects}
\end{table}

tex*/

texdoc stlog, do
foreach pn of numlist 1/2 {
  quietly ttest wantinfo if prenudge == 0 | prenudge == `pn', by(prenudge)
  local diff = r(mu_2) - r(mu_1)
  display "Prenudge `pn' Effect: " %4.3f `diff' ", t-test: " %5.4f r(p_l)
}
texdoc stlog close



if (`dorest') {

}

/*tex
\end{document}
tex*/

set more off
! /Library/TeX/Distributions/.DefaultTeX/Contents/Programs/texbin/pdflatex replicateExperiment
