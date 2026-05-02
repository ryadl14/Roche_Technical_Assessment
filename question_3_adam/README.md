# Q3: ADaM ADSL Dataset Creation

Derives a subject-level ADSL dataset from SDTM source data using 
{admiral}.

## Approach
DM domain used as the backbone (one row per subject). Six additional 
variables derived:

- AGEGR9/AGEGR9N: age groupings using derive_vars_cat()
- TRTSDTM: first valid exposure datetime from EX, with time imputation 
  to minute level using derive_vars_dtm() and derive_vars_merged()
- ITTFL: Y/N randomisation flag based on ARM population
- ABNSBPFL: Y/N flag for abnormal systolic BP (<100 or >=140 mmHg)
  using derive_var_merged_exist_flag()
- LSTALVDT: last known alive date across VS, AE, DS, and EX sources 
  using derive_vars_extreme_event()
- CARPOPFL: Y/NA cardiac adverse event flag

## Input
```pharmaversesdtm::dm```, ```ex```, ```vs```, ```ae```, ```ds```

## Output
ADSL with all required variables with a full DM backbone.

## Script
```create_adsl.R```