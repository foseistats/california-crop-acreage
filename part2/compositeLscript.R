# Final corrected code for Question 6

# Load the data
vegdata <- read.table("CAcropdata.txt", header = TRUE)
vegacres <- veg.1$acres
zt <- 1:length(vegacres)

# Define the correct pairwise composite likelihood function
pairwise_loglik <- function(params, y, zt) {
  beta0 <- params[1]
  beta1 <- params[2]
  gamma <- params[3]
  sigma2 <- params[4]
  
  n <- length(y)
  loglik <- 0
  
  varw <- sigma2 / (1 - gamma^2)
  covw <- gamma * varw
  
  for (i in 2:n) {
    mu_i <- beta0 + beta1 * zt[i]
    mu_im1 <- beta0 + beta1 * zt[i-1]
    
    mean_vec <- c(mu_im1, mu_i)
    cov_matrix <- matrix(c(varw, covw, covw, varw), nrow = 2)
    
    loglik <- loglik + dmvnorm(c(y[i-1], y[i]), mean = mean_vec, sigma = cov_matrix, log = TRUE)
  }
  
  return(-loglik)  # negative for minimization
}

# Load mvtnorm for dmvnorm
library(mvtnorm)

# Initial guesses
beta0_start <- coef(lm(vegacres ~ zt))[1]
beta1_start <- coef(lm(vegacres ~ zt))[2]
gamma_start <- 0.5
sigma2_start <- var(residuals(lm(vegacres ~ zt))) * (1 - gamma_start^2)

# Fit using optim
fit <- optim(par = c(beta0_start, beta1_start, gamma_start, sigma2_start),
             fn = pairwise_loglik, y = vegacres, zt = zt,
             method = "BFGS", control = list(maxit = 10000))

# Store estimates
pairwise_estimates <- fit$par

names(pairwise_estimates) <- c("beta0", "beta1", "gamma", "sigma2")
pairwise_estimates

# Parametric bootstrap
set.seed(123)
B <- 1000
boot_estimates <- matrix(NA, nrow = B, ncol = 4)
colnames(boot_estimates) <- c("beta0", "beta1", "gamma", "sigma2")

for (b in 1:B) {
  # Simulate new W(t)
  n <- length(zt)
  W <- numeric(n)
  W[1] <- rnorm(1, mean = 0, sd = sqrt(pairwise_estimates["sigma2"] / (1 - pairwise_estimates["gamma"]^2)))
  
  for (t in 2:n) {
    W[t] <- pairwise_estimates["gamma"] * W[t-1] + rnorm(1, mean = 0, sd = sqrt(pairwise_estimates["sigma2"]))
  }
  
  # Create Y(t)
  Ysim <- pairwise_estimates["beta0"] + pairwise_estimates["beta1"] * zt + W
  
  # Refit
  boot_fit <- try(optim(par = pairwise_estimates,
                        fn = pairwise_loglik, y = Ysim, zt = zt,
                        method = "BFGS", control = list(maxit = 10000)), silent = TRUE)
  
  if (!inherits(boot_fit, "try-error")) {
    boot_estimates[b, ] <- boot_fit$par
  }
}

# Remove NAs
boot_estimates <- boot_estimates[complete.cases(boot_estimates), ]

# Basic bootstrap intervals
original_estimates <- pairwise_estimates



######
# Basic bootstrap intervals
basic_intervals <- function(original, bootstrap) {
  q_low <- quantile(bootstrap - original, 0.975, na.rm = TRUE)
  q_high <- quantile(bootstrap - original, 0.025, na.rm = TRUE)
  c(lower = original - q_low, upper = original - q_high)
}

# Percentile intervals
percentile_intervals <- function(bootstrap) {
  c(lower = quantile(bootstrap, 0.025, na.rm = TRUE), 
    upper = quantile(bootstrap, 0.975, na.rm = TRUE))
}

# Build all intervals
intervals <- list()

for (param in c("beta0", "beta1", "gamma", "sigma2")) {
  idx <- match(param, colnames(boot_estimates))
  original <- fit$par[idx]
  bootstrap_vals <- boot_estimates[, idx]
  
  intervals[[param]] <- list(
    basic = basic_intervals(original, bootstrap_vals),
    percentile = percentile_intervals(bootstrap_vals)
  )
}

# Display
intervals

