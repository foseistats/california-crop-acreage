# From part3/: Rscript --vanilla run.R
# Runs only the self-contained fitting section of the original script.
# It does not implement or reproduce a full Dirichlet regression.
main <- function() {
  if (!file.exists("part3codes.R")) stop("Run from the part3 folder.")
  packages <- c("ggplot2", "tidyr")
  missing <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
  if (length(missing)) stop("Install packages: ", paste(missing, collapse = ", "))
  data <- read.csv("data.p3.csv")
  stopifnot(identical(names(data), c("zt", "yf", "yv", "yo")),
            nrow(data) == 49, all(data$zt == 1:49),
            all(is.finite(as.matrix(data))),
            all(as.matrix(data[c("yv", "yf", "yo")]) > 0),
            all(abs(rowSums(data[c("yv", "yf", "yo")]) - 1) < 1e-12))
  code <- readLines("part3codes.R", warn = FALSE)
  boundary <- grep("^#+ *7 *$", code)
  if (length(boundary) != 1) stop("Original section boundary changed; review runner.")
  dir.create("outputs", showWarnings = FALSE)
  grDevices::pdf("outputs/original-fitting-section.pdf", width = 10, height = 7)
  device <- grDevices::dev.cur()
  on.exit({if (device %in% grDevices::dev.list()) grDevices::dev.off(device)}, add = TRUE)
  env <- new.env(parent = globalenv())
  connection <- textConnection(code[seq_len(boundary - 1L)])
  on.exit(close(connection), add = TRUE)
  # print.eval renders the original ggplot expression in a non-interactive run.
  source(connection, local = env, print.eval = TRUE)
  grDevices::dev.off(device)
  stopifnot(env$fit$convergence == 0)
  predictions <- data.frame(zt = data$zt, vegetable = env$mu_v_hat,
                             fruit = env$mu_f_hat, other = env$mu_o_hat)
  stopifnot(all(as.matrix(predictions[-1]) > 0),
            all(abs(rowSums(predictions[-1]) - 1) < 1e-12))
  write.csv(predictions, "outputs/fitted-proportions.csv", row.names = FALSE)
  write.csv(data.frame(parameter = c("beta_v0", "beta_v1", "beta_f0", "beta_f1"),
                        estimate = env$fit$par),
            "outputs/four-parameter-estimates.csv", row.names = FALSE)
  capture.output({
    cat("Original four-parameter objective; NOT a full Dirichlet fit.\n")
    print(env$fit)
    cat("\nLater residual and Beta-marginal diagnostic sections were not executed.\n")
  }, file = "outputs/fit-summary.txt")
  capture.output(sessionInfo(), file = "outputs/session-info.txt")
  cat("Saved verified initial-section outputs. See REPRODUCIBILITY.md for scope.\n")
}
main()
