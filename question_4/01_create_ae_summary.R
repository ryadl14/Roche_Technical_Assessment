install.packages("pharmaverseadam")
install.packages("gtsummary")
library(pharmaverseadam)
library(dplyr)
library(tidyr)
library(ggplot2)
library(gtsummary)
library(gt)

setwd("~/Desktop/Roche_Tech_Assessment/question_4/")

# Save dataset as object
adae <- adae

# Only retain Treatment Emergent AEs
filtered_adae <- filter(adae, TRTEMFL == "Y")

# Only keep the important columns
summarised_adae <- filtered_adae %>%
  select(USUBJID, ACTARM, AESOC, AETERM)

# Important columns
adae["TRTEMFL"] # Treatment Emergent Analysis Flag
adae["ACTARM"] # Description of Actual Arm = Group
adae["AESOC"] # Primary System Organ Class
adae["AETERM"] # Reported Term for the AE

# Subset the adsl dataset to only hold unique subject_id and group
adsl_subset = adsl %>%
  select(USUBJID, ACTARM)

# Each subject only has one type of organ class
deduplicated_by_organ <- distinct(filtered_adae, USUBJID, AESOC, ACTARM)

# Each subject only has one type of AE
deduplicated_by_ae <- distinct(filtered_adae, USUBJID, AETERM, ACTARM)

# Counts the number of AEs per group.
num_of_TEAE <- distinct(filtered_adae, USUBJID, ACTARM) %>%
  count(ACTARM)

# ==========================

TEAE <- distinct(filtered_adae, USUBJID, ACTARM) %>%
  mutate(AE = "Treatment Emergent AEs", .before = 1)

TEAE_summary <- TEAE |> tbl_summary(
  by = ACTARM,
  include= c(AE)
) |>
remove_row_type(AE, type = "header")

print(TEAE_summary)
# ==========================


# Creates a summary table of the three groups by organ class
by_organ_summary <- deduplicated_by_organ |> tbl_summary(
  by = ACTARM, 
  include = c(AESOC), 
  sort = all_categorical(FALSE) ~ "frequency",
  percent = adsl_subset,
)

gt_organ <- as_gt(by_organ_summary)

# =======================

#Creates a summary table of the three groups by type of AE
by_ae_summary <- deduplicated_by_ae |> tbl_summary(
  by = ACTARM, 
  include = c(AETERM), 
  sort = all_categorical(FALSE) ~ "frequency",
  percent = adsl_subset
)

gt_ae <- as_gt(by_ae_summary)
class(gt_ae)


# =======================

full_tbl <- tbl_stack(list(
  TEAE_summary,
  by_organ_summary,
  by_ae_summary
))

print(full_tbl)

as_gt(full_tbl) |>
  gtsave("ae_summary_table.html", path = "./output/")


