
# Q4: TLG — Adverse Events Reporting

Produces tables, listings, and graphs for adverse event reporting 
using ```pharmaverseadam::adae``` and ```pharmaverseadam::adsl.```

## Outputs

### Summary Table (01_create_ae_summary_table.R)
- Treatment-emergent AEs summarised by organ class and AE term
- Columns: Placebo, Xanomeline High Dose, Xanomeline Low Dose
- Denominator taken from adsl for accurate subject-level percentages
- Output: output/ae_summary_table.html

### Visualisations (02_create_visualizations.R)
- Plot 1: Stacked bar chart of AE severity by treatment arm
  Output: ```output/ae_barchart.png```
- Plot 2: Forest plot of top 10 most frequent AEs with 95% 
  Clopper-Pearson confidence intervals
  Output: ```output/ae_forest_plot.png```

### Listing (03_create_listings.R)
- Detailed listing of treatment-emergent AEs per subject
- Sorted by subject ID and AE start date
- Output: ```output/ae_listing.html```

## How to Run
Run each script independently. Outputs are saved to output/ folder.