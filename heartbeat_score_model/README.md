# Heartbeat SCORE, Explained!


## Goal:  Explain the Heartbeat (Firefox Satisfaction) score, using supplied covariates.

## Background

We ask a random subset of Firefox users "Please Rate Firefox".  These are some responses, along with a few selected possible explanatory covariates.

## Tasks

Claim:  Heartbeat Score (self-reported "Please Rate Firefox") is related to other measurable aspects of the Firefox experience.  Model this relationship.

1.  Explain SCORE using other covariates.
2.  Justify data analysis choices.
3.  Describe whether the model you create is 'good'.
4.  Write up repeatable analysis.
5.  Suggest 'next steps'.




## Data Dictionary:

In file `heartbeat_score_model.csv`:

- channel:

  which 'channel' of Firefox.  (release, aurora, etc.).  The release cycle for a version is:  Nightly -> Aurora (Dev Edition) -> Beta -> Release

- clockSkewed

  Is the user's clock (as they see it) 'wrong', compared to the world clock.  (naive heuristic, undercount)

- defaultBrowser

  Is Firefox the user's Default Browser at response time.

- dnt

  User has the Do Not Track header enabled.

- hasFlash

  User has any version of Shockwave Flash plugin enabled.

- locale

  User's locale.  (en-US, en-GB, es-MX, etc).

- received

  Date time the response was received at the server (GMT)

- score

  Heartbeat score.  Integer of [1, 2, 3, 4, 5].

- searchEngine

  Users 'default' search engine.  "other" means one not included in Firefox.

- series

  The 'main version' of Firefox.  42.0.1 => 42.  Increases sequentially (mostly) every 6 weeks.

- silverlight

  User has Microsoft Silverlight Plugin.

- version

  Full version of Firefox.

- usingNonIncludedSearchEngine

  User has 'other' as the default search engine.  This covers both intentional changes, and 'hijacked' search engines.


```r

# some possible loader code

D <- read.csv("./heartbeat_score_model.csv")
D$series <- as.factor(D$series)
D <- subset(D,select=c(-received, -version))

```




