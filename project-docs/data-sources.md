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
  
  