# =============================================================================
# Macroeconomic Drivers of Trade Openness in Singapore
# =============================================================================
# Research question: What structural macroeconomic factors explain Singapore's
# persistently high trade openness (exports + imports as % of GDP)?
#
# Approach: Two model specifications —
#   1. Baseline OLS    (contemporaneous regressors)
#   2. Lagged OLS      (prior-year conditions) — tests whether openness adapts
#                       to lagged macro conditions rather than current shocks,
#                       consistent with trade openness as a structural feature
#                       rather than a purely cyclical response
#
# Data: World Bank World Development Indicators (WDI), Singapore, 1980–2024
# =============================================================================


# --- 0. Package loading -------------------------------------------------------

library(WDI)
library(dplyr)
library(modelsummary)  # Regression output tables
library(ggplot2)       # Visualisation


# --- 1. Data acquisition ------------------------------------------------------

# Pull macroeconomic indicators for Singapore from World Bank WDI API
macro_raw <- WDI(
  country = "SG",
  indicator = c(
    trade_gdp    = "NE.TRD.GNFS.ZS",        # Trade openness: exports + imports (% of GDP) — DEPENDENT VARIABLE
    gdp_growth   = "NY.GDP.MKTP.KD.ZG",     # Real GDP growth (%)
    unemployment = "SL.UEM.TOTL.ZS",         # Unemployment rate (% of labour force)
    fdi_gdp      = "BX.KLT.DINV.WD.GD.ZS",  # FDI net inflows (% of GDP)
    gov_debt_gdp = "GC.DOD.TOTL.GD.ZS",     # Government debt (% of GDP)
    pop_growth   = "SP.POP.GROW",            # Population growth rate (%)
    cab_gdp      = "BN.CAB.XOKA.GD.ZS"      # Current account balance (% of GDP)
  ),
  start = 1980,
  end   = 2024
)


# --- 2. Data cleaning ---------------------------------------------------------

macro_data <- macro_raw %>%
  arrange(year) %>%
  select(-iso2c, -country)  # Drop redundant identifier columns

# Retain only complete cases for all analysis variables
macro_final <- macro_data %>%
  filter(
    !is.na(trade_gdp),
    !is.na(gdp_growth),
    !is.na(unemployment),
    !is.na(fdi_gdp),
    !is.na(gov_debt_gdp),
    !is.na(pop_growth),
    !is.na(cab_gdp)
  )


# --- 3. Visualisation — Singapore trade openness, 1980–2024 ------------------

ggplot(macro_final, aes(x = year, y = trade_gdp)) +
  geom_line(colour = "#d7191c", linewidth = 0.9) +
  labs(
    title    = "Singapore Trade Openness, 1980–2024",
    subtitle = "Exports + Imports as % of GDP",
    x        = "Year",
    y        = "Trade openness (% of GDP)",
    caption  = "Source: World Bank World Development Indicators"
  ) +
  theme_minimal()


# --- 4. Model 1 — Baseline OLS ------------------------------------------------

# Tests whether contemporaneous macro conditions explain trade openness.
# Key questions:
#   - Does domestic slack (unemployment) drive trade exposure counter-cyclically?
#   - Does the external balance (cab_gdp) reinforce or substitute for openness?

baseline_trade_model <- lm(
  trade_gdp ~ gdp_growth + unemployment + fdi_gdp +
              gov_debt_gdp + pop_growth + cab_gdp,
  data = macro_final
)

summary(baseline_trade_model)


# --- 5. Model 2 — Lagged specification ----------------------------------------

# Motivation: Singapore's trade openness may reflect structural adjustment to
# prior macroeconomic conditions rather than immediate shocks.
# If the lagged model explains more variation than the contemporaneous one,
# it supports the view that openness is an adaptive, structural feature of
# Singapore's economy — not a purely cyclical response.

macro_lag <- macro_final %>%
  arrange(year) %>%
  mutate(
    gdp_growth_lag   = lag(gdp_growth),
    unemployment_lag = lag(unemployment),
    fdi_gdp_lag      = lag(fdi_gdp),
    gov_debt_gdp_lag = lag(gov_debt_gdp),
    pop_growth_lag   = lag(pop_growth),
    cab_gdp_lag      = lag(cab_gdp)
  ) %>%
  filter(
    !is.na(gdp_growth_lag),
    !is.na(unemployment_lag),
    !is.na(fdi_gdp_lag),
    !is.na(gov_debt_gdp_lag),
    !is.na(pop_growth_lag),
    !is.na(cab_gdp_lag)
  )

lag_trade_model <- lm(
  trade_gdp ~ gdp_growth_lag + unemployment_lag + fdi_gdp_lag +
              gov_debt_gdp_lag + pop_growth_lag + cab_gdp_lag,
  data = macro_lag
)

summary(lag_trade_model)


# --- 6. Results table — both specifications side by side ----------------------

modelsummary(
  list(
    "Baseline OLS"         = baseline_trade_model,
    "Lagged Specification" = lag_trade_model
  ),
  stars   = TRUE,
  gof_map = c("nobs", "r.squared", "adj.r.squared"),
  title   = "Macroeconomic Drivers of Trade Openness in Singapore: Regression Results (1980–2024)"
)
