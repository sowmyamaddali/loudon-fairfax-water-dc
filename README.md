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
consumption.[Article](https://www.cnn.com/2026/03/30/climate/data-centers-are-having-an-underrported)


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


## Data Sources (Subject to change as the project develops)
See `project-docs/data-sources.md` for full log.
Planned sources include:
- USGS Water Use Data (County-level, 5-year estimates)
- Loudon County Service Authority annual water reports
- Fairfax Water annual reports
- U.S. Census/ACS population data
- U.S. Drought Monitor/SPI drought index


## Status
Environment setup complete (renv initialized, core packages installed).
Data acquisition in-progress