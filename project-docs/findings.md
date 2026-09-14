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



















