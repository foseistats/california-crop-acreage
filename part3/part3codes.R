###### 1
data.p3<-read.csv("data.p3.csv")
### sactterplot
library(ggplot2)
library(tidyr)

# Convert to long format for ggplot
df_long <- pivot_longer(data.p3,
                        cols = c("yv", "yf", "yo"),
                        names_to = "crop",
                        values_to = "proportion")

# Rename crop levels for plot legend
df_long$crop <- factor(df_long$crop,
                       levels = c("yv", "yf", "yo"),
                       labels = c("Vegetables", "Fruits", "Other"))

# Create the plot
ggplot(df_long, aes(x = zt, y = proportion, color = crop)) +
  geom_point() +
  geom_line() +
  labs(title = "",
       x = "Year (1=1960)",
       y = "Proportion of Total Harvested Acres",
       color = "Crop Type") +
  theme_minimal()




####### 4
loglik_model8 <- function(par, zt, yv, yf) {
  # Parameters: intercepts and slopes
  beta_v0 <- par[1]
  beta_v1 <- par[2]
  beta_f0 <- par[3]
  beta_f1 <- par[4]
  
  eta_v <- beta_v0 + beta_v1 * zt
  eta_f <- beta_f0 + beta_f1 * zt
  
  # Predicted proportions via logistic
  mu_v <- exp(eta_v) / (1 + exp(eta_v))
  mu_f <- exp(eta_f) / (1 + exp(eta_f))
  
  mu_o <- 1 - mu_v - mu_f
  
  # Avoid log(0) by clipping
  eps <- 1e-10
  mu_v <- pmax(mu_v, eps)
  mu_f <- pmax(mu_f, eps)
  mu_o <- pmax(mu_o, eps)
  
  # Log-likelihood
  ll <- yv * log(mu_v) + yf * log(mu_f) + (1 - yv - yf) * log(mu_o)
  
  return(-sum(ll))  # negative log-likelihood
}

# Starting values
init_par <- c(0, 0, 0, 0)  # (beta_v0, beta_v1, beta_f0, beta_f1)

fit <- optim(
  par = init_par,
  fn = loglik_model8,
  zt = data.p3$zt,
  yv = data.p3$yv,
  yf = data.p3$yf,
  method = "BFGS",
  hessian = TRUE
)

fit$par  # estimated beta coefficients

eta_v_hat <- fit$par[1] + fit$par[2] * data.p3$zt
eta_f_hat <- fit$par[3] + fit$par[4] * data.p3$zt
mu_v_hat <- exp(eta_v_hat) / (1 + exp(eta_v_hat))
mu_f_hat <- exp(eta_f_hat) / (1 + exp(eta_f_hat))
mu_o_hat <- 1 - mu_v_hat - mu_f_hat



# 1. Create scatterplot with actual data
plot(data.p3$zt, data.p3$yv, type = "p", col = "darkgreen", pch = 16,
     ylim = c(0, 1), ylab = "Proportion", xlab = "Year (1=1960)", main = "Proportions and Fitted Dirichlet Model")
points(data.p3$zt, data.p3$yf, col = "darkorange", pch = 16)
points(data.p3$zt, data.p3$yo, col = "gray", pch = 16)

# 2. Recompute fitted values using estimated parameters
beta_v0 <- fit$par[1]
beta_v1 <- fit$par[2]
beta_f0 <- fit$par[3]
beta_f1 <- fit$par[4]

eta_v_hat <- beta_v0 + beta_v1 * data.p3$zt
eta_f_hat <- beta_f0 + beta_f1 * data.p3$zt

mu_v_hat <- exp(eta_v_hat) / (1 + exp(eta_v_hat))
mu_f_hat <- exp(eta_f_hat) / (1 + exp(eta_f_hat))
mu_o_hat <- 1 - mu_v_hat - mu_f_hat

# 3. Add fitted curves
lines(data.p3$zt, mu_v_hat, col = "darkgreen", lwd = 2)
lines(data.p3$zt, mu_f_hat, col = "darkorange", lwd = 2)
lines(data.p3$zt, mu_o_hat, col = "gray", lwd = 2)

# 4. Add legend
legend("topright", legend = c("Vegetables", "Fruits", "Other"),
       col = c("darkgreen", "darkorange", "gray"), lty = 1, pch = 16, lwd = 2)





######### 7
etav=plogis(-2.34864597+0.02453705*data.p3$zt)
etaf=plogis(-1.74429627+0.02440692*data.p3$zt)
mu.v= exp(etav) / (1 + exp(etav))
res.v=data.p3$yv-etav
  mu.f=  exp(etaf) / (1 + exp(etaf))
  res.f=data.p3$yf-etaf
  
par(mfrow=c(1,2))  
plot(data.p3$zt,res.v,main="vegetables")
plot(data.p3$zt,res.f,main="fruits")
acf(res.f,main="fruits")
acf(res.v,main="vegetables")




#########8
# Extract parameter estimates
beta_v0 <- fit$par[1]
beta_v1 <- fit$par[2]
beta_f0 <- fit$par[3]
beta_f1 <- fit$par[4]
phi_hat <- exp(fit$par[5])

# Linear predictors
eta_v <- beta_v0 + beta_v1 * zt
eta_f <- beta_f0 + beta_f1 * zt

# Fitted proportions using softmax-like transformation
mu_v <- exp(eta_v) / (1 + exp(eta_v))
mu_f <- exp(eta_f) / (1 + exp(eta_f))
mu_o <- 1-mu_v-mu_f

# Alpha values
alpha_v <- phi_hat * mu_v
alpha_f <- phi_hat * mu_f
alpha_o <- phi_hat * mu_o

# Compute CDF values from Beta marginals
u_v <- pbeta(data.p3$yv, shape1 = alpha_v, shape2 = phi_hat - alpha_v)
u_f <- pbeta(data.p3$yf, shape1 = alpha_f, shape2 = phi_hat - alpha_f)
u_o <- pbeta(data.p3$yo, shape1 = alpha_o, shape2 = phi_hat - alpha_o)

# K-S tests for uniformity
ks_v <- ks.test(u_v, "punif")
ks_f <- ks.test(u_f, "punif")
ks_o <- ks.test(u_o, "punif")

# Display diagnostics
list(
  p_values = c(vegetable = ks_v$p.value, fruit = ks_f$p.value, other = ks_o$p.value),
  ks_stats = c(vegetable = ks_v$statistic, fruit = ks_f$statistic, other = ks_o$statistic)
)















