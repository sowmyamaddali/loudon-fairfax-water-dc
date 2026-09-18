# Import libraries
library(dplyr)

# Prepare modeling data per utility, dropping NA rows for regression
fairfax_model_data <- combined_annual %>%
  filter(county == "Fairfax Water",
         !is.na(avg_production_mgd),
         !is.na(population))

loudoun_model_data <- combined_annual %>%
  filter(county == "Loudoun Water",
         !is.na(avg_production_mgd),
         !is.na(population))

nrow(fairfax_model_data)
nrow(loudoun_model_data)


# Check collinearity between year and population
cor(fairfax_model_data$year, fairfax_model_data$population)
cor(loudoun_model_data$year, loudoun_model_data$population)

# Year & population have near perfect year/population collinearity
# Use population and drop year


# Correlation check
cor(fairfax_model_data$avg_production_mgd, fairfax_model_data$population)
cor(loudoun_model_data$avg_production_mgd, loudoun_model_data$population)

cor(fairfax_model_data$avg_production_mgd, 
    fairfax_model_data$pct_weeks_in_drought,
    use = "complete.obs")
cor(loudoun_model_data$avg_production_mgd, 
    loudoun_model_data$pct_weeks_in_drought,
    use = "complete.obs")


# Regression: function of population + drought
fairfax_model <- lm(
  avg_production_mgd ~ population + pct_weeks_in_drought,
  data = fairfax_model_data
)

loudoun_model <- lm(
  avg_production_mgd ~ population + pct_weeks_in_drought,
  data = loudoun_model_data
)

summary(fairfax_model)
summary(loudoun_model)

nobs(fairfax_model)
nobs(loudoun_model)

# --------------------------------------------------------------------------------
# Check collinearity among all three predictors first
fairfax_check <- combined_annual %>%
  filter(county == "Fairfax Water", year %in% 2013:2018)

loudoun_check <- combined_annual %>%
  filter(county == "Loudoun Water", year %in% 2013:2018)

cor(fairfax_check$population, fairfax_check$dc_demand_mw)
cor(loudoun_check$population, loudoun_check$dc_demand_mw)

cor(fairfax_check$avg_production_mgd, fairfax_check$dc_demand_mw)
cor(loudoun_check$avg_production_mgd, loudoun_check$dc_demand_mw)

# population and dc_demand_mw are almost perfectly collinear (0.91 and 0.98)
# this confirms that they can't both go into one mode
# the data center variable is essentially riding along with population growth over
# this short window, so a combined model wouldn't be able to tell them apart.

# --------------------------------------------------------------------------------
# Bivariate models, one predictor at a time, n=6 for each
fairfax_dc_model <- lm(
  avg_production_mgd ~ dc_demand_mw,
  data = fairfax_check
)

loudoun_dc_model <- lm(
  avg_production_mgd ~ dc_demand_mw,
  data = loudoun_check
)

summary(fairfax_dc_model)
summary(loudoun_dc_model)


fairfax_pop_model <- lm(
  avg_production_mgd ~ population,
  data = fairfax_check
)

loudoun_pop_model <- lm(
  avg_production_mgd ~ population,
  data = loudoun_check
)

summary(fairfax_pop_model)
summary(loudoun_pop_model)

# --------------------------------------------------------------------------------
# Full population + drought regression
fairfax_full <- combined_annual_full %>%
  filter(county == "Fairfax Water", !is.na(avg_production_mgd),
         !is.na(population), !is.na(pct_weeks_in_drought))

loudoun_full <- combined_annual_full %>%
  filter(county == "Loudoun Water", !is.na(avg_production_mgd),
         !is.na(population), !is.na(pct_weeks_in_drought))

nrow(fairfax_full)
nrow(loudoun_full)

fairfax_model_full <- lm(avg_production_mgd ~ population + pct_weeks_in_drought, data = fairfax_full)
loudoun_model_full <- lm(avg_production_mgd ~ population + pct_weeks_in_drought, data = loudoun_full)

summary(fairfax_model_full)
summary(loudoun_model_full)








