rm(list=ls())
# initialize
library(ggplot2)
library(MASS)
library(party)
options("scipen"=999, "digits"=3)

# import csv (be certain that getwd() is the root folder)
d.hb <- read.csv(paste(getwd(), "/heartbeat_score_model/heartbeat_score_model.csv", sep=""), stringsAsFactors = FALSE)
# coerce factors manually
d.hb$channel <- factor(d.hb$channel)
d.hb$locale <- factor(d.hb$locale)
d.hb$searchEngine[d.hb$searchEngine == 'yahoo-en-GB'] <- 'yahoo'
d.hb$searchEngine[d.hb$searchEngine == 'yahoo-web'] <- 'yahoo'
d.hb$searchEngine <- factor(d.hb$searchEngine)
d.hb$series <- factor(d.hb$series)
d.hb$version <- factor(d.hb$version)
# coerce to POSIX
d.hb$received <- as.POSIXct(d.hb$received, format = "%Y-%m-%d %H:%M:%S")
# display summary and classes
summary(d.hb, maxsum=15)
format(lapply(d.hb, class))

# coerce alternate df with integers to factor
d.alt <- d.hb
d.alt$clockSkewed <- factor(d.hb$clockSkewed)
d.alt$defaultBrowser <- factor(d.hb$defaultBrowser)
d.alt$dnt <- factor(d.hb$dnt)
d.alt$hasFlash <- factor(d.hb$hasFlash)
d.alt$silverlight <- factor(d.hb$silverlight)
d.alt$usingNonIncludedSearchEngine <- factor(d.hb$usingNonIncludedSearchEngine)
d.alt <- subset(d.alt, select=c(-received, -version, -locale)) 
summary(d.alt, maxsum=15)

# channel table
t.channel <- aggregate(rep(1, nrow(d.hb)) ~ channel, data = d.hb, sum)
t.channel$prop <- t.channel[,2] / sum(t.channel[,2])
names(t.channel) <- c('channel','N','prop')
t.channel[order(-t.channel$N),]

# series x channel table
t.series <- aggregate(rep(1, nrow(d.hb)) ~ channel + series, data = d.hb, sum)
names(t.series) <- c('channel','series','N')
t.series[order(-t.series$N),]

# plot all scores
plot(ordered(d.hb$score))

f.pVal <- function(x) {
  # table coefficients etc., calculate odds and p values, and combine
  t.ctable <- coef(summary(x))
  t.odds <- exp(t.ctable[, "Value"])
  t.p <- pnorm(abs(t.ctable[, "t value"]), lower.tail = FALSE) * 2
  t.ctable <- cbind(t.ctable, "odds" = t.odds, "p value" = t.p)
}
# ordered logistic regression model
m.polr <- polr(ordered(score) ~ channel + clockSkewed + defaultBrowser + dnt + hasFlash + series + silverlight + usingNonIncludedSearchEngine, data = d.alt, Hess=TRUE)
print(t.ctable <- f.pVal(m.polr))
summary(m.polr)

# ctree classification models
m.ctree <- ctree(ordered(score) ~ channel + clockSkewed + defaultBrowser + dnt + hasFlash + series + silverlight + usingNonIncludedSearchEngine, data=d.alt)
plot(m.ctree)
m.ctree <- ctree(ordered(score) ~ clockSkewed + defaultBrowser + dnt + hasFlash + series + silverlight + usingNonIncludedSearchEngine, data=d.alt)
plot(m.ctree)
m.ctree <- ctree(ordered(score) ~ clockSkewed + defaultBrowser + dnt + hasFlash + silverlight + usingNonIncludedSearchEngine, data=d.alt)
plot(m.ctree)
