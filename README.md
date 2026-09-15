# Loudoun/Fairfax County Data Center Water Consumption


## Overview
This project examines how public water consumption in Loudoun and Fairfax County,
Virginia, home to the densest concentration of data centers in the U.S
("Data Center Alley") -- has changed before and after major data center build.
It also investigates whether other factors such as population growth, drought,
industrial/agricultural shifts explain the observed changes, rather than
attributing them to data centers by default.

Inspired by CNN reporting on data centers' contribution to atmospheric heat
release, this project applies similar before/after empirical approach to water
consumption. [Article](https://www.cnn.com/2026/03/30/climate/data-centers-are-having-an-underrported)


## Research Questions
1. How has water withdrawal/consumption in Loudoun/Fairfax County changed over
time relative to data center growth?
2. Can changes be attributed specifically to data centers, or are other factors
significant confounders?


## Repo Structure (Subject to change as the project develops)
```
loudoun-fairfax-water-dc/
├── README.md              # project overview, question, data sources, how to reproduce
├── data/
│   ├── raw/                # untouched downloads (USGS, ICPRB PDFs, Census, drought) — never edit these
│   └── processed/          # cleaned, validated R output, ready for analysis
├── scripts/
│   ├── download_data.R
│   ├── download_confounders.R
│   ├── clean_data.R
│   ├── analysis.R
│   └── visualize.R
├── output/
│   ├── figures/
│   └── tables/
├── project-docs/
│   ├── data-sources.md    # exact URLs, retrieval dates, sources used
│   ├── decisions.md       # methodological decisions and reasoning
│   └── findings.md        # dated log of what each analysis/chart shows
├── .gitignore
├── renv.lock
└── loudoun-fairfax-water-dc.Rproj
```


## Setup
This project uses `renv` for reproducible package management.

```r
install.packages("renv") # if not already installed
renv::restore()          # installs exact package versions from renv.lock
```


## Data Sources
Full log in `project-docs/data-sources.md`. Currently acquired:
- **ICPRB WMA Water Supply Study** (2015 & 2020 editions) - monthly 
  utility-level production data for Fairfax Water and Loudoun Water, 
  2005–2018, extracted from PDF appendices and validated across the two 
  studies' overlapping years
- **USGS County Water-Use Data (2015)** - population-served and per-capita 
  delivery fields only; withdrawal totals found unreliable for these two 
  counties due to multi-jurisdictional utility attribution (see 
  `project-docs/decisions.md`)

Still needed: USGS county data for 2000/2005/2010/2020; Census/ACS 
population data for confounder analysis; drought index data.
- **Census ACS 5-Year Population Estimates** - county-level population,
  2009–2022
- **CDC/U.S. Drought Monitor** - weekly county-level drought severity,
  2000–2016 (known gap: 2017–2023 not yet sourced)
- **Dominion Energy Data Center Demand (MW)** - annual data center electricity
  demand for Dominion's service territory (>80% of which is Loudoun County),
  2013–2022, sourced from PJM committee filings, used as a proxy for data
  center growth
- **2025 ICPRB Study, Data Center Water Use Modeling** - ICPRB's own forecast
  of upstream consumptive water use by data centers in the Potomac basin,
  2025–2050 (forward-looking; used as contextual comparison, not merged into
  the historical regression)

Still needed: 2017–2023 drought data; USGS county data for additional years,
if a reliable withdrawal attribution is found.

## Status
- Environment setup complete (renv initialized)
- Fairfax Water and Loudoun Water monthly production data (2005–2023)
  extracted, cross-validated across three ICPRB study editions, and combined
- Population (2009–2022), drought (2000–2016), and Dominion data center
  demand (2013–2022) data acquired and joined into a combined annual dataset
  (`data/processed/combined_annual_loudoun_fairfax_extended.csv`)
- Preliminary regression analysis complete: Loudoun Water's production shows
  a strong, statistically significant relationship with both population
  growth and data center demand (R²≈0.81 for each, n=10, 2013–2022) - the two
  predictors are too collinear to separate as distinct drivers over this
  window. Fairfax Water's production shows no relationship with either
  variable. Full findings in `project-docs/findings.md`.
- Next: source 2017–2023 drought data to close the confounder gap; begin
  drafting Data and Methods and Results sections

