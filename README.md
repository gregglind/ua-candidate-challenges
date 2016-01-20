**Deadline**: Monday, January 25, 2016

##Instructions

Below you will find two data analysis tasks.  We ask you to spend a little time considering each task, formulating / documenting your analysis workflow, and submitting the result / workflow.  Each task should take a few hours, we are looking for quality of process / analysis, not necessarily a given answer.

Feel free to use any language / tools that you are comfortable with (R, Python, Matlab, etc).  Feel free to report your insights in any way that you are comfortable with (Google Presentation, Markdown, etc).  Feel free to submit your assignment in any way that you are comfortable with (GitHub, email, Dropbox, etc).


##User Feedback Data Analysis

###Background

As discussed in your phone-screens with Matt and Rob, we have a tool called Input that we use to collect unsolicited feedback from Firefox users in our various products.  We use this system to provide insights as to whether a given release is healthy.

###Task

You will find feedbackSample.csv in the ./input\_feedback\_data/ subdirectory.  It contains a raw dump of the English Input feedback for Firefox Desktop from 2015/12/06 to 2015/12/26.  This range includes the period in which Firefox 43 was released (2015/12/15).  Your task is to consider whether there are any issues coming up that may be worth reporting to the relevant stakeholders.  Note that new issues (e.g. spike in Flash crashes) are more relevant than existing large issues (e.g. steady levels of crashing complaints).

###Deliverable

Write up your analysis in any format you want.  Please make sure it is easy for us to follow and reproduce your work.  Any analysis should be easily reproducible from the raw data file and your report.

##User Rating / Config Data Analysis

###Background

As discussed with Rebecca, we have two systems by which we can collect data.  We have Heartbeat, which is a mechanism of randomly sampling Firefox clients and asking users to rate Firefox on a 5-star scale.  We also have Telemetry, which is a collection of machine-state and configuration measurements for a given Firefox client.

###Task

We have given you a set of data that consists of the Heartbeat score and some Telemetry covariates in the ./heartbeat\_score\_model/ subdirectory.  Evaluate the following claim: Heartbeat Score (self-reported "Please Rate Firefox") is related to other measurable aspects of the Firefox experience.   Please perform your analysis using Python, R, or GNU Octave.

**Minimum requirements**:
* Fit a model that explains scores using other covariates.
* Identify those covariates that are better for predicting scores.
* Describe whether the model you create is 'good'.
* Suggest 'next steps'.

For each of the minimum requirements, please provide justification for all analysis choices you made en route to your ultimate responses.

###Deliverable

Write up your analysis in any format you want.  Please make sure it is easy for us to follow and reproduce your work.  Any analysis should be easily reproducible from the raw data file and your report.


If you have questions please email Matt Grimes.
