rm(list=ls())
# initialize
library(plyr)
library(ggplot2)
library(car)
library(tm)
library(SnowballC)
library(wordcloud)
library(cluster)
library(ggdendro)
library(fpc)   
options("scipen"=999, "digits"=3)

# import csv (be certain that getwd() is the root folder)
d.input <- read.csv(paste(getwd(), "/input_feedback_data/feedbackSample.csv", sep=""), stringsAsFactors=FALSE)
# correct missing platform string
d.input$platform[d.input$platform==""] <- "Linux"
d.input$platform <- factor(d.input$platform)
# collapse platforms into wider vendor categories
d.input$platform_wide <- strtrim(as.character(d.input$platform), 7)
d.input$platform_wide[d.input$platform_wide=="Fedora"] <- "Linux"
d.input$platform_wide <- factor(d.input$platform_wide)
# correct irregular strings
d.input$browser_version[d.input$browser_version=="43.0;"] <- "43"
d.input$browser_version[d.input$browser_version=="40.0.3"] <- "40"
d.input$browser_verlen <- nchar(d.input$browser_version)
# collapse browser_version into 3 categories
d.input$browser_cat <- character(length = nrow(d.input))
d.input$browser_cat[d.input$browser_version >= 43] <- 'post-update'
d.input$browser_cat[d.input$browser_version <  43] <- 'pre-update'
d.input$browser_cat[d.input$browser_verlen > 2] <- 'legacy' # these versions have nchar 6, all recent have 2
d.input$browser_cat <- factor(d.input$browser_cat)
# manually coerce classes
d.input$date <- as.POSIXct(d.input$date, format = "%m/%d/%Y")
d.input$browser <- factor(d.input$browser)
d.input$browser_version <- factor(d.input$browser_version)
d.input$platform <- factor(d.input$platform)

# sample sizes and %happy by browser_cat and platform_wide
aggregate(happy ~ browser_cat + platform_wide, data = d.input, each(length,mean))

# bar plot of %happy by browser_cat and platform_wide (excluding small groups)
t.input <- d.input[d.input$platform_wide != 'Android',]
t.input <- t.input[t.input$browser_cat != 'legacy',]
ggplot(data=aggregate(happy ~ browser_cat + platform_wide, data = t.input, mean),
       aes(x=platform_wide, y=happy, fill=browser_cat)) + 
  geom_bar(stat="identity", position=position_dodge())

# 1-way ANOVA with type III SS
Anova(lm(happy ~ browser_cat, data = t.input), type="3")
# 2-way ANOVA with type III SS
Anova(lm(happy ~ browser_cat*platform_wide, data = t.input), type="3")

# sample sizes and %happy by browser_cat and platform (Windows only)
aggregate(happy ~ browser_cat + platform, data = t.input[t.input$platform_wide=='Windows',], each(length,mean))
ggplot(data=aggregate(happy ~ browser_cat + platform, data = t.input[t.input$platform_wide=='Windows',], mean),
       aes(x=platform, y=happy, fill=browser_cat)) + 
  geom_bar(stat="identity", position=position_dodge()) + theme(axis.text.x = element_text(angle = 90, hjust = 1))

# plot %happy over days by browser_cat and platform_wide
t.date <- aggregate(happy ~ date + browser_cat + platform_wide, data = t.input, mean)
ggplot(t.date, aes(as.Date(date), happy)) + scale_x_date() + geom_line(aes(color = browser_cat)) + facet_grid(. ~ platform_wide) + theme(axis.text.x = element_text(angle = 90, hjust = 1))

# functions to create and preprocess document corpi for text mining, and to generate word clouds
f.impCorp <- function(x, whole= FALSE) {
  # either collapse descriptions into one field or leave as many
  if (whole) {
    review_text <- paste(x, collapse=" ")  
  } else {
    review_text <- x  
  }
  # create vector source of descriptions, collect as corpus structure
  review_source <- VectorSource(review_text)
  corpus <- Corpus(review_source)
}
f.DTM <- function(corpus) {
  # preprocess text corpus
  corpus <- tm_map(corpus, removeNumbers)
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, tolower)
  corpus <- tm_map(corpus, removeWords, stopwords("english"))
  corpus <- tm_map(corpus, removeWords, c('firefox', 'mozilla','browser','yahoo','chrome'))
  corpus <- tm_map(corpus, stemDocument)
  corpus <- tm_map(corpus, stripWhitespace)
  corpus <- tm_map(corpus, PlainTextDocument)
  # create document term matrix from corpus
  dtm <- DocumentTermMatrix(corpus)
}
f.wordCloud <- function(dtm, size= 20) {
  # cast dtm to integer matrix, collapse over documents for sorted term sums
  dtm2 <- as.matrix(dtm)
  frequency <- colSums(dtm2)
  frequency <- sort(frequency, decreasing=TRUE)
  # get term char strings from sorted term count vector and plot word cloud
  words <- names(frequency)
  wordcloud(words[1:size], frequency[1:size], colors=brewer.pal(6, "Dark2"))
}

# organize each corpus to be analyzed
d.manyCorpHpre <- f.impCorp(d.input$description[d.input$happy==1 & d.input$browser_cat=='pre-update'])
d.manyDTMHpre <- f.DTM(d.manyCorpHpre)
d.manyDTMHpre
d.manyCorpHpost <- f.impCorp(d.input$description[d.input$happy==1 & d.input$browser_cat=='post-update'])
d.manyDTMHpost <- f.DTM(d.manyCorpHpost)
d.manyDTMHpost
d.manyCorpUpre <- f.impCorp(d.input$description[d.input$happy==0 & d.input$browser_cat=='pre-update'])
d.manyDTMUpre <- f.DTM(d.manyCorpUpre)
d.manyDTMUpre
d.manyCorpUpost <- f.impCorp(d.input$description[d.input$happy==0 & d.input$browser_cat=='post-update'])
d.manyDTMUpost <- f.DTM(d.manyCorpUpost)
d.manyDTMUpost

# happy word cloud pre-update
f.wordCloud(d.manyDTMHpre, 40)
# happy word cloud post-update
f.wordCloud(d.manyDTMHpost, 40)
# unhappy word cloud pre-update
f.wordCloud(d.manyDTMUpre, 40)
# unhappy word cloud post-update
f.wordCloud(d.manyDTMUpost, 40)

t.corr <- 0.4
# Happy pre-update term correlations
findAssocs(d.manyDTMHpre, c("problem", "crash", "freez", "flash", "plugin", "bug", "ticket","addon","update","release"), corlimit=t.corr)
# Happy post-update term correlations
findAssocs(d.manyDTMHpost, c("problem", "crash", "freez", "flash", "plugin", "bug", "ticket","addon","update","release"), corlimit=t.corr)
# Unhappy pre-update term correlations
findAssocs(d.manyDTMUpre, c("problem", "crash", "freez", "flash", "plugin", "bug", "ticket","addon","update","release"), corlimit=t.corr)
# Unhappy post-update term correlations
findAssocs(d.manyDTMUpost, c("problem", "crash", "freez", "flash", "plugin", "bug", "ticket","addon","update","release"), corlimit=t.corr)

# thin the DTMs, otherwise it runs excessively long
# t.manyDTMHpre <- removeSparseTerms(d.manyDTMHpre, 0.95)
# t.manyDTMHpost <- removeSparseTerms(d.manyDTMHpost, 0.95)
t.manyDTMUpre <- removeSparseTerms(d.manyDTMUpre, 0.95)
t.manyDTMUpost <- removeSparseTerms(d.manyDTMUpost, 0.95)

# compute distances
# d.distHpre <- dist(t(t.manyDTMHpre), method="euclidian")
# d.distHpost <- dist(t(t.manyDTMHpost), method="euclidian")
d.distUpre <- dist(t(t.manyDTMUpre), method="euclidian")   
d.distUpost <- dist(t(t.manyDTMUpost), method="euclidian")   

# hierarchical clustering
# m.hcHpre <- hclust(d=d.distHpre, method="ward.D2")
# m.hcHpost <- hclust(d=d.distHpost, method="ward.D2")
m.hcUpre <- hclust(d=d.distUpre, method="ward.D2")   
m.hcUpost <- hclust(d=d.distUpost, method="ward.D2")   

# plot hc dendrograms
# ggdendrogram(m.hcHpre, rotate = TRUE, size = 4, theme_dendro = FALSE, color = "tomato")
# ggdendrogram(m.hcHpost, rotate = TRUE, size = 4, theme_dendro = FALSE, color = "tomato")
ggdendrogram(m.hcUpre, rotate = TRUE, size = 4, theme_dendro = FALSE, color = "tomato")
ggdendrogram(m.hcUpost, rotate = TRUE, size = 4, theme_dendro = FALSE, color = "tomato")

# # k-means clustering
# m.kfitHpre <- kmeans(d.distHpre, 2)
# m.kfitHpost <- kmeans(d.distHpost, 2)
# m.kfitUpre <- kmeans(d.distUpre, 2)
# m.kfitUpost <- kmeans(d.distUpost, 2)
# 
# # plot k-means clusters
# clusplot(as.matrix(d.distHpre),  m.kfitHpre$cluster, color=T, shade=T, labels=2, lines=0)
# clusplot(as.matrix(d.distHpost), m.kfitHpost$cluster, color=T, shade=T, labels=2, lines=0) 
# clusplot(as.matrix(d.distUpre),  m.kfitUpre$cluster, color=T, shade=T, labels=2, lines=0) 
# clusplot(as.matrix(d.distUpost), m.kfitUpost$cluster, color=T, shade=T, labels=2, lines=0) 
