# Script:
# Combines and cleans:
# - ICPRB 2015 study monthly production (2005-2013)
# - ICPRB 2020 study monthly production (2010-2018)
# - USGS county water-use data (2015), population/delivery fields only
# See decisions.md - withdrawal fields unreliable for Fairfax/Loudoun

# import libraries
library(dplyr)
library(readr)


# Load both raw datasets
icprb_2015 <- read.csv("data/raw/icprb/icprb_2015study_monthly_production_2005_2013.csv")
icprb_2020 <- read.csv("data/raw/icprb/icprb_2020study_monthly_production_2010_2018.csv")


# Check the overlap years (2010-2013) for consistency -- Fairfax Water
overlap_2015 <- icprb_2015 %>%
  filter(year %in% 2010:2013, utility == "Fairfax Water") %>%
  arrange(year, month)

overlap_2020 <- icprb_2020 %>%
  filter(year %in% 2010:2013, utility == "Fairfax Water") %>%
  arrange(year, month)

comparison <- overlap_2015 %>%
  rename(production_2015study = production_mgd) %>%
  inner_join(
    overlap_2020 %>% rename(production_2020study = production_mgd),
    by = c("month", "year")
  ) %>%
  mutate(diff = production_2020study - production_2015study)

# print(comparison)


# Check the overlap years (2010-2013) for consistency -- Loudoun Water
overlap_2015_loudoun <- icprb_2015 %>%
  filter(year %in% 2010:2013, utility == "Loudoun Water (Purchased)") %>%
  arrange(year, month)

overlap_2020_loudoun <- icprb_2020 %>%
  filter(year %in% 2010:2013, utility == "Loudoun Water (Total Use)") %>%
  arrange(year, month)

comparison_loudoun <- overlap_2015_loudoun %>%
  rename(purchased_2015study = production_mgd) %>%
  select(-utility) %>%
  inner_join(
    overlap_2020_loudoun %>% rename(total_use_2020study = production_mgd) %>% select(-utility),
    by = c("month", "year")
  ) %>%
  mutate(diff = total_use_2020study - purchased_2015study)

comparison_loudoun


# Combining into one clean dataset
icprb_combined <- bind_rows(
  icprb_2015 %>% filter(!(year %in% 2010:2013)), # keeping only 2005-2009 from 2015 study
  icprb_2020 # 2010-2018 from 2020 study
)


# Standardize utility labels across the full timeline
icprb_combined <- icprb_combined %>%
  mutate(utility = case_when(
    utility %in% c("Loudoun Water (Purchased)", "Loudoun Water (Total Use)") ~ "Loudoun Water",
    TRUE ~ utility
  ))

#table(icprb_combined$utility, icprb_combined$year)


# Write to CSV
write.csv(
  icprb_combined,
  "data/processed/icprb_monthly_production_2005_2018.csv",
  row.names = FALSE
)












