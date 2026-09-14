# Import libraries
library(ggplot2)
library(dplyr)

# Production over time, faceted by county, drought years flagged
ggplot(combined_annual %>% filter(!is.na(avg_production_mgd)),
  aes(x = year, y = avg_production_mgd)) +
  geom_line(color = "steelblue", linewidth = 1) +
  geom_point(color = "steelblue") +
  geom_vline(
    data = combined_annual %>% filter(pct_weeks_in_drought > 20),
    aes(xintercept = year),
    linetype = "dashed", color = "firebrick", alpha = 0.5
  ) +
  facet_wrap(~ county, scales = "free_y") +
  labs(
    title = "Annual Average Water Production, Fairfax & Loudoun Water (2005-2018)",
    subtitle = "Dashed red lines mark years with >20% of weeks in D1+ drought",
    x = "Year", y = "Avg. Production (MGD)"
  ) +
  theme_minimal()


ggsave("output/figures/production_trend_drought.png",
       width = 10,
       height = 5,
       dpi = 300)

# --------------------------------------------------------------------------------
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








