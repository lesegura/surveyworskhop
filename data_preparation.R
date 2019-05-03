#####################################################################################################
#                                                                                                   #
# The appended NSDUH 2002-2014 dataset can be downloaded from:                                      #
# https://www.datafiles.samhsa.gov/study-series/national-survey-drug-use-and-health-nsduh-nid13517  #
#                                                                                                   #
# Other individual years and pooled years of the NSDUH can be found in the link above. You can also #
# find the dataset in different formats (R, SAS, STATA, SPSS, ASCII, and delimited).                #
#                                                                                                   #
#####################################################################################################

######################################################
#                                                    #
# Load and prepare the dataset for years 2002-2014   #
#                                                    #
######################################################


load("/Users/luissegura/Dropbox/Survey Workshop/2019/Code/surveyworskhop/Example data/Raw/NSDUH_2002_2017.RData")
nsduh_02_17 <- CONCATPUF_0217_031919

rm(CONCATPUF_0217_031919) ### remove this object from the environment

names(nsduh_02_17) <- tolower(names(nsduh_02_17)) ### turning all variable names to low caps

str(nsduh_02_17) ### checking the structure of the dataset

str(nsduh_02_17$year) ##3 checkin the structure of the variable year

nsduh_02_17$year <- as.integer(nsduh_02_17$year) ### turning year to numeric

table(nsduh_02_17$year) ### checking

nsduh_02_17$year_i <- ifelse(nsduh_02_17$year < 2006, 0, 
                             ifelse(nsduh_02_17$year > 2007 & nsduh_02_17$year < 2012, 1, 
                                    NA)) ### creating an indicator of periods 2002 - 2005 and 2008 - 2011

table(nsduh_02_17$year, nsduh_02_17$year_i, useNA = "always") ### checking

var_names <- c("anal", "id", "vestr", "verep", "heryr", "newrace2", "iranlfy", 
               "age2", "income", "irsex", "pden", "anlyr", "mrjy") ### creating a vector with names we want to look for

### loop to look for the variable names in var_names
for(i in var_names){
  print(grep(paste(i), names(nsduh_02_17), value = T))
}

var_names <- c("analwc1", "analwc2", "analwc3", "analwc4", "analwc5",    
               "analwc6", "analwc7", "analwc8", "analwc9", "analwc10", 
               "analwc11", "analwc12", "analwc13", "analwc14", "analwc15", 
               "analwc16", "questid2", "vestr", "verep", "heryr", "newrace2", 
               "iranlfy", "age2", "income", "irsex", "pden00", "pden90", 
               "pden10", "anlyr", "mrjyr", "year", "year_i") ### updating the variable names


nsduh <- nsduh_02_17[,  var_names] ### subseting the dataset to the variables that we are going to use for our example

names(nsduh)

str(nsduh)

rm(nsduh_02_17) ### removing the bigger dataset from the environment


save(nsduh, file = "nsduh.RData") ### exporting it to an RData file
save.image(file = "data_worksapce.RData") ### saving the workspace




