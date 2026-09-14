## USGS County-Level Water-Use Data (2015)
- Source: USGS National Water Use Science Project, "Estimated Use of Water 
  in the United States County-Level Data for 2015" (ver. 2.0, June 2018)
- Citation: Dieter, C.A., Linsey, K.S., Caldwell, R.R., Harris, M.A., 
  Ivahnenko, T.I., Lovelace, J.K., Maupin, M.A., and Barber, N.L., 2018, 
  U.S. Geological Survey data release, https://doi.org/10.5066/F7TB15V5
- URL: https://www.sciencebase.gov/catalog/item/get/5af3311be4b0da30c1b245d8
- File used: usco2015v2.0.csv ("All Data CSV")
- Date retrieved: 2026-09-12
- Retrieval method: Manual download (readNWISuse() non-functional; 
  read_wateruse() replacement only on dataRetrieval dev branch -- see 
  decisions.md, 2026-09-12 entry on manual download)
- Coverage: County level, all U.S. counties, year 2015; filtered to Loudoun 
  County (FIPS 51107) and Fairfax County (FIPS 51059)
- Units: Mgal/d (million gallons per day) for withdrawal fields; thousands 
  for population fields; confirmed via attached FGDC metadata XML
- Known caveat: Public-supply withdrawal fields (PS-Wtotl etc.) are 
  unreliable for Fairfax/Loudoun due to multi-jurisdictional utility 
  attribution issues -- see decisions.md. Population-served and delivery 
  fields (PS-TOPop, DO-PSDel, DO-PSPCp) appear reliable.
- Still needed: equivalent files for 2000, 2005, 2010, 2020 for the 
  before/after comparison
  
  
## ICPRB Washington Metropolitan Area Water Supply Study (2015 edition)
- Source: Interstate Commission on the Potomac River Basin (ICPRB)
- URL: https://www.potomacriver.org/wp-content/uploads/2015/08/ICP15-04b_Ahmed.pdf
- Date retrieved: 2026-09-12
- Coverage: Monthly average production (MGD), 2005–2013, Fairfax Water 
  (retail + wholesale, includes water sold to Loudoun Water) and Loudoun 
  Water (Purchased, i.e. water bought from Fairfax Water)
- Extraction method: PDF text parsed with `pdftools`/`stringr` in 
  `01_download_data.R`; parsing isolates rows between "Monthly ave. 
  production" and "Peak 1-day production" headers to avoid duplicating 
  peak-production data as average-production data (see decisions.md)
- Notes: This table reports actual utility-level production, avoiding the 
  county-attribution issue found in USGS county water-use data (see 
  decisions.md, 2026-09-12 entry). "Loudoun Water (Purchased)" reflects 
  water bought from Fairfax Water only, not Loudoun's own Goose Creek 
  production — a separate, currently unlocated table would be needed for 
  Loudoun's total production including self-supplied water.
- Still needed: Peak 1-day production data (if useful later), and the 
  2020 study appendix for more recent years (2014–2019/2020)
  

## Census ACS 5-Year Population Estimates (Loudoun & Fairfax County, VA)
- Source: U.S. Census Bureau American Community Survey (ACS), via 
  `tidycensus::get_acs()`
- Variable: B01003_001 (Total Population)
- Date retrieved: 2026-09-12
- Coverage: County level, ACS 5-year estimates for end-years 2009-2018 
  (each representing a rolling 5-year window, e.g. "2009" = 2005-2009 data)
- Counties: Loudoun (FIPS 51107), Fairfax County (FIPS 51059) — note 
  Fairfax County must be specified by FIPS code, not name, since "Fairfax" 
  alone is ambiguous with the independent City of Fairfax
- Notes: 2009 estimate has MOE = 0 (unusual, possibly a data quirk in 
  that vintage); cross-validated against USGS 2015 county water-use 
  population figures (TP-TotPop) — both sources agree closely for 2015 
  (Fairfax: 1,142,004 ACS vs. 1,142,234 USGS; Loudoun: 351,129 ACS vs. 
  375,629 USGS: some divergence for Loudoun worth noting)  
  

## CDC/USDM County-Level Drought Data (2000-2016)
- Source: U.S. Drought Monitor via CDC National Environmental Public Health 
  Tracking Network
- URL: https://data.cdc.gov/api/views/spsk-9jj6/rows.csv?accessType=DOWNLOAD
- Date retrieved: 2026-09-12
- Coverage: Weekly, county level, Loudoun (FIPS 51107) and Fairfax County 
  (FIPS 51059), 2000-2016
- Value encoding: 0-4 = D0 (Abnormally Dry) through D4 (Exceptional 
  Drought); 9 = No drought conditions — confirmed via distribution (9 = 
  1,240 of 1,774 weeks, ~70%; D0-D4 account for the rest, consistent with 
  a non-drought-prone region with occasional real events) [URL](https://droughtmonitor.unl.edu/About/AbouttheData/DroughtClassification.aspx)
- Known gap: dataset ends 2016; ICPRB production data extends to 2018 — 
  2017-2018 drought data not yet sourced


## Dominion Energy Data Center Demand (MW), 2013-2022
- Source: Dominion Energy, presented to PJM Load Analysis Subcommittee (LAS)
- Title: "Dominion Energy Service Territory Data Center Forecasting"
- Date of presentation: June 26, 2023
- URL: https://pjm.com/-/media/committees-groups/subcommittees/las/2023/20230626/20230626-item-05---dominion-load-adjustment-method_results.ashx
- Date retrieved: 2026-09-12
- Coverage: Annual historical demand (MW), Dominion Energy service 
  territory only, 2013-2022 ("A" = actual, per source labeling)
- Values (MW): 2013=462, 2014=532, 2015=636, 2016=753, 2017=931, 
  2018=1113, 2019=1421, 2020=1808, 2021=2302, 2022=2767
- Scope caveat: This is Dominion Energy's entire service territory, 
  not Loudoun County specifically or Fairfax Water's/Loudoun Water's 
  exact service boundaries. Per the same source, "Loudoun County is 
  over 80% of Dominion Energy's data center demand", so this is a 
  strong proxy for Loudoun's data center growth, but not an exact 
  county-level or utility-boundary match. Treat as regional indicator, 
  not precise attribution.
- Note: A second chart in the same source shows "New Connect Ultimate 
  Capacity" (a different, larger-magnitude metric: 67, 341, 489, 744, 
  1123, 1588... for the same years) and this is a different measure 
  (new connections' eventual max capacity, not actual metered demand) 
  and should not be confused with or substituted for the demand series 
  above.












