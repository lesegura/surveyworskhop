  library(survey)
  
  names(nsduh)

  dclus <- svydesign(id = ~verep, strata = ~vestr, weights = ~analwc4, data = nsduh, nest = TRUE)
  
  ftable(svyby(~heryr, ~as.factor(year_i), dclus, svymean, na.rm = TRUE))
  
  svyby(~heryr, ~as.factor(year_i), dclus, svymean, na.rm = TRUE)
  
  