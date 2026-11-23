# Part 3 reproduction notes

## Completed checks

The original script parses. Its initial four-parameter optimizer completes with convergence code 0. The new runner executes that initial section in a clean R session, exports fitted proportions and coefficients, and records the software environment. The 49 input rows match Part 1's `data.p3.csv`; each observed composition is positive and sums to one within numerical tolerance. The fitted proportions are also positive and sum to one at the observed years for this run.

The original script, data, RStudio project, report, and eleven PNG figures are preserved unchanged (the report filename is clarified).

## Code and report differ

- `loglik_model8()` has only four parameters. It minimizes the negative sum of `yv * log(mu_v) + yf * log(mu_f) + yo * log(mu_o)`. It contains no Dirichlet precision parameter or Dirichlet normalizing terms, so running this function does not reproduce the report's five-parameter Dirichlet fit.
- The two means use separate inverse logits with `mu_o = 1 - mu_v - mu_f`. This does not enforce a positive third component for every possible parameter vector. Clipping inside the objective can conceal invalid candidate compositions, though the fitted values from the verified run are valid at the observed times. No parameterization was changed here.
- Reported slopes and the report's precision estimate are not reproduced by the supplied optimizer. The time variable has not been rescaled by the runner to try to reconcile them.
- The script contains no confidence-band construction or covariance-based interval calculation matching the report's bands. The PNGs are supporting artifacts rather than newly verified interval estimates.

## Why the full script stops

The last section reads `fit$par[5]`, but the fitted vector has length four, giving `phi_hat = NA`. It also references a bare `zt` object that is not defined in a clean session. Direct execution stops with `object 'zt' not found`. Defining that variable alone would not supply the missing precision estimate needed by the Beta-marginal calculations.

The section labeled 7 uses hard-coded coefficients, instead of the current optimizer results, for the residual calculations. It additionally computes unused `mu.v` and `mu.f` by applying an inverse-logit transformation to quantities already on the probability scale. The runner stops before this section and makes no claim to reproduce its residual figures.

## Diagnostic interpretation

The supplied ACF/PACF figures show remaining temporal structure. Ordinary K–S p-values do not automatically account for serial dependence or the estimation of distributional parameters from the same observations. Non-significant p-values alone do not establish model adequacy. The original report is preserved, and its reported diagnostic p-values are not represented as independently verified here.

To reproduce a full Dirichlet workflow, the model specification and corresponding estimation/diagnostic code would need to be reconciled with the report. No replacement statistical analysis has been silently substituted for the supplied coursework.
