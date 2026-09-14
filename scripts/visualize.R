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







