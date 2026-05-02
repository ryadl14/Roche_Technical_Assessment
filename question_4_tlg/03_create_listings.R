library(pharmaverseadam)
library(dplyr)
library(gt)

adae <- pharmaverseadam::adae

adae_listing <- adae %>%
  filter(TRTEMFL == "Y") %>% # Filter by treatment emergent events
  select(USUBJID, ACTARM, AETERM, AESEV, AEREL, AESTDTC, AEENDTC) %>% # Select the relevant columns
  arrange(USUBJID, AESTDTC) # Arrange in order of subject and AE start time.
  
adae_listing %>%
  gt() %>%
  gtsave("ae_listing.html", path = "question_4_tlg/output")
  