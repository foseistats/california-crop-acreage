# Correct code for composite likelihood estimation and bootstrap in R

# Define negative composite log likelihood for AR(1) model
neglogcl <- function(theta, yv, zt) {
  beta0 <- theta[1]
  beta1 <- theta[2]
  gamma <- theta[3]
  sigma2 <- theta[4]
  
  
  
 # Guard against invalid parameter regions
  if (sigma2 <= 0 || abs(gamma) >= 1) {
    return(1e10)  # Return a large number if illegal parameter values
  }
  
  # Means at times t-1 and t
  mu_tminus1 <- beta0 + beta1 * zt[-length(zt)]
  mu_t <- beta0 + beta1 * zt[-1]
  
  # Observed pairs
  y_tminus1 <- yv[-length(yv)]
  y_t <- yv[-1]
  
  # Compute quadratic form
  quad <- (y_tminus1 - mu_tminus1)^2 + (y_t - mu_t)^2 - 2 * gamma * (y_tminus1 - mu_tminus1) * (y_t - mu_t)
  
  # Determinant of 2x2 covariance matrix: det = sigma2^2 * (1 - gamma^2)
  log_det <- 2 * log(sigma2) + log(1 - gamma^2)
  
  # Composite likelihood value (ignoring constants)
  cl_value <- -(length(y_t)) * 0.5 * log_det - (1 - gamma^2) * sum(quad) / (2 * sigma2)
  
  return(-cl_value)  # negative for minimization
}

# Example starting values (adjust if needed)
beta0_start <- 7
beta1_start <- 1
gamma_start <- 0.5
sigma2_start <- 0.4

# Assume yv is your vegetable acres data and zt is the time index
# Example: yv <- veg.data$acres, zt <- veg.data$time
yv<-veg.1$acres
zt<-veg.1$zt


# Fit composite likelihood model
fit_cl <- optim(
  par = c(beta0_start, beta1_start, gamma_start, sigma2_start),
  fn = neglogcl,
  yv = yv,
  zt = zt,
  method = "BFGS",
  hessian = TRUE
)

# Extract parameter estimates
fit_cl$par

set.seed(NULL)

B <- 1000
boot_estimates <- matrix(NA, nrow = B, ncol = 4)
beta0_hat<-6.971990
beta1_hat<-0.961735
gamma_hat<-0.999114
sigma2_hat<-0.407181

for (b in 1:B) {
  
  # Simulate new data under the estimated model
  y_boot <- numeric(length(zt))
  y_boot[1] <- rnorm(1, mean = beta0_hat + beta1_hat * zt[1], 
                      sd = sqrt(sigma2_hat / (1 - gamma_hat^2)))
  
  for (i in 2:length(zt)) {
    mean_i <- beta0_hat + beta1_hat * zt[i] + gamma_hat * (y_boot[i-1] - beta0_hat - beta1_hat * zt[i-1])
    y_boot[i] <- rnorm(1, mean = mean_i, sd = sqrt(sigma2_hat))
  }
  
  # Try fitting
  fitb <- tryCatch({
    optim(
      par = c(beta0_hat, beta1_hat, gamma_hat, sigma2_hat),
      fn = neglogcl,
      zt = y_boot,
      zt = zt,
      method = "BFGS",
      control = list(maxit = 5000)
    )
  }, error = function(e) NULL)
  
  # Save only if fit was successful
  if (!is.null(fitb) && fitb$convergence == 0) {
    boot_estimates[b, ] <- fitb$par
  }
}

# Remove rows that are all NA
boot_estimates <- boot_estimates[complete.cases(boot_estimates), ]


