install.packages("admiral")
install.packages("pharmaversesdtm")
library(admiral)
library(pharmaversesdtm)

dm <- pharmaversesdtm::dm

# == Output variables =====
# AGEGR9   = Age grouping (Categories = "<18", "18 - 50", ">50")
# AGEGR9N  = Age grouping (Numeric: 1 = <18, 2 = 18 - 50, 3 = >50)
# TRTSDTM  = Treatment start time (using the first exposure record and imputing missing hours and minutes but not seconds)
# ITTFL    = Y/N flag for randomisation
# ABNSBPFL = Y/N for supine sBP <100 or >=140mmHg
# LSTALVDT = Last known alive data using any vital signs, AE start date, disposition record or exposure record.
# CARPOPFL = Y/NA flag for cardiac AE.

adsl <- dm %>%
  select(-DOMAIN) %>% # Dropped domain as it is a SDTM-specific variable.
  mutate(TRT01P = ARM, TRT01A = ACTARM) # Planned and actual treatment columns

## == AGEGR9 and AGER9N ===================
agegr9_lookup <- exprs(
  ~condition,           ~AGEGR9, # A blueprint on how the AGEGR9 column should look.
  AGE < 18,               "<18", # If AGE < 18, impute "<18" into AGEGR9
  between(AGE, 18, 50), "18-50", # If AGE is between 18 and 50, impute "18-50" into AGEGR9
  AGE > 50,               ">50"  # If AGE > 50, impute ">50" into AGEGR9
)

agegr9n_lookup <- exprs(
  ~condition,           ~AGEGR9N,
  AGE < 18,               1,
  between(AGE, 18, 50),   2,
  AGE > 50,               3
)

adsl <- adsl %>%
  derive_vars_cat(
    definition = agegr9_lookup
  ) %>%
  derive_vars_cat(
    definition = agegr9n_lookup
  )

## == TRTSDTM extraction from EX ==============

# Extract from EX.EXSTDTC (take from the source data), convert to numeric datetime.
# Derivations should only occur when EX.EXDOSE > 0 OR EXDOSE == 0 and EX.EXTRT contains 'PLACEBO'
# A complete datepart of EX.EXSTDTC is needed prior to derivation.
# If time is missing, impute completely missing time with 00:00:00, partially missing time with 00 for respective time.
# If only seconds are missing then do not populate imputation flag

ex <- pharmaversesdtm::ex

ex_ext <- ex %>%
  derive_vars_dtm(
    dtc = EXSTDTC,               # The raw character column to convert
    new_vars_prefix = "EXST",    # Creates EXSTDTM (datetime) and EXSTTMF (imputation flag)
    highest_imputation = "M",    # Impute missing time but not missing date
    time_imputation = "00:00:00" # Fill missing time with midnight
  ) 

# == Creating TRTSDTM =========================
adsl <- adsl %>%
  derive_vars_merged(
    dataset_add = ex_ext,
    filter_add = (EXDOSE > 0 | # Checking for subject who were dosed
                    (EXDOSE == 0 &
                       str_detect(EXTRT, "PLACEBO"))) & !is.na(EXSTDTM), # Looking for subjects who were placebo
    new_vars = exprs(TRTSDTM = EXSTDTM, TRTSTMF = EXSTTMF),
    order = exprs(EXSTDTM, EXSEQ),
    mode = "first",
    by_vars = exprs(STUDYID, USUBJID)
  )

# == Creating ITTFL ===========================
adsl <- adsl %>% # Spec states Y when ARM is missing, no missing data in adsl.
  mutate(ITTFL = case_when(
    !is.na(ARM) ~ "Y",
    TRUE        ~ "N"
  ))

# == ABNSBPFL extraction from VS =============

vs <- pharmaversesdtm::vs

adsl <- adsl %>%
  derive_var_merged_exist_flag(
    dataset_add = vs,
    by_vars = exprs(STUDYID, USUBJID),
    new_var = ABNSBPFL,
    false_value = "N",
    missing_value = "N",
    
    # Creates a flag that shows Y if they had supine systolic blood pressure <100 or >=140 mmHg
    condition = (VSTESTCD == "SYSBP" & VSSTRESU == "mmHg" & (VSSTRESN >= 140 | VSSTRESN < 100))
  )


# == Creating TRTEDTM: Needed for LSTALVDT ====
adsl <- adsl %>%
  derive_vars_merged(
    dataset_add = ex_ext,
    filter_add = (EXDOSE > 0 | # Checking for subject who were dosed
                    (EXDOSE == 0 &
                       str_detect(EXTRT, "PLACEBO"))) & !is.na(EXSTDTM), # Looking for subjects who were placebo
    new_vars = exprs(TRTEDTM = EXSTDTM),
    order = exprs(EXSTDTM, EXSEQ),
    mode = "last",
    by_vars = exprs(STUDYID, USUBJID)
  )

# == LSTALVDT =================================

# VS.VSSTRESN and VS.VSSTRESC (not both missing) and VS.VSDTC not missing
# AE.AESTDTC
# DS.DSSTDTC
# ADSL.TRTEDTM
# Set to max of (Vitals complete, AE onset complete, disposition complete, treatment complete).

ae <- pharmaversesdtm::ae
ds <- pharmaversesdtm::ds

adsl <- adsl %>%
  derive_vars_extreme_event(
    by_vars = exprs(STUDYID, USUBJID),
    events = list(
      event(
        dataset_name = "vs",
        order = exprs(VSSTRESN, VSSTRESC, VSDTC),
        condition = (!is.na(VSSTRESN) | !is.na(VSSTRESC)) & !is.na(VSDTC),
        set_values_to = exprs(
          LSTALVDT = convert_dtc_to_dt(VSDTC, highest_imputation = "M"),
          seq = VSSEQ
        ),
      ),
      event(
        dataset_name = "ae",
        order = exprs(AESTDTC),
        condition = !is.na(AESTDTC),
        set_values_to = exprs(
          LSTALVDT = convert_dtc_to_dt(AESTDTC, highest_imputation = "M"),
          seq = AESEQ
        ),
      ),
      event(
        dataset_name = "ds",
        order = exprs(DSSTDTC),
        condition = !is.na(DSSTDTC),
        set_values_to = exprs(
          LSTALVDT = convert_dtc_to_dt(DSSTDTC, highest_imputation = "M"),
          seq = DSSEQ
        ),
      ),
      event(
        dataset_name = "adsl",
        condition = !is.na(TRTEDTM),
        set_values_to = exprs(LSTALVDT = date(TRTEDTM), seq = 0), # Save as a date object rather than date time for consistency.
      )
    ),
    source_datasets = list(ds = ds, ae = ae, vs = vs, adsl = adsl),
    tmp_event_nr_var = event_nr,
    order = exprs(LSTALVDT, seq, event_nr),
    mode = "last",
    new_vars = exprs(LSTALVDT)
  )

# == CARPOPFL =================================

adsl <- adsl %>%
  derive_var_merged_exist_flag(
    dataset_add = ae,
    by_vars = exprs(STUDYID, USUBJID),
    new_var = CARPOPFL,
    
    # Creates a flag that shows Y if AESOC is cardiac disorders, converts to uppercase.
    condition = (toupper(AESOC) == "CARDIAC DISORDERS")
  )
        
        
        