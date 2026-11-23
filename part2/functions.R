
gompertz_model <-function(x){
  nls(
  acres ~ alpha0 + alpha1 * exp(-exp(beta - gamma * zt)),
  data = x,
  start = list(alpha0 = 6.495, alpha1 = 7.91763, beta = 3, gamma = 0.1)
)
}


##### 2







####### 3
#for vegetables  and fruits
loglik_ar1 <- function(params, y, z) {
  beta0 <- params[1]
  beta1 <- params[2]
  phi   <- params[3]
  sigma2 <- params[4]
  
  if (abs(phi) >= 1 || sigma2 <= 0) return(Inf)  # enforce stationarity
  
  mu <- beta0 + beta1 * z
  n <- length(y)
  
  e1 <- (y[1] - mu[1])^2 / (sigma2 / (1 - phi^2))
  rest <- sum((y[-1] - mu[-1] - phi * (y[-n] - mu[-n]))^2)
  
  loglik <- -0.5 * log(2 * pi * sigma2 / (1 - phi^2)) - 0.5 * e1 -
    0.5 * (n - 1) * log(2 * pi * sigma2) - 0.5 * rest / sigma2
  
  return(-loglik)  # we minimize
}

# Starting values from simple linear regression
#lm_start <- lm(vegetables ~ zt, data = crop_data)






########## 6
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


