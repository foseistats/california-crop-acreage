fruit<-read.table("CAfruitdat.txt",header = TRUE)
fruit$acres<-fruit$acres/100000
fruit$zt<-fruit$yr-1959

othercrop<-read.table("CAothercropdat.txt",header=TRUE)
othercrop$acres<-othercrop$acres/100000


vegetables<-read.table("CAvegetabledat.txt",header=TRUE)
vegetables$acres<-vegetables$acres/100000
write.csv(vegetables,"vegnew.csv")
vegetables$zt<-vegetables$yr-1959


all.acres<-data.frame(yf=fruit[,2],yv=vegetables[,2],yo=othercrop[,2])
# Create new data frame with row-wise proportions
df_proportions <- as.data.frame(t(apply(all.acres, 1, function(row) row / sum(row))))

# Optional: Keep column names the same
colnames(df_proportions) <- colnames(all.acres)
new.dat<-cbind(zt=fruit[,3],df_proportions)
write.csv(new.dat,"data.p3.csv",row.names = FALSE)


########## vegetables....
# Plot vegetable acres
plot(vegetables$zt, vegetables$acres, type = "l", lwd = 2,
     xlab = "Time Index (zt)", ylab = "Vegetable Acres (x100,000)",
     main = "Vegetable Acres over Time")

# Fit a linear model
veg_lm <- lm(acres ~ zt, data = vegetables)

# Summary of the fit
summary(veg_lm)

# Plot with fitted line
plot(vegetables$zt, vegetables$acres, type = "l", lwd = 2,
     xlab = "Time Index (zt)", ylab = "Vegetable Acres (x100,000)",
     main = "Vegetable Acres with Linear Fit")
abline(veg_lm, col = "red", lwd = 2)


# Residual plot
plot(vegetables$zt, residuals(veg_lm), type = "h",
     xlab = "Time Index (zt)", ylab = "Residuals",
     main = "Residuals of Linear Fit")
abline(h = 0, col = "blue")


par(mfrow=c(2,2))
plot(veg_lm)




###### fruits

# Plot fruit acres
oldpar<-par()
par(mfrow=c(1,1))
plot(fruit$zt, fruit$acres, type = "l", lwd = 2,
     xlab = "Time Index (zt)", ylab = "Fruit Acres (x100,000)",
     main = "Fruit Acres over Time")

# Fit a linear model
fruit_lm <- lm(acres ~ zt, data = fruit)

# Summary of the fit
summary(fruit_lm)

# Plot with fitted line
plot(fruit$zt, fruit$acres, type = "l", lwd = 2,
     xlab = "Time Index (zt)", ylab = "Fruit Acres (x100,000)",
     main = "Fruit Acres with Linear Fit")
abline(fruit_lm, col = "red", lwd = 2)


# Residual plot
plot(fruit$zt, residuals(fruit_lm), type = "h",
     xlab = "Time Index (zt)", ylab = "Residuals",
     main = "Residuals of Linear Fit")
abline(h = 0, col = "blue")

par(mfrow=c(2,2))
plot(fruit_lm)


