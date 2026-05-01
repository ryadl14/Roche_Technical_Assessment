install.packages("pharmaverseadam")
install.packages("gt")
library(pharmaverseadam)
library(ggplot2)
library (gt)
library(dplyr)

adae <- adae 

#### Plot 1 ####

ggplot(adae, aes(fill = AESEV, x = ACTARM)) +
  geom_bar(position="stack", stat = "count") +
  ggtitle("AE severity distribution by treatment") +
  labs(x = "Treatment Arm", y = "Count of AEs") +
  theme_bw() 

ggsave("ae_barchart.png", path = "output/")
  
################


##### Plot 2 #####

adsl <- adsl
n_rows_adsl <- nrow(adsl) # Gets the number of rows in adsl to get the number of subjects 

####

top_ten_ae <- distinct(adae, USUBJID, AETERM, ACTARM) %>% # Retain only the important columns.
  count (AETERM) %>% # Count the number of each AE
  mutate(Total = n_rows_adsl) %>% # Creates a total column
  mutate("Incidence" = (n / n_rows_adsl)) %>% # Creates Incidence by dividing the number of each AE by the total number of AEs.
  arrange(desc(Incidence)) %>% # Sort in descending order
  slice(1:10) %>% # Retain the top 10.
  rowwise() %>%
  mutate(CI_lower = binom.test(n, Total)$conf.int[1], # Makes upper and lower bound columns for the CIs.
         CI_upper = binom.test(n, Total)$conf.int[2])


####

ggplot(top_ten_ae, aes(x = Incidence, y = reorder(AETERM, Incidence))) + # Adverse events put in descending orde of incidence
  geom_point(size = 2) +
  geom_errorbarh(aes(xmin = CI_lower, xmax = CI_upper), linewidth = 0.5) +
  ggtitle ("Top 10 Most Frequent Adverse Events") +
  scale_x_continuous(
    breaks = c(0.05, 0.10, 0.15, 0.20, 0.25), # Manually set the breaks (could have been done automatically using the scales package though)
    label = c("5%","10%", "15%", "20%", "25%")) + 
  labs(x = "Percentage of Patients (%)", y = "Adverse Event", subtitle = "n = 306, 95% CIs") +
  theme_bw()

ggsave("ae_forest_plot.png", path = "output/") # Saves to the output folder.


####

adae_listing <- adae %>%
  filter(TRTEMFL == "Y") %>% # Filter by treatment emergent events
  select(USUBJID, ACTARM, AETERM, AESEV, AEREL, AESTDTC, AEENDTC) %>% # Select the relevant columns
  arrange(USUBJID, AESTDTC) # Arrange in order of subject and AE start time.
  
adae_listing %>%
  gt() %>%
  gtsave("ae_listing.html", path = "output/")
  
