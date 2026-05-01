# == Libraries ==================================================
library(pharmaverseraw)
library(sdtm.oak)
library(dplyr)

# == Load raw data and CT =======================================
ds_raw <- pharmaverseraw::ds_raw
study_ct <- read.csv("~/Desktop/Roche_Tech_Assessment/question_2/ct_data/sdtm_ct.csv")

ds_raw <- ds_raw %>%
  generate_oak_id_vars(pat_var = "PATNUM", raw_src = "ds_raw")

# == Topic variable: DSDECOD via CT mapping =====================
ds <- assign_ct(
  raw_dat = ds_raw,
  raw_var = "IT.DSTERM",
  tgt_var = "DSDECOD",
  ct_spec = study_ct,
  ct_clst = "C66727",
  id_vars = oak_id_vars()
)

# == Temporarily add OTHERSP to ds for conditioning =============
ds <- ds %>%
  left_join(select(ds_raw, oak_id, OTHERSP), by = "oak_id")


# == Mapping IT.DSDECOD to DSDECOD if OTHERSP = NA ==============
cnd_othersp <- condition_add(ds, is.na(OTHERSP))
ds <- assign_no_ct(
    tgt_dat = cnd_othersp,
    tgt_var = "DSDECOD",
    raw_dat = ds_raw,
    raw_var = "IT.DSDECOD"
  ) # aCRF: programming note 2


# == DSTERM: OTHERSP first, then IT.DSTERM for remaining NAs ====
ds <- ds %>%
  mutate(DSTERM = case_when( 
    !is.na(OTHERSP) ~ OTHERSP, # When OTHERSP is not null, map OTHERSP to DSTERM   | #aCRF programming note 4
    TRUE ~ ds_raw$IT.DSTERM[match(oak_id, ds_raw$oak_id)] # aCRF: programming note 6
  ))

# == DSCAT Mappings =============================================
ds <- ds %>%
  mutate(DSCAT = case_when(
    DSDECOD == "RANDOMIZED"  ~ "PROTOCOL MILESTONE", # Maps DSCAT as PROTOCOL MILESTONE if DSDECOD == "RANDOMIZED"   | aCRF: programming note 3
    !is.na(OTHERSP)          ~ "OTHER EVENT",        # If OTHERSP != null, mapp DSCAT to OTHER EVENT                 | aCRF: programming note 5
    TRUE                     ~ "DISPOSITION EVENT",  # If previous conditions not met, map as DISPOSITION EVENT      | aCRF: programming note 3
  ))

ds <- ds %>%
  mutate(DSDECOD = case_when(
    !is.na(OTHERSP) ~ OTHERSP, #aCRF programming note 4
    TRUE            ~ DSDECOD
  ))

# == Remaining variable mappings ================================
ds <- assign_no_ct(tgt_dat = ds, raw_dat = ds_raw, raw_var = "STUDY",      tgt_var = "STUDYID",  id_vars = oak_id_vars())
ds <- assign_no_ct(tgt_dat = ds, raw_dat = ds_raw, raw_var = "INSTANCE",   tgt_var = "VISIT",    id_vars = oak_id_vars())
ds <- assign_no_ct(tgt_dat = ds, raw_dat = ds_raw, raw_var = "IT.DSSTDAT", tgt_var = "DSSTDTC",  id_vars = oak_id_vars()) # aCRF: programming note 1
ds <- assign_no_ct(tgt_dat = ds, raw_dat = ds_raw, raw_var = "DSDTCOL",    tgt_var = "DSDTC",    id_vars = oak_id_vars())

# == Temporarily add DSTMCOL to ds ==============================
ds <- ds %>%
  left_join(select(ds_raw, oak_id, DSTMCOL), by = "oak_id")

# == DSDTC with ISO 8601 formatting =============================
ds <- ds %>%
  mutate(DSDTC = case_when(
    !is.na(DSTMCOL) ~ format(as.Date(DSDTC, "%m-%d-%Y"), "%Y-%m-%d") |> paste(DSTMCOL, sep = "T"), # aCRF: programming note 7
    TRUE            ~ format(as.Date(DSDTC, "%m-%d-%Y"), "%Y-%m-%d") # Formats in ISO8601 standard
  )) %>%
  select(-DSTMCOL) # Drops the DSTMCOL column.

# == Fixing DSSTDTC formatting ==================================
ds <- ds %>%
  mutate(
    DSSTDTC = format(as.Date(DSSTDTC, "%m-%d-%Y"), "%Y-%m-%d")
  )

# == USUBJID and VISITNUM derived on ds =========================
ds <- ds %>%
  mutate(
    USUBJID = paste(STUDYID, patient_number, sep = "-"),
    VISITNUM = case_when(
      VISIT == "Screening 1" ~ 1,
      VISIT == "Baseline"    ~ 2,
      VISIT == "Week 2"      ~ 3,
      VISIT == "Week 4"      ~ 4,
      VISIT == "Week 6"      ~ 5,
      VISIT == "Week 8"      ~ 6,
      VISIT == "Week 12"     ~ 7,
      VISIT == "Week 16"     ~ 8,
      VISIT == "Week 20"     ~ 9,
      VISIT == "Week 24"     ~ 10,
      VISIT == "Week 26"     ~ 11,
      TRUE                   ~ NA_real_
    )
  )

# == DOMAIN hardcoded as DS =====================================
ds <- hardcode_no_ct(
  tgt_dat = ds,
  tgt_var = "DOMAIN",
  tgt_val = "DS",
  raw_dat = ds_raw,
  raw_var = "raw_source",
  id_vars = oak_id_vars()
)

# == Drop temporary OTHERSP column ==============================
ds <- ds %>% select(-OTHERSP)

# == Create the DSSEQ column ====================================
ds <- ds %>%
  group_by(USUBJID) %>%
  mutate(DSSEQ = row_number()) %>%
  ungroup()

# == Reorder the data ===========================================
ds <- ds %>%
  select(STUDYID, DOMAIN, USUBJID, DSSEQ, DSTERM, DSDECOD, DSCAT, VISITNUM, VISIT, DSDTC, DSSTDTC) %>%
  arrange(USUBJID, DSSEQ)





