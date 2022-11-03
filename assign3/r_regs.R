### Comparing fixest in R with gravity ###
### 11/2/2022 ### 

library(tidyverse)
library(fixest)

# please set your directory
dir = "/Users/junwong/Dropbox/Second Year/Dingel - Trade/assignments"
setwd(dir)

# import data
df <- read.csv("data/Detroit.csv")
df <- df %>% 
  mutate(across(c(flows, distance_Google_miles, duration_minutes), log))

# regressions 
est1 = feols(flows ~ distance_Google_miles | work_ID + home_ID, df, vcov="hetero")
est2 = feols(flows ~ duration_minutes | work_ID + home_ID, df, vcov="hetero")

# style that i like
styledoc = style.tex( main = "aer",
  depvar.title = "Dependent Variable",
  model.title = "",
  fixef.suffix = " FE",
  yesNo = "Yes",
  signif.code = c("***"=0.01, "**"=0.05, "*"=0.10)
)

# variable labels
varlabel=c(flows = "Log(Flows)", 
       distance_Google_miles = "Log(Distance)",
       duration_minutes = "Log(Duration)",
       work_ID = "Destination",
       home_ID = "Home")

# output the table 
etable(est1, est2, tex=T, style.tex = styledoc, dict=varlabel, 
       extralines=list("Run Time"=c("1", "1")))

