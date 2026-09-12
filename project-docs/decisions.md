## 2026-09-12 - USGS county water-use withdrawal fields unreliable for Fairfax/Loudoun
- Decision: Do not use USGS county-level `PS-Wtotl` (public supply total withdrawal) 
  or related withdrawal fields as ground truth for Fairfax and Loudoun County
- Reason: Internal inconsistency found in the 2015 data -- Fairfax County's 
  `DO-PSDel` (public-supply water delivered to domestic users) = 91.38 Mgal/d, 
  but `PS-Wtotl` (total public-supply withdrawal) = only 0.06 Mgal/d for the 
  same county/year. Fairfax Water is a multi-jurisdictional utility (serves 
  Fairfax, Loudoun, Prince William, plus wholesale to Herndon/Vienna/Fairfax 
  City), and its Potomac/Occoquan withdrawal appears to be mis-attributed or 
  incompletely coded at the county level in this dataset, rather than 
  reflecting actual intake. Loudoun's low PS-Wtotl (6.86 Mgal/d) likely 
  reflects the same issue, since Loudoun Water also purchases from Fairfax 
  Water in addition to its own Goose Creek intake.
- Alternative considered: Using USGS withdrawal fields directly -- rejected 
  due to this internal inconsistency
- Resolution: Use ICPRB Washington Metropolitan Area Water Supply Study 
  reports as primary source for actual utility withdrawal/production trends. 
  USGS county data retained only for population-served and per-capita 
  delivery fields (`PS-TOPop`, `DO-PSDel`, `DO-PSPCp`), which appear 
  internally consistent.
  
  
## 2026-09-12 - ICPRB PDF parsing: average vs. peak production tables
- Decision: Restrict monthly production extraction to lines between 
  "Monthly ave. production" and "Peak 1-day production" headers
- Reason: Initial regex-based extraction captured both average and peak 
  tables under one series, doubling row counts (18 rows/month/utility 
  instead of 9) and silently mislabeling peak data as average data
  
