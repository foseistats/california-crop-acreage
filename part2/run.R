# From part2/: Rscript --vanilla run.R
main <- function() {
  if (!file.exists("_targets.R")) stop("Run this script from the part2 folder.")
  targets::tar_make(callr_function = NULL)
  dir.create("outputs", showWarnings = FALSE)
  gompertz <- targets::tar_read(gompertz.fit)
  veg <- targets::tar_read(veg.data)
  fruit <- targets::tar_read(fruit.data)
  arveg <- targets::tar_read(fitar1veg)
  arfruit <- targets::tar_read(fitar1fruit)
  stopifnot(arveg$convergence == 0, arfruit$convergence == 0)
  capture.output({
    cat("GOMPERTZ FIT\n"); print(summary(gompertz))
    cat("\nVEGETABLE AR(1) FIT (value is NEGATIVE log likelihood)\n"); print(arveg)
    cat("\nFRUIT AR(1) FIT (value is NEGATIVE log likelihood)\n"); print(arfruit)
    cat("\nORIGINAL COMPOSITE TARGET: REVIEW REQUIRED; see REPRODUCIBILITY.md\n")
    print(targets::tar_read(fit_cl))
  }, file = "outputs/model-summaries.txt")
  estimates <- rbind(arveg$par, arfruit$par)
  colnames(estimates) <- c("intercept", "slope", "phi", "innovation_variance")
  write.csv(data.frame(crop = c("Vegetables", "Fruit"), estimates,
                       negative_log_likelihood = c(arveg$value, arfruit$value)),
            "outputs/ar1-estimates.csv", row.names = FALSE)
  grDevices::pdf("outputs/model-plots.pdf", width = 12, height = 5)
  device <- grDevices::dev.cur()
  on.exit({if (device %in% grDevices::dev.list()) grDevices::dev.off(device)}, add = TRUE)
  plot(veg$zt, veg$acres, type = "l", xlab = "Year index (1 = 1960)",
       ylab = "Vegetable acres (100,000s)", main = "Gompertz fit")
  lines(veg$zt, fitted(gompertz), col = "blue", lwd = 2)
  innovations <- function(data, fit) {
    e <- data$acres - (fit$par[1] + fit$par[2] * data$zt)
    # Standardize the initial stationary error to the innovation variance scale.
    c(sqrt(1 - fit$par[3]^2) * e[1], e[-1] - fit$par[3] * head(e, -1))
  }
  par(mfrow = c(1, 3))
  acf(resid(targets::tar_read(lmveg)), main = "Linear model errors")
  acf(resid(gompertz), main = "Gompertz errors")
  acf(innovations(veg, arveg), main = "AR(1) innovations")
  grDevices::dev.off(device)
  capture.output(sessionInfo(), file = "outputs/session-info.txt")
  cat("Part 2 outputs saved under outputs/. Composite/ bootstrap limitations remain documented.\n")
}
main()
