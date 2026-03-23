# =============================================================================
# Inflation Dynamics in Singapore: Domestic Slack vs. External Exposure
# =============================================================================
# Research question: What drives inflation in Singapore — domestic labour market
# conditions (unemployment) or external trade exposure (trade openness)?
#
# Approach: Three progressive model specifications —
#   1. Baseline OLS  (contemporaneous regressors)
#   2. Lagged OLS    (prior-year conditions as predictors)
#   3. Error-correction model (ECM) to capture long-run adjustment dynamics
#
# Data: World Bank World Development Indicators (WDI), Singapore, 1980–2024
# =============================================================================


# --- 0. Package loading -------------------------------------------------------

library(WDI)
library(dplyr)
library(tidyr)
library(car)           # VIF multicollinearity diagnostics
library(modelsummary)  # Regression output tables
library(ggplot2)       # Visualisation


# --- 1. Data acquisition ------------------------------------------------------

# Pull macroeconomic indicators for Singapore from World Bank WDI API
macro_raw <- WDI(
  country = "SG",
  indicator = c(
    gdp_growth   = "NY.GDP.MKTP.KD.ZG",    # Real GDP growth (%)
    unemployment = "SL.UEM.TOTL.ZS",        # Unemployment rate (% of labour force)
    cpi_level    = "FP.CPI.TOTL",           # CPI index (2010 = 100) — used to construct inflation
    fdi_gdp      = "BX.KLT.DINV.WD.GD.ZS", # FDI net inflows (% of GDP)
    gov_debt_gdp = "GC.DOD.TOTL.GD.ZS",    # Government debt (% of GDP)
    trade_gdp    = "NE.TRD.GNFS.ZS",        # Trade openness: exports + imports (% of GDP)
    cab_gdp      = "BN.CAB.XOKA.GD.ZS",    # Current account balance (% of GDP)
    pop_growth   = "SP.POP.GROW"            # Population growth rate (%)
  ),
  start = 1980,
  end   = 2024
)

macro_raw <- macro_raw %>% arrange(year)


# --- 2. Variable construction -------------------------------------------------

# WDI provides CPI as an index (not a rate), so inflation is computed as the
# year-on-year percentage change in the CPI level
macro_data <- macro_raw %>%
  mutate(
    inflation = (cpi_level - lag(cpi_level)) / lag(cpi_level) * 100
  )

# Select analysis variables; drop rows where inflation cannot be computed (first obs)
macro_final <- macro_data %>%
  select(year, inflation, gdp_growth, unemployment, trade_gdp,
         fdi_gdp, gov_debt_gdp, cab_gdp, pop_growth) %>%
  filter(!is.na(inflation))


# --- 3. Visualisation — Singapore inflation, 1980–2024 -----------------------

ggplot(macro_final, aes(x = year, y = inflation)) +
  geom_line(colour = "#2c7bb6", linewidth = 0.9) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50") +
  labs(
    title    = "Singapore CPI Inflation, 1980–2024",
    subtitle = "Derived from World Bank WDI CPI index (2010 = 100)",
    x        = "Year",
    y        = "Inflation rate (%)",
    caption  = "Source: World Bank World Development Indicators"
  ) +
  theme_minimal()


# --- 4. Model 1 — Baseline OLS ------------------------------------------------

# Tests whether contemporaneous macro conditions explain inflation.
# Key variables of interest:
#   - unemployment: proxy for domestic slack (Phillips curve channel)
#   - trade_gdp:    proxy for external exposure (imported inflation channel)

baseline_model <- lm(
  inflation ~ unemployment + gdp_growth + trade_gdp +
              fdi_gdp + gov_debt_gdp + pop_growth,
  data = macro_final
)

summary(baseline_model)

# Multicollinearity check — VIF > 10 suggests a problematic collinearity
vif(baseline_model)


# --- 5. Model 2 — Lagged specification ----------------------------------------

# Motivation: inflation likely responds to prior-year conditions rather than
# contemporaneous shocks in a small open economy with policy lags.
# Lagged regressors also reduce reverse causality concerns
# (e.g., high inflation affecting reported unemployment in the same period).

macro_final <- macro_final %>%
  arrange(year) %>%
  mutate(inflation_lag = lag(inflation))

lag_model <- lm(
  inflation ~ inflation_lag + unemployment + gdp_growth + trade_gdp +
              fdi_gdp + gov_debt_gdp + pop_growth,
  data = macro_final
)

summary(lag_model)


# --- 6. Model 3 — Error-correction model (ECM) --------------------------------

# Motivation: if inflation and its determinants share a long-run equilibrium,
# an ECM separates short-run dynamics from the speed of adjustment back to trend.
#
# Structure:
#   - Dependent variable: Δinflation (first difference — short-run change)
#   - inflation_lag: error-correction term; expected negative coefficient,
#     indicating that above-equilibrium inflation in t-1 pulls inflation down in t
#   - Lagged regressors: short-run effects of macro drivers

macro_ecm <- macro_final %>%
  arrange(year) %>%
  mutate(
    d_inflation   = inflation - lag(inflation),  # Short-run change in inflation
    inflation_lag = lag(inflation),               # Long-run error-correction term
    unemp_lag     = lag(unemployment),
    gdp_lag       = lag(gdp_growth),
    trade_lag     = lag(trade_gdp),
    fdi_lag       = lag(fdi_gdp),
    debt_lag      = lag(gov_debt_gdp),
    pop_lag       = lag(pop_growth)
  ) %>%
  filter(!is.na(d_inflation))

ecm_model <- lm(
  d_inflation ~ inflation_lag + unemp_lag + gdp_lag + trade_lag +
                fdi_lag + debt_lag + pop_lag,
  data = macro_ecm
)

summary(ecm_model)

# A negative and significant coefficient on inflation_lag confirms error-correction:
# deviations from the long-run equilibrium are partially reversed each period.


# --- 7. Results table — all three specifications side by side -----------------

modelsummary(
  list(
    "Baseline OLS"         = baseline_model,
    "Lagged Specification" = lag_model,
    "Error-Correction"     = ecm_model
  ),
  stars   = TRUE,
  gof_map = c("nobs", "r.squared", "adj.r.squared"),
  title   = "Inflation Dynamics in Singapore: Regression Results (1980–2024)"
)
