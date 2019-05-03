#####################################################################################################
#                                                                                                   #
# Data for this project was obtained by appending each individual STATA dataset for the             #
# NSDUH years 2002-2005 & 2008-2011. These were provided in the 2018 version of this course.        #
#                                                                                                   #
#####################################################################################################

############################################
#                                          #
# Load and prepare the NSDUH 2002 dataset  #
#                                          #
############################################

rm(list = ls())

library(readstata13)
library(tidyverse)

setwd("/Users/luissegura/Dropbox/Survey Workshop/2018/EPIC COURSE/Data lab/") ### set the directory where the datasets are

nsduh_data_names <- list.files(pattern = "*.dta") ### assign the names of the dataset to a vector
str(nsduh_data_names)
nsduh_list <- list() ### create a list for all the datasets
nsduh_list_names <- list()



### loop to import the 8 nsduh datasets into a list called "nsduh_list" and transform variable names to low caps
for(i in 1:length(nsduh_data_names)){
  nsduh_list[[nsduh_data_names[i]]] <- read.dta13(nsduh_data_names[i],
                                         convert.factors = T)
  names(nsduh_list[[i]]) <- tolower(names(nsduh_list[[i]]))
  if(i < 5){
    nsduh_list[[i]][["year"]] <- i + 2001
  } else if(i > 4){
    nsduh_list[[i]][["year"]] <- i + 2003
  }
  nsduh_list[[i]][["realid"]] <- (nsduh_list[[i]][["year"]] * 1e5) + nsduh_list[[i]][["caseid"]]
  nsduh_list_names[[nsduh_data_names[i]]] <- names(nsduh_list[[i]])
  print(nsduh_list_names)
}

var_names <- c("caseid", "realid", "vestr", "verep", "year", "heryr", "anlyr", "mrjyr", "newrace2", 
               "iranlfy", "age2", "income", "irsex", "pden", "abodanl", "abodher", "anydrug", "analwt_c")

for(i in 1:length(nsduh_list)){
  nsduh_list[[i]] <- nsduh_list[[i]][var_names]
  print(names(nsduh_list[[i]]))
}

sapply(nsduh_list, str)


nsduh <- do.call(rbind, nsduh_list)

setwd("/Users/luissegura/Dropbox/Survey Workshop/2019/Code/surveyworskhop/")

rm(nsduh_list)

save(nsduh, file = "nsduh.RData")
save.image(file = "data.workspace.RData")


########################
#                      #
# Other useful code    #
#                      #
########################

# assign(nsduh_data_names[i], read.dta13(nsduh_data_names[i],
#                                        convert.factors = T)) 
# setdiff(bigdataframe, smalldataframe)
# 
# list2env(nsduh_list ,.GlobalEnv) ### unlist all dataframes into the environment
# 
