# Loudon/Fairfax County Data Center Water Consumption


## Overview
This project examines how public water consumption in Loudon and Fairfax County,
Virginia, home to the densest concentration of data centers in the U.S
("Data Center Alley") -- has changed before and after major data center build.
It also investigates whether other factors such as population growth, drought,
industrial/agricultural shifts explain the observed changes, rather than
attributing them to data centers by default.

Inspired by CNN reporting on data centers' contribution to atmospheric heat
release, this project applies similar before/after empirical approach to water
consumption. [Article](https://www.cnn.com/2026/03/30/climate/data-centers-are-having-an-underrported)


## Research Questions
1. How has water withdrawal/consumption in Loudon/Fairfax County changed over
time relative to data center growth?
2. Can changes be attributed specifically to data centers, or are other factors
significant confounders?


## Repo Structure (Subject to change as the project develops)
```
loudoun-fairfax-water-dc/
├── README.md              # project overview, question, data sources, how to reproduce
├── data/
│   ├── raw/               # untouched downloads (USGS, utility PDFs/CSVs) — never edit these
│   └── processed/         # cleaned R output, ready for analysis
├── scripts/
│   ├── 01_download_data.R
│   ├── 02_clean_data.R
│   ├── 03_analysis.R
│   └── 04_maps.R
├── output/
│   ├── figures/
│   └── tables/
├── project-docs/
│   └── data-sources.md    # exact URLs, retrieval dates, county reports used
|   └── decisions.md
├── .gitignore             # ignore large raw files if needed, .Rhistory, .Rproj.user
└── your-project.Rproj
```


## Setup
This project uses `renv` for reproducible package management.

```r
install.packages("renv") # if not already installed
renv::restore()          # installs exact package versions from renv.lock
```


## Data Sources
Full log in `project-docs/data-sources.md`. Currently acquired:
- **ICPRB WMA Water Supply Study** (2015 & 2020 editions) — monthly 
  utility-level production data for Fairfax Water and Loudoun Water, 
  2005–2018, extracted from PDF appendices and validated across the two 
  studies' overlapping years
- **USGS County Water-Use Data (2015)** — population-served and per-capita 
  delivery fields only; withdrawal totals found unreliable for these two 
  counties due to multi-jurisdictional utility attribution (see 
  `project-docs/decisions.md`)

Still needed: USGS county data for 2000/2005/2010/2020; Census/ACS 
population data for confounder analysis; drought index data.

## Status
- Environment setup complete (renv initialized)
- Fairfax Water and Loudoun Water monthly production data (2005–2018) 
  extracted, cross-validated, and combined into 
  `data/processed/icprb_monthly_production_2005_2018.csv`
- Next: pull confounder data (population, drought), then move to analysis

