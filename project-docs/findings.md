## 2026-09-12 - Production trends 2005-2018: Fairfax vs. Loudoun
**Fairfax Water:** Highly volatile year-to-year, ranging ~141-172 MGD.
Two of its three highest peaks (2007, 2016) coincide with flagged drought years
(>20% weeks in D1+). Sharpest single-year drop (2008->2009) follows a 
drought year rather than a calm one. It is worth investigating whether this
reflects a lagged effect, a data artifact, or a genuine demand pullback.

**Loudoun Water:** Much steadier upward trend overall (~17->23 MGD), punctuated
by occasional dips. Its clearest peak (2016) aligns with the same drought year
as Fairfax's 2016 peak, this is the point where both utilities spike together.

**Preliminary read:** Loudoun's trend looks more consistent with steady structural
growth (population, development, possibly data center buildout), while Fairfax
shows sharper weather-sensitivity, drought years appear to coincide with ususally
high production more often than calm years do. This is descriptive only (14 annual points,
visual correlation, no statistical test yet), not a casual claim.

**Open question for next step:** Is Fairfax's volatility actually tracking drought,
or is this coincidence given only 14 data points? Worth a formal correlation/regression check
(production ~ drought + population + year) rather than relying on visual
alignment alone.


## 2026-09-13 -  Regression: production ~ population + drought (n=8 per utility)
**Loudoun Water:** R^2=0.88, F-test p=0.0047 (significant).
Population (p=0.0017) and drought % weeks (p=0.030) both individually significant.
Both structural growth (population) and weather varaibility (drought) show real,
independent associations with population.

**Fairfax Water:** R^2=0.45, F-test p=0.224 (Not significant).
Neither population (p=0.206) nor drought (p=0.168) individually significant. No
statistically defensible relationship detected. Fairfax's volatility remains unexplained
by these two variables.

**Caveats:** n=8 per model (2 years lost to missing drought data 2017-2018).
Extremely low power so treating it as exploratory, not confirmatory. Year and 
population are highly collinear (r=0.96-0.9998), so year was excluded; this may
absorb some of what would otherwise show as a population effect or vice-versa. No
data center variable included yet. These results say nothing about DC attribution directly,
only about population and drought as confounders.

**Implication:** Fairfax's unexplained volatility is itself worth investigating
further possible candidates: multi-jurisdictional wholesale complexity, commercial/
industrial demand (which could include data centers), or data quality in the production
reporting itself.


## 2026-09-13 - Data Center Demand (Dominion) Regression, 2013-2018 (n=6)
**Correlations:** population and dc_demand_nw are highly collinear (Fairfax r=0.91, Loudoun r=0.98)
it is expected since both grew steadily over this window. Therefore cannot include both in one model.

**Bivariate regressions (n=6, 4 df):**
- Fairfax ~ dc_demand_mw: R^2=0.27, p=0.29 (not significant)
- Fairfax ~ population: R^2=0.52, p=0.10 (not significant, but closer)
- Loudoun ~ dc_demand_mw: R^2=0.31, p=0.25 (not significant)
- Loudoun ~ population: R^2=0.42, p=0.16 (not significant)

**Interpretation:** At n=6, no predictor reaches conventional significance. Population
shows somewhat higher R^2 than dc_demand_mw for both utilities, but this is not a statistically
defensible distinction given the sample size and the two variables' near perfect collinearity.
Cannot conclude data center demand explains production better (or worse) than population growth with
this data.

**Implications:** This is a genuine limitation to report honestly, not a null result to hide.
Two paths forward:
1. Acquire longer/more granular data
2. Reframe the claims around this limitation explicitly


## 2026-09-14 - Extended regression with n=10 (2013-2022), corrected

**Fairfax Water ~ dc_demand_mw:** R^2=0.004, p=0.86 (no relationship)
**Loudoun Water ~ dc_demand_mw:** R^2=0.806, p=0.0004 (strong, significant)
**Loudoun Water ~ population:** R^2=0.806, p=0.0004 (strong, significant — 
  essentially identical to dc_demand_mw model)

**Interpretation:** Loudoun Water's production tracks both population and 
Dominion's regional data center demand almost identically well (R^2 differs 
by only 0.0002). Given r=0.93 collinearity between the two predictors over 
this window, the regression cannot statistically distinguish which is the 
"true" driver and they are near-perfect proxies for each other over 
2013-2022. This is an honest limitation, not a null result: it means the 
available data cannot separate "Loudoun grew because of data centers" from 
"Loudoun grew because more people moved there" as competing explanations, 
because both happened simultaneously and at similar rates.

**Fairfax remains the interesting counterpoint:** its production is 
essentially flat/unexplained by either variable, consistent with Dominion's 
own statement that Loudoun accounts for >80% of their data center demand and 
data centers are geographically concentrated away from where Fairfax draws 
its growth story from.

**Implication:** The strongest defensible claim is: "Loudoun 
Water's rising production is strongly associated with both population 
growth and data center demand growth, which are too collinear in this 
period to separate statistically — this itself is a notable finding, since 
it suggests data center growth and general regional growth in Loudoun have 
moved in lockstep, rather than data centers being an isolated driver on 
top of an otherwise stable population trend." Fairfax's lack of any 
relationship to either variable is a genuine puzzle worth further 
investigation (e.g., wholesale complexity, wastewater return flows, or a 
variable not yet captured).


## 2026-09-16 - Drought data 2017-2023 sourced from USDM API
- **Decision:** Extend drought coverage via usdmdataservices.unl.edu 
  API (percent-area format), harmonized to a comparable pct_weeks_in_drought 
  and area-weighted severity metric
- **Reason:** CDC dataset ends 2016; official USDM service has no such cutoff
- **Caveat:** Methodology differs from CDC source (percent-area vs. single categorical code)
  and metrics are conceptually aligned, not identically derived. Treat 2000-2016 
  and 2017-2023 drought values as comparable but not perfectly consistent.


## 2026-09-18 - Full regression, extended drought data (n=14)

- Fairfax: R²=0.36, F p=0.085 (not significant). Population p=0.15, 
  drought p=0.066 (marginal). Weak evidence for drought over population, 
  neither confirmed.

- Loudoun: R²=0.84, F p<0.0001. Population p<0.0001 (dominant), 
  drought p=0.67 (not significant). With more data, drought's earlier 
  apparent significance (n=8 test) disappears, population fully 
  explains Loudoun's trend; drought does not add anything once 
  population is controlled for.

- Revision from earlier finding: the n=8 result showing drought as 
  significant for Loudoun does not replicate at n=14. Population is 
  the clear, robust driver for Loudoun. Fairfax remains largely 
  unexplained by either variable.


## 2026-09-19 - Monthly seasonal analysis, Loudoun (n=168 monthly obs)

Tested whether population's or dc_demand's association with production 
is stronger in summer months (proxy for cooling-driven demand).

Population x summer interaction: not significant (p=0.83)
Dc_demand x summer interaction: not significant (p=0.51)

Summer itself is a strong, flat effect (+8-10 MGD, p<0.0001) but does 
not scale with population or dc_demand growth over the study period.

Interpretation: no evidence that Loudoun's seasonal water demand spike 
is tied to data center expansion specifically. The summer effect looks 
structural/constant rather than growing with data center buildout, 
which argues against a detectable data-center-driven cooling signature 
in this monthly data. Combined with the earlier annual finding 
(population and dc_demand too collinear to separate), this analysis 
does not find evidence distinguishing data centers from general growth 
as a driver of Loudoun's water production increase.








