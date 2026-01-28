# Replication files

**Paper**: [Show me the labels: Using pre-nudges to reduce calorie information avoidance](https://link.springer.com/article/10.1007/s11166-025-09471-9)

**Coauthors**: [Tabaré Capitán](http://tabarecapitan.com), Linda Thunström, Klaas van ’t Veld, Jonas Nordström, and Jason Shogren

## Contents

- Raw data from two survey experiments  
  - Laboratory experiment  
  - Online experiment  
- Questionnaires underlying the survey experiments  
- Code required to reproduce all results reported in the paper  

## Requirements

Stata 14.2 or higher, with the following user-written commands installed:

- `ritest`
- `gsgreg`
- `grc1leg`
- `texsave`
- `texdoc`

## Instructions

The do-file `it.do` is the main entry point. It calls all scripts required to reproduce the results of the paper in the correct order.  
Please read the next section before running the code.

## Remarks

This repository provides the full set of files needed to reproduce every result reported in the paper. All tables and figures in the published manuscript can be regenerated using the supplied data and code.

That said, transparency and reproducibility go beyond merely sharing data and scripts. While this repository meets the standard required for replication, it should not be interpreted as an example of best practices in research software engineering or version-controlled workflows.

Several limitations are worth noting:

1. **PDF-first workflow**  
   The analysis code is organised around `texdoc`, which generates a combined PDF containing code, output, and commentary for each script. While this provides a complete audit trail, it also makes the code more complex and harder to read, reuse, or extend than a modular script-based structure.

2. **External Stata dependencies**  
   Reproduction requires several user-written Stata commands that are not bundled with the repository. Although this is common in applied work, these dependencies are maintained externally and may change over time. Stata provides limited support for version pinning of such commands, which can affect long-run reproducibility.

3. **Post-publication repository**  
   This repository was assembled after publication and reflects a long-running analysis process that predates systematic use of git for development. As a result, the repository history should not be interpreted as a clean or incremental research timeline.

Readers are therefore encouraged to treat this repository strictly as a replication package for the published paper. For a clear and practical guide to workflows that support robust, transparent, and maintainable open research, see Julian Reif’s guide:  
https://julianreif.com/guide/

This repository and the remarks above are posted by me personally. I am responsible for the analysis underlying the paper and for ensuring that the reported results are correct and reproducible. The structure and style of the code reflect collaborative decisions and historical constraints rather than an attempt to showcase software-engineering practices.

## Citation

You can cite the paper as follows:

**APA**
```
Capitán, T., Thunström, L., van ’t Veld, K., Nordström, J., and Shogren, J. F. (2026).
Show me the labels: Using pre-nudges to reduce calorie information avoidance.
Journal of Risk and Uncertainty, 1–39.
```
**BibTeX**
```
@article{capitan2026show,
  title   = {Show me the labels: Using pre-nudges to reduce calorie information avoidance},
  author  = {Capit{\\'a}n, Tabar{\\'e} and Thunstr{\\"o}m, Linda and van{'}t Veld, Klaas and Nordstr{\\"o}m, Jonas and Shogren, Jason F},
  journal = {Journal of Risk and Uncertainty},
  pages   = {1--39},
  year    = {2026},
  publisher = {Springer}
}
```
