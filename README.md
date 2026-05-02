# Roche Early Development ADS Programmer — Technical Assessment

This repository contains my solutions to the DSX Data Scientist coding 
assessment. The assessment covers R package development, clinical data 
programming using the pharmaverse ecosystem (SDTM/ADaM), data 
visualisation, and Python API development.

## Repository Structure

question_1/ — R Package Development

question_2/ — SDTM DS Domain Creation using {sdtm.oak}

question_3/ — ADaM ADSL Dataset Creation using {admiral}

question_4_tlg/ — TLG Adverse Events Reporting

question_5/ — Clinical Data API (FastAPI)


## Questions Overview

### Q1: R Package — descriptiveStats
An R package implementing six descriptive statistics functions: 

calc_mean(), calc_median(), calc_mode(), calc_q1(), calc_q3(), 
and calc_iqr(). 

The package includes full Roxygen2 documentation, 
edge case handling, and a testthat test suite (19 passing tests).

To install and use:
```r
devtools::install("question_1/descriptiveStats")

library(descriptiveStats)
```

### Q2: SDTM DS Domain
An R script that maps raw disposition data 
(pharmaverseraw::ds_raw) to a CDISC-compliant DS domain using 
{sdtm.oak}. Key derivations include DSDECOD via controlled 
terminology mapping, conditional DSCAT logic per aCRF programming 
notes, and ISO8601 date formatting.

**Input: pharmaverseraw::ds_raw, study_ct (CDISC controlled terminology)**

**Output: ds — a CDISC-compliant DS domain with 11 variables**

**Script: question_2/02_create_ds_domain.R**

*Limitation: DSSTDY not derived — requires first dose date from EX 
domain which was out of scope for this derivation.*

### Q3: ADaM ADSL
An R script that derives an ADSL subject-level dataset from SDTM 
source data using {admiral}. DM is used as the backbone, with six 
additional variables derived: AGEGR9/AGEGR9N (age groupings), 
TRTSDTM (treatment start datetime with imputation), ITTFL 
(ITT population flag), ABNSBPFL (abnormal systolic BP flag), 
LSTALVDT (last known alive date across four sources), and 
CARPOPFL (cardiac adverse event flag).

**Input: pharmaversesdtm::dm, ex, vs, ae, ds**

**Output: adsl — subject-level analysis dataset**

**Script: question_3/create_adsl.R**

### Q4: TLG — Adverse Events Reporting
Three outputs produced from pharmaverseadam::adae and 
pharmaverseadam::adsl:
- AE summary table by treatment arm and organ class (gtsummary)
- AE severity stacked bar chart by treatment arm (ggplot2)
- Forest plot of top 10 AEs with 95% Clopper-Pearson CIs (ggplot2)
- Detailed AE listing filtered to treatment-emergent events (gt)

Scripts: 

**question_4_tlg/01_create_ae_summary_table.R**

**question_4_tlg/02_create_visualizations.R**

**question_4_tlg/03_create_listings**
         
### Q5: Clinical Data API (FastAPI)
A RESTful API built with FastAPI that serves clinical trial adverse 
event data and calculates patient risk scores across three endpoints:

- ```GET /```: Welcome message confirming the API is running
- ```POST /ae-query```: Dynamic filtering by severity and/or treatment arm
- ```GET /subject-risk/{subject_id}```: Weighted safety risk score per subject

Script: ```question_5_api/main.py```

To run:
```bash
cd question_5_api
uvicorn main:app --reload
```

Interactive documentation available at http://127.0.0.1:8000/docs

## How to Run

All R scripts are self-contained and install required packages at 
the top. Run each script from the repo root in RStudio or via 
Rscript. R 4.2.0 or above required.

## Notes

- AI assistance was used in accordance with assessment guidelines, for
  explaining new concepts, error interpretation, and sense-checking.

- Claude Sonnet 4.6 was used with the Learning style to ensure AI acted 
  as a guide and tutor rather than writing code for me.
  All code was written and is understood by the author.

- Q6 (GenAI assistant) was not attempted due to time constraints.
