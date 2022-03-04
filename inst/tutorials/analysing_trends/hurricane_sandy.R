# This script creates a model of robberies in New York City each day to identify
# whether Hurricane Sandy was associated with any change in robbery frequency

# Load packages
library(broom)
library(fable)
library(feasts)
library(lubridate)
library(tsibble)
library(tidyverse)

# Load data
offences_against_persons <- read_csv("")

# Get dates of public holidays in NYC
holidays <- as_date(timeDate::holidayNYSE(year = 2010:2014))

# Count robberies per day
robbery_counts <- offences_against_persons %>%
  # Remove all crimes except personal robbery
  filter(offense_type == "personal robbery") %>%
  # Remove the time-of-day from the date column
  mutate(date = as_date(date)) %>%
  # Count the number of robberies (i.e. rows of data) on each date
  count(date)

# Find the average number of robberies per day
summary(robbery_counts)

# Prepare data for analysis
robbery_counts <- robbery_counts %>%
  mutate(
    # Add a column specifying if each date is a public holiday or not
    holiday = ifelse(date %in% holidays, TRUE, FALSE),
    # Add a column specifying if each date was during Hurricane Sandy or not
    sandy = ifelse(
      date %in% ymd("2012-10-29", "2012-10-30", "2012-10-31", "2012-11-01", "2012-11-02"),
      TRUE,
      FALSE
    )
  ) %>%
  # Remove any rows with missing values
  drop_na() %>%
  # Convert the result to be a time-series object
  as_tsibble(index = date) %>%
  # Fill in any gaps caused by days with no robberies
  fill_gaps(n = 0)

# Produce a model of how many robberies we expect on each day
robbery_model <- model(robbery_counts, model = ARIMA(n ~ holiday + sandy))

# Check the residuals look like white noise
gg_tsresiduals(robbery_model)

# Extract the model results
robbery_model %>%
  tidy() %>%
  mutate(p.value = scales::pvalue(p.value))
