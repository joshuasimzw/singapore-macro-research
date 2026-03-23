# Singapore Macroeconomic Research

Two applied econometric analyses of Singapore's macroeconomic dynamics, using World Bank World Development Indicators (WDI) data spanning 1980–2024. Both projects were completed as part of independent research coursework for a BSc (Hons) Economics degree at the University of East Anglia.

---

## Projects

### 1. Inflation Dynamics: Domestic Slack vs. External Exposure

**Script:** `01_inflation_dynamics.R`

**Research question:** What drives consumer price inflation in Singapore — domestic labour market conditions (unemployment) or external trade exposure (trade openness)?

Singapore is an unusually open economy with limited monetary policy independence, making it a distinctive case for testing open-economy inflation models. The analysis examines whether standard Phillips curve logic holds, and whether imported price pressures via trade openness represent a meaningful additional channel.

**Methodology:**

Three progressive model specifications are estimated using OLS:

- *Baseline OLS* — inflation regressed on contemporaneous macroeconomic conditions
- *Lagged specification* — regressors lagged one period to address reverse causality and test policy transmission lags
- *Error-correction model (ECM)* — first-differenced inflation regressed on lagged levels and differences, separating short-run dynamics from long-run adjustment

**Key findings:**

- Both unemployment (domestic slack) and trade openness (external exposure) are statistically significant drivers of inflation, consistent with an open-economy Phillips curve
- Trade openness has a positive coefficient, suggesting imported price pressures are a meaningful inflation channel — expected given Singapore's trade-to-GDP ratio exceeding 300%
- The ECM error-correction term is negative and significant, indicating relatively fast mean-reversion: a substantial share of deviations from long-run equilibrium are corrected within one year
- Inflation persistence is limited, consistent with Singapore's credible monetary policy framework operated through the SGD exchange rate band

---

### 2. Macroeconomic Drivers of Trade Openness

**Script:** `02_trade_openness.R`

**Research question:** What structural macroeconomic factors explain the level and variation of Singapore's trade openness over time?

Singapore maintains one of the highest trade-to-GDP ratios in the world. This analysis investigates whether that openness is driven by cyclical macroeconomic conditions or whether it reflects deeper structural features that respond more slowly to prior-period economic states.

**Methodology:**

Two model specifications are estimated using OLS:

- *Baseline OLS* — trade openness regressed on contemporaneous macro conditions
- *Lagged specification* — all regressors lagged one period, testing whether openness responds to prior-period conditions rather than current shocks

**Key findings:**

- Higher unemployment is associated with increased trade openness, suggesting trade functions as a counter-cyclical stabilisation mechanism — consistent with Singapore's outward-oriented growth model
- Population growth and current account balance are significant structural drivers of openness
- The lagged model explains more variation than the contemporaneous specification, supporting the interpretation that trade openness is an adaptive, structural feature of Singapore's economy rather than a purely cyclical outcome
- GDP growth and fiscal variables show limited direct influence on openness after controlling for other factors

---

## Data

All data are sourced from the [World Bank World Development Indicators (WDI)](https://databank.worldbank.org/source/world-development-indicators), accessed programmatically via the `WDI` R package. No manual downloads are required — scripts pull directly from the API on execution.

| Indicator | WDI Code | Description |
|---|---|---|
| GDP growth | NY.GDP.MKTP.KD.ZG | Real GDP growth (%) |
| Unemployment | SL.UEM.TOTL.ZS | Unemployment rate (% of labour force) |
| CPI | FP.CPI.TOTL | CPI index, 2010 = 100 (used to derive inflation) |
| FDI | BX.KLT.DINV.WD.GD.ZS | FDI net inflows (% of GDP) |
| Government debt | GC.DOD.TOTL.GD.ZS | Central government debt (% of GDP) |
| Trade openness | NE.TRD.GNFS.ZS | Exports + imports (% of GDP) |
| Current account | BN.CAB.XOKA.GD.ZS | Current account balance (% of GDP) |
| Population growth | SP.POP.GROW | Population growth rate (%) |

---

## Requirements

```r
install.packages(c("WDI", "dplyr", "tidyr", "car", "modelsummary", "ggplot2"))
```

Developed and tested in R 4.3+.

---

## File Structure

```
singapore-macro-research/
├── README.md
├── 01_inflation_dynamics.R
└── 02_trade_openness.R
```

---

## Author

**Joshua Sim Zhe Wei**
BSc (Hons) Economics, University of East Anglia (predicted First Class Honours)
[joshua.simzw@gmail.com](mailto:joshua.simzw@gmail.com)
