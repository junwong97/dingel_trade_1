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
base1 <- proc.time()
est1 = feols(flows ~ distance_Google_miles | work_ID + home_ID, df, vcov="hetero")
time1 <- proc.time() - base1

base2 <- proc.time()
est2 = feols(flows ~ duration_minutes | work_ID + home_ID, df, vcov="hetero")
time2 <- proc.time() - base2

# style that i like
styledoc = style.tex( main = "aer",
  depvar.title = "Dependent Variable",
  model.title = "",
  fixef.suffix = " FE",
  yesNo = "Yes",
  signif.code = c("***"=0.01, "**"=0.05, "*"=0.10),
  stats.title = "\\midrule",
  fixef.title = ""
)

# variable labels
varlabel=c(flows = "Log(Flows)", 
       distance_Google_miles = "Log(Distance)",
       duration_minutes = "Log(Duration)",
       work_ID = "Destination",
       home_ID = "Home")

# output the table 
etable(est1, est2, tex=T, style.tex = styledoc, dict=varlabel, 
       extralines=list("-Command"=c("\\texttt{feols}", "\\texttt{feols}"),
                       "-Run Time"=c(time1[3], time2[3])), digits=3, 
       digits.stats = "r2", fitstat = c('n', 'r2'), 
       file="output/table_3_r.tex", replace=T)

