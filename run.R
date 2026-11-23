# Run with: Rscript --vanilla run.R (from the repository root).
# Execute the original analysis in a temporary directory so its CSV writes
# do not replace the supplied files. All saved results go into outputs/.
main <- function() {
  root <- normalizePath(getwd(), mustWork = TRUE)
  inputs <- c("CAfruitdat.txt", "CAvegetabledat.txt", "CAothercropdat.txt")
  required <- c(inputs, "part1 script.R")
  missing <- required[!file.exists(required)]
  if (length(missing)) stop("Run from the project root. Missing: ", paste(missing, collapse = ", "))

  datasets <- lapply(inputs, function(f) read.table(f, header = TRUE))
  for (d in datasets) {
    stopifnot(identical(names(d), c("yr", "acres")), nrow(d) == 49L,
              all(d$yr == 1960:2008), all(is.finite(d$acres)), all(d$acres > 0))
  }

  output <- file.path(root, "outputs")
  dir.create(output, showWarnings = FALSE)
  work <- tempfile("crop-analysis-")
  dir.create(work)
  oldwd <- getwd()
  on.exit({setwd(oldwd); unlink(work, recursive = TRUE)}, add = TRUE)
  stopifnot(all(file.copy(file.path(root, inputs), work)))
  setwd(work)

  grDevices::pdf(file.path(output, "analysis-plots.pdf"), width = 9, height = 7)
  device <- grDevices::dev.cur()
  on.exit({if (device %in% grDevices::dev.list()) grDevices::dev.off(device)}, add = TRUE)
  analysis <- new.env(parent = globalenv())
  sys.source(file.path(root, "part1 script.R"), envir = analysis)
  grDevices::dev.off(device)

  capture.output({
    cat("VEGETABLE ACREAGE MODEL\n")
    print(summary(analysis$veg_lm))
    cat("\nFRUIT ACREAGE MODEL\n")
    print(summary(analysis$fruit_lm))
  }, file = file.path(output, "model-summaries.txt"))
  write.csv(data.frame(
    crop = c("Vegetables", "Fruit"),
    intercept = c(coef(analysis$veg_lm)[1], coef(analysis$fruit_lm)[1]),
    slope = c(coef(analysis$veg_lm)[2], coef(analysis$fruit_lm)[2]),
    adjusted_r_squared = c(summary(analysis$veg_lm)$adj.r.squared,
                           summary(analysis$fruit_lm)$adj.r.squared)
  ), file.path(output, "model-metrics.csv"), row.names = FALSE)
  stopifnot(all(file.copy(c("vegnew.csv", "data.p3.csv"), output, overwrite = TRUE)))
  capture.output(sessionInfo(), file = file.path(output, "session-info.txt"))
  cat("Results saved to", output, "\n")
}
main()
