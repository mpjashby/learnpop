# This script models the number of different types of violent crime in London
# over time to see if Op SCEPTRE is associated with a change in the number of
# offences

# Load packages
library(broom)
library(fable)
library(feasts)
library(lubridate)
library(tsibble)
library(tidyverse)

# Load data
london_crime <- read_csv("https://github.com/mpjashby/learnpop/raw/main/inst/extdata/london_weapons_possession.csv.gz")

# Count weapons and violence per month
crime_counts <- london_crime %>%
  mutate(date = ymd(str_glue("{date}-01"))) %>%
  count(crime_type, date)

# Prepare data for analysis
crime_counts <- crime_counts %>%
  # Convert dates to months
  mutate(date = yearmonth(date)) %>%
  # Remove any rows with missing values
  drop_na() %>%
  # Convert the result to be a time-series object
  as_tsibble(index = date, key = crime_type) %>%
  # Fill in any gaps caused by days with no robberies
  fill_gaps(n = 0) %>%
  # Identify which months are associated with Op Sceptre
  mutate(
    sceptre = ifelse(date %in% ymd("2021-04-01", "2021-11-01"), TRUE, FALSE)
  )

# Produce models of how many robberies we expect on each day
crime_model <- model(crime_counts, model = ARIMA(n ~ sceptre))

# Check the residuals look like white noise
crime_model %>%
  filter(crime_type == "Robbery") %>%
  gg_tsresiduals()

# Extract the model results
crime_model %>%
  tidy() %>%
  mutate(p.value = scales::pvalue(p.value))
