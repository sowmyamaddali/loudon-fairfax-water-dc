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
  


## 2026-09-12 - ICPRB overlap validation and utility label standardization
- Decision: Concatenate 2015 study (2005-2009) with 2020 study (2010-2018) 
  into a single continuous series; relabel "Loudoun Water (Purchased)" and 
  "Loudoun Water (Total Use)" both as "Loudoun Water"
- Reason: Verified all 48 overlapping Fairfax Water months (2010-2013) 
  matched exactly between studies (no revisions). Verified all 48 
  overlapping Loudoun months matched exactly between "Purchased" (2015 
  study) and "Total Use" (2020 study) labels, confirming Loudoun had no 
  meaningful self-supply before Trap Rock WTF came online (Sept 2018) — 
  so the two definitions are equivalent for 2005-2018 and safe to treat 
  as one continuous "Loudoun Water" series
- Caveat: Post-2018 data (once acquired) will need separate handling, since 
  Loudoun's own Trap Rock production breaks the purchased=total equivalence
  

## 2026-09-12 - Combined annual dataset construction
- Decision: Aggregate monthly production to annual mean; use % of weeks in 
  D1+ drought and mean drought severity (excluding "None" weeks) as annual 
  drought summary metrics; full outer join across production, population, 
  drought by county + year (2000-2018), preserving NA where a source 
  doesn't cover that year rather than truncating to overlap
- Reason: Sources have different coverage windows (production 2005-2018, 
  population 2009-2018, drought 2000-2016); an inner join would silently 
  drop years and understate the true observation window
- Caveat: `avg_drought_severity` is undefined (NaN) in years/counties with 
  zero non-"None" weeks, will show as NaN, not NA; needs handling before 
  any modeling step


## 2026-09-16 - Excluded incomplete 2016 boundary week from USDM pull
- **Decision:** Dropped 2016 from the new USDM API extract (only 1 week 
  returned, a boundary artifact) rather than merging it with the CDC 
  2000-2016 data
- **Reason:** CDC's 2016 figure is based on a full 52-week year; USDM's 2016 
  figure was based on a single week and produced nonsensical values 
  (100% and 0%) when compared directly
  
  
  
  
  
  
  
  
  
  
  
  
  
