clear all

/* Load the raw Experiment, Background, and Weights data */
*texdoc do getrawData

/* Clean the Experiment data */
*texdoc do getcleanDataExperiment

/* Clean the Background data */
*texdoc do getcleanDataBackground

/* Clean the Weight data */
*texdoc do getcleanDataWeight

/* Merge the three datasets and create new variables */
* texdoc do getcleanDataAll

/* Replicate the analyis of the main experiment reported in the paper */
*texdoc do replicateExperiment

/* Do new analysis for R&R */
*texdoc do newAnalysis

/* Try replicating (with possible minor changes due to weight cleanup) the
scatterplots */
*texdoc do doGsreg

/* Check differences between Tabaré's data and mine */
*texdoc do compareData

/* Get the Mturk data */
*texdoc do getrawDataMturk
*texdoc do getcleanDataMturk

/* Replicate the Mturk analysis */
*texdoc do replicateMturk

