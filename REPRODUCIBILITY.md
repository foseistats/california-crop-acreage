# Reproducibility notes

## What was verified

- The original script and `run.R` parse successfully.
- `Rscript --vanilla run.R` completes with the included data and standard R packages.
- All three input series contain 49 aligned years, 1960–2008, with positive, finite acreage values.
- The reproduced coefficients, adjusted R², and regression summaries agree with the rounded values printed in the supplied report.
- The regenerated `data.p3.csv` agrees numerically with the supplied file; each row's three crop proportions sum to 1 within numerical tolerance.
- Original scripts, data exports, report, and PNGs are preserved without modifying their contents.

## Data conventions

The TXT inputs contain `yr` and `acres` columns. Acreage is in unscaled acres. The script divides acreage by 100,000 before modeling.

The supplied `fruitnew.csv` and `vegnew.csv` have an exported row-index column, `yr`, scaled `acres`, and `zt`. The original script writes `vegnew.csv` **before** adding `zt`, so its regenerated vegetable CSV has no `zt` column. The runner keeps that version in `outputs/vegnew.csv` and does not replace the supplied one.

The script does not write `fruitnew.csv`; that supplied export is included as supporting material.

`data.p3.csv` contains `zt`, `yf`, `yv`, and `yo`, where the last three are fruit, vegetable, and other-crop shares of their combined acreage. These proportions are prepared here, but no model of the proportions is fitted in the supplied Part 1 script.

## Running the original script directly

`source("part1 script.R")` works from the project root, but writes `vegnew.csv` and `data.p3.csv` in that working directory. Use `run.R` to keep those writes separate from the supplied files and to save model summaries and plots automatically.

The runner validates the expected year alignment before the original script combines data by row position. No statistical model formulas or transformations in the original script were changed.

## Scope

The project folder identifies the coursework as Spring 2025. The supplied report's title page displays November 23, 2026. The report is preserved as supplied, and no submission-date claim is made in the README.

The original report discusses potential extensions and uses the word seasonality in its conclusion. Annual data can show fluctuations but do not establish within-year seasonality. No polynomial, generalized additive, generalized linear, or time-series model is fitted by this supplied script.

The run records the current R session in `outputs/session-info.txt`. Exact historical software versions were not supplied, so reproduction confirms the numerical results in the current environment rather than recreating the original software environment.
