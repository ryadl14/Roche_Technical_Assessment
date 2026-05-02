# Q2: SDTM DS Domain Creation

Maps raw disposition data to a CDISC-compliant DS domain using 
{sdtm.oak}.

## Approach
- Raw data source: pharmaverseraw::ds_raw
- Controlled terminology: study_ct (CDISC C66727 codelist)
- Topic variable DSDECOD derived via assign_ct() with CT mapping
- DSCAT derived conditionally per aCRF programming notes:
  - PROTOCOL MILESTONE when DSDECOD = RANDOMIZED
  - OTHER EVENT when OTHERSP is not null
  - DISPOSITION EVENT for all remaining records
- DSTERM derived from OTHERSP when populated, else IT.DSTERM
- Dates reformatted to ISO8601 (YYYY-MM-DD, with time where available)

## Input
```pharmaverseraw::ds_raw```, study_ct CSV

## Output
DS domain with variables: STUDYID, DOMAIN, USUBJID, DSSEQ, DSTERM, 
DSDECOD, DSCAT, VISITNUM, VISIT, DSDTC, DSSTDTC

## Limitation
DSSTDY not derived — requires reference start date from EX domain.

## Script
```
02_create_ds_domain.R
```