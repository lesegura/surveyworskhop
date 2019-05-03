
### Loading dataset NSDUH 2002 - 2011
load("/Users/luissegura/Dropbox/Survey Workshop/2019/Code/surveyworskhop/Example data/For use in class/nsduh.RData")

### Create a new and recoded variable of race
table(nsduh$newrace2) ### checking original variable

### creating a new race variable and recoding 1 = Whites, 2 = Blacks, 3 = Hispanics, 4 = Other
nsduh$race <- ifelse(nsduh$newrace2 == 3 |  nsduh$newrace2 == 5 | nsduh$newrace2 == 6, 4, 
                     ifelse(nsduh$newrace2 == 7, 3, nsduh$newrace2)) 

table(nsduh$newrace2, nsduh$race, useNA = "always") ### checking

### Create a new variable “frequency of use of prescription opioids”
table(nsduh$iranlfy) ### checking original variable

### Creating a new variable of frequency of NMUPO 0 = no use, 1 = 1-29 days, 2 = 30 - 99 days, 3 = 100 - 365 days
nsduh$freq_nmupo <- ifelse(nsduh$iranlfy == -9, NA, 
                           ifelse(nsduh$iranlfy < 30, 1, 
                                  ifelse(nsduh$iranlfy > 29 & nsduh$iranlfy < 100, 2, 
                                         ifelse(nsduh$iranlfy > 99 &  nsduh$iranlfy < 366, 3, 0))))

table(nsduh$freq_nmupo, useNA = "always") ### checking new variable

table(nsduh$iranlfy, nsduh$freq_nmupo, useNA = "always") ### checking

### Create a new age variable
table(nsduh$age2, useNA = "always") ### checking original variable

nsduh$age <- ifelse(nsduh$age2 < 13, 1, 2) ### creating a new variable of age 1 = 12 - 25 years, 2 = 26+ years

table(nsduh$age2, nsduh$age, useNA = "always") ### checking

