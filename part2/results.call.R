##
tar_read(veg.data)


##
summary(tar_read(gompertz.fit))
confint(tar_read(gompertz.fit),level = 0.95)
##ci for sigma^2
lower <- ((45) * 0.4876229) / qchisq(1 - 0.05/2, df = 45)
upper <- ((45) * 0.4876229) / qchisq(0.05/2, df = 45)
c(lower, upper)



# Assume gompertz_model is your fitted nls model
gompertz_model <- tar_read(gompertz.fit)


# Plot the original data first
plot(vegnew$zt, vegnew$acres, type = "l",
     xlab = "Year(1=1960)",
     ylab = "Vegetable Acres (x100,000)",
     main = "Vegetable Acres with Gompertz Fit")

# Add Gompertz fit
x_vals <- seq(min(vegnew$zt), max(vegnew$zt), length.out = 100)
y_vals <- predict(gompertz_model, newdata = data.frame(zt = x_vals))
lines(x_vals, y_vals, col = "blue", lwd = 2)



##### 2
library(gridExtra)

par(mfrow=c(1,1))
plot(vegnew$zt, residuals(gompertz_model), type = "p",
     main = "Residuals from Gompertz Model",
     xlab = "Year(1=1960)", ylab = "Residuals")->gmplot
abline(h = 0, col = "red")

lm_model <- lm(acres ~ zt, data = vegnew)
plot(vegnew$zt, residuals(lm_model), type = "p",
     main = "Residuals from Linear Model",
     xlab = "Year(1=1960)", ylab = "Residuals")->lmplot
abline(h = 0, col = "red")

grid.arrange(gmplot,lmplot)

# Linear model residual variance
var_lin <- sum(resid(lm_model)^2) / df.residual(lm_model)

# Gompertz model residual variance
var_gomp <- sum(resid(gompertz_model)^2) / df.residual(gompertz_model)

cat("Linear Model σ² estimate:", round(var_lin, 4), "\n")
cat("Gompertz Model σ² estimate:", round(var_gomp, 4), "\n")



###### 3

fruit.1<-tar_read(fruit.data)
veg.1<-tar_read(veg.data)

# Extract estimates for ar1 veg
est_veg <- tar_read(fitar1veg)$par
logLik_veg <- tar_read(fitar1veg)$value

names(est_veg) <- c("beta0", "beta1", "gamma", "sigma2")
print(est_veg)
cat("Log-likelihood (vegetables):", logLik_veg, "\n")


# Extract estimates for ar1 vfruit
est_fruit <- tar_read(fitar1fruit)$par
logLik_fruit <- tar_read(fitar1fruit)$value

names(est_fruit) <- c("beta0", "beta1", "gamma", "sigma2")
print(est_fruit)
cat("Log-likelihood (fruit):", logLik_fruit, "\n")

#### scattterplots
#Vegetables
plot(veg.1$zt, veg.1$acres,
     xlab = "Year(1=1960)", ylab = "Vegetable Acres(x100,000)", pch = 19)
lines(veg.1$zt, est_veg["beta0"] + est_veg["beta1"] * veg.1$zt,
      col = "blue", lwd = 2)

# Fruits
plot(fruit.1$zt, fruit.1$acres,
     xlab = "Year(1=1960)", ylab = "Fruit Acres (x100,000) ", pch = 19)
lines(fruit.1$zt, est_fruit["beta0"] + est_fruit["beta1"] * fruit.1$zt,
      col = "blue", lwd = 2)




########## 5
# Residuals from each model
resid_simple <- residuals(tar_read(lmveg))
resid_gompertz <- residuals(tar_read(gompertz.fit))
resid_ar1 <- residuals(tar_read(fitar1veg))


#### residuals for ar1 error structure
fitted_ar1 <- 6.3185647 + 0.1513498 * veg.1$zt
epsilon_hat <- veg.1$acres - fitted_ar1
epsilon_hat_adj <- numeric(length(veg.1$acres))
epsilon_hat_adj[1] <- epsilon_hat[1] # no adjustment for first one, residuals

for (t in 2:length(veg.1$acres)) {
  epsilon_hat_adj[t] <- epsilon_hat[t] - 0.6556477 * epsilon_hat[t-1]
}



# Plot ACF
par(mfrow=c(1,3))
acf(resid_simple, main = "Simple Linear Regression")
acf(resid_gompertz, main = "Gompertz Fit")
 acf(epsilon_hat_adj, main ="AR(1) error structure")



######## 6 composite likelihood
 tar_read(fit_cl)$par #parameters
 




