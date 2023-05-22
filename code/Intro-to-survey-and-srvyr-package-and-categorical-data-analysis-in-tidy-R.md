Intro to survey and srvyr package and categorical data analysis in tidy
R
================
Analysis of Complex Survey Data @episummer
2023-05-18

- <a href="#step-1-load-packages-and-dataset"
  id="toc-step-1-load-packages-and-dataset">Step 1: Load Packages and
  Dataset</a>
- <a href="#step-2-data-pre-processing"
  id="toc-step-2-data-pre-processing">Step 2: Data pre processing</a>
- <a href="#step-3-creating-a-survey-design-object"
  id="toc-step-3-creating-a-survey-design-object">Step 3: Creating a
  survey design object</a>
- <a href="#step-4-analyze-categorical-data"
  id="toc-step-4-analyze-categorical-data">Step 4: Analyze Categorical
  Data</a>

This rmarkdown file accompanies Video 10.1 as an introduction to analyze
categorical data from complex survey samples using tidy coding grammar.

### Step 1: Load Packages and Dataset

We will be using four packages in this session.

The package tidyverse is a collection of packages designed for data
science. All packages included in tidyverse share an underlying coding
grammar often called tidy. You can learn more about coding using tidy
language in the book R for Data Science by Hadley Wickham. An online
version can be found here: <https://r4ds.hadley.nz>

The package survey is an R package that provides functions to analyze
data from complex surveys. Documentation for this package can be found
here: <https://r-survey.r-forge.r-project.org/survey/>

The package srvyr allows to use tidy coding language using functions
from the package survey. You can read more about this here:
<http://gdfe.co/srvyr/>

We are going to use the dataset called NHANESraw that comes with the
NHANES package.

The NHANES is survey data collected by the US National Center for Health
Statistics (NCHS) which has conducted a series of health and nutrition
surveys since the early 1960’s. Since 1999 approximately 5,000
individuals of all ages are interviewed in their homes every year and
complete the health examination component of the survey. The NHANES
target population is “the non-institutionalized civilian resident
population of the United States”. The NHANES (National Health and
Nutrition Examination surveys) use complex survey designs (see
<http://www.cdc.gov/nchs/data/series/sr_02/sr02_162.pdf>) that
oversample certain subpopulations like racial minorities. Naive analysis
of the NHANES data can lead to mistaken conclusions. The NHANESraw
include 75 variables available for the 2009-2010 and 2011-2012 sample
years. NHANESraw has 20,293 observations of these variables plus four
additional variables that describe that sample weighting scheme
employed.

``` r
### Load libraries needed
library(tidyverse)
```

    ## ── Attaching packages ─────────────────────────────────────── tidyverse 1.3.2 ──
    ## ✔ ggplot2 3.4.2     ✔ purrr   1.0.1
    ## ✔ tibble  3.2.1     ✔ dplyr   1.1.1
    ## ✔ tidyr   1.3.0     ✔ stringr 1.5.0
    ## ✔ readr   2.1.4     ✔ forcats 1.0.0
    ## ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
    ## ✖ dplyr::filter() masks stats::filter()
    ## ✖ dplyr::lag()    masks stats::lag()

``` r
library(survey)
```

    ## Loading required package: grid
    ## Loading required package: Matrix
    ## 
    ## Attaching package: 'Matrix'
    ## 
    ## The following objects are masked from 'package:tidyr':
    ## 
    ##     expand, pack, unpack
    ## 
    ## Loading required package: survival
    ## 
    ## Attaching package: 'survey'
    ## 
    ## The following object is masked from 'package:graphics':
    ## 
    ##     dotchart

``` r
library(srvyr)
```

    ## 
    ## Attaching package: 'srvyr'
    ## 
    ## The following object is masked from 'package:stats':
    ## 
    ##     filter

``` r
library(NHANES)

### Load data
data("NHANESraw")
```

### Step 2: Data pre processing

We use the function glimpse() to explore the whole dataset.

``` r
### Explore the whole dataset
glimpse(NHANESraw)
```

    ## Rows: 20,293
    ## Columns: 78
    ## $ ID               <int> 51624, 51625, 51626, 51627, 51628, 51629, 51630, 5163…
    ## $ SurveyYr         <fct> 2009_10, 2009_10, 2009_10, 2009_10, 2009_10, 2009_10,…
    ## $ Gender           <fct> male, male, male, male, female, male, female, female,…
    ## $ Age              <int> 34, 4, 16, 10, 60, 26, 49, 1, 10, 80, 10, 80, 4, 35, …
    ## $ AgeMonths        <int> 409, 49, 202, 131, 722, 313, 596, 12, 124, NA, 121, N…
    ## $ Race1            <fct> White, Other, Black, Black, Black, Mexican, White, Wh…
    ## $ Race3            <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ Education        <fct> High School, NA, NA, NA, High School, 9 - 11th Grade,…
    ## $ MaritalStatus    <fct> Married, NA, NA, NA, Widowed, Married, LivePartner, N…
    ## $ HHIncome         <fct> 25000-34999, 20000-24999, 45000-54999, 20000-24999, 1…
    ## $ HHIncomeMid      <int> 30000, 22500, 50000, 22500, 12500, 30000, 40000, 4000…
    ## $ Poverty          <dbl> 1.36, 1.07, 2.27, 0.81, 0.69, 1.01, 1.91, 1.36, 2.68,…
    ## $ HomeRooms        <int> 6, 9, 5, 6, 6, 4, 5, 5, 7, 4, 5, 5, 7, NA, 6, 6, 5, 6…
    ## $ HomeOwn          <fct> Own, Own, Own, Rent, Rent, Rent, Rent, Rent, Own, Own…
    ## $ Work             <fct> NotWorking, NA, NotWorking, NA, NotWorking, Working, …
    ## $ Weight           <dbl> 87.4, 17.0, 72.3, 39.8, 116.8, 97.6, 86.7, 9.4, 26.0,…
    ## $ Length           <dbl> NA, NA, NA, NA, NA, NA, NA, 75.7, NA, NA, NA, NA, NA,…
    ## $ HeadCirc         <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ Height           <dbl> 164.7, 105.4, 181.3, 147.8, 166.0, 173.0, 168.4, NA, …
    ## $ BMI              <dbl> 32.22, 15.30, 22.00, 18.22, 42.39, 32.61, 30.57, NA, …
    ## $ BMICatUnder20yrs <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ BMI_WHO          <fct> 30.0_plus, 12.0_18.5, 18.5_to_24.9, 12.0_18.5, 30.0_p…
    ## $ Pulse            <int> 70, NA, 68, 68, 72, 72, 86, NA, 70, 88, 84, 54, NA, N…
    ## $ BPSysAve         <int> 113, NA, 109, 93, 150, 104, 112, NA, 108, 139, 94, 12…
    ## $ BPDiaAve         <int> 85, NA, 59, 41, 68, 49, 75, NA, 53, 43, 45, 60, NA, N…
    ## $ BPSys1           <int> 114, NA, 112, 92, 154, 102, 118, NA, 106, 142, 94, 12…
    ## $ BPDia1           <int> 88, NA, 62, 36, 70, 50, 82, NA, 60, 62, 38, 62, NA, N…
    ## $ BPSys2           <int> 114, NA, 114, 94, 150, 104, 108, NA, 106, 140, 92, 12…
    ## $ BPDia2           <int> 88, NA, 60, 44, 68, 48, 74, NA, 50, 46, 40, 62, NA, N…
    ## $ BPSys3           <int> 112, NA, 104, 92, 150, 104, 116, NA, 110, 138, 96, 11…
    ## $ BPDia3           <int> 82, NA, 58, 38, 68, 50, 76, NA, 56, 40, 50, 58, NA, N…
    ## $ Testosterone     <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ DirectChol       <dbl> 1.29, NA, 1.55, 1.89, 1.16, 1.16, 1.16, NA, 1.58, 1.9…
    ## $ TotChol          <dbl> 3.49, NA, 4.97, 4.16, 5.22, 4.14, 6.70, NA, 4.14, 4.7…
    ## $ UrineVol1        <int> 352, NA, 281, 139, 30, 202, 77, NA, 39, 128, 109, 38,…
    ## $ UrineFlow1       <dbl> NA, NA, 0.415, 1.078, 0.476, 0.563, 0.094, NA, 0.300,…
    ## $ UrineVol2        <int> NA, NA, NA, NA, 246, NA, NA, NA, NA, NA, NA, NA, NA, …
    ## $ UrineFlow2       <dbl> NA, NA, NA, NA, 2.51, NA, NA, NA, NA, NA, NA, NA, NA,…
    ## $ Diabetes         <fct> No, No, No, No, Yes, No, No, No, No, No, No, Yes, No,…
    ## $ DiabetesAge      <int> NA, NA, NA, NA, 56, NA, NA, NA, NA, NA, NA, 70, NA, N…
    ## $ HealthGen        <fct> Good, NA, Vgood, NA, Fair, Good, Good, NA, NA, Excell…
    ## $ DaysPhysHlthBad  <int> 0, NA, 2, NA, 20, 2, 0, NA, NA, 0, NA, 0, NA, NA, NA,…
    ## $ DaysMentHlthBad  <int> 15, NA, 0, NA, 25, 14, 10, NA, NA, 0, NA, 0, NA, NA, …
    ## $ LittleInterest   <fct> Most, NA, NA, NA, Most, None, Several, NA, NA, None, …
    ## $ Depressed        <fct> Several, NA, NA, NA, Most, Most, Several, NA, NA, Non…
    ## $ nPregnancies     <int> NA, NA, NA, NA, 1, NA, 2, NA, NA, NA, NA, NA, NA, NA,…
    ## $ nBabies          <int> NA, NA, NA, NA, 1, NA, 2, NA, NA, NA, NA, NA, NA, NA,…
    ## $ Age1stBaby       <int> NA, NA, NA, NA, NA, NA, 27, NA, NA, NA, NA, NA, NA, N…
    ## $ SleepHrsNight    <int> 4, NA, 8, NA, 4, 4, 8, NA, NA, 6, NA, 9, NA, 7, NA, N…
    ## $ SleepTrouble     <fct> Yes, NA, No, NA, No, No, Yes, NA, NA, No, NA, No, NA,…
    ## $ PhysActive       <fct> No, NA, Yes, NA, No, Yes, No, NA, NA, Yes, NA, No, NA…
    ## $ PhysActiveDays   <int> NA, NA, 5, NA, NA, 2, NA, NA, NA, 4, NA, NA, NA, NA, …
    ## $ TVHrsDay         <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ CompHrsDay       <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ TVHrsDayChild    <int> NA, 4, NA, 1, NA, NA, NA, NA, 1, NA, 3, NA, 2, NA, 5,…
    ## $ CompHrsDayChild  <int> NA, 1, NA, 1, NA, NA, NA, NA, 0, NA, 0, NA, 1, NA, 0,…
    ## $ Alcohol12PlusYr  <fct> Yes, NA, NA, NA, No, Yes, Yes, NA, NA, Yes, NA, No, N…
    ## $ AlcoholDay       <int> NA, NA, NA, NA, NA, 19, 2, NA, NA, 1, NA, NA, NA, NA,…
    ## $ AlcoholYear      <int> 0, NA, NA, NA, 0, 48, 20, NA, NA, 52, NA, 0, NA, NA, …
    ## $ SmokeNow         <fct> No, NA, NA, NA, Yes, No, Yes, NA, NA, No, NA, No, NA,…
    ## $ Smoke100         <fct> Yes, NA, NA, NA, Yes, Yes, Yes, NA, NA, Yes, NA, Yes,…
    ## $ SmokeAge         <int> 18, NA, NA, NA, 16, 15, 38, NA, NA, 16, NA, 21, NA, N…
    ## $ Marijuana        <fct> Yes, NA, NA, NA, NA, Yes, Yes, NA, NA, NA, NA, NA, NA…
    ## $ AgeFirstMarij    <int> 17, NA, NA, NA, NA, 10, 18, NA, NA, NA, NA, NA, NA, N…
    ## $ RegularMarij     <fct> No, NA, NA, NA, NA, Yes, No, NA, NA, NA, NA, NA, NA, …
    ## $ AgeRegMarij      <int> NA, NA, NA, NA, NA, 12, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ HardDrugs        <fct> Yes, NA, NA, NA, No, Yes, Yes, NA, NA, NA, NA, NA, NA…
    ## $ SexEver          <fct> Yes, NA, NA, NA, Yes, Yes, Yes, NA, NA, NA, NA, NA, N…
    ## $ SexAge           <int> 16, NA, NA, NA, 15, 9, 12, NA, NA, NA, NA, NA, NA, NA…
    ## $ SexNumPartnLife  <int> 8, NA, NA, NA, 4, 10, 10, NA, NA, NA, NA, NA, NA, NA,…
    ## $ SexNumPartYear   <int> 1, NA, NA, NA, NA, 1, 1, NA, NA, NA, NA, NA, NA, NA, …
    ## $ SameSex          <fct> No, NA, NA, NA, No, No, Yes, NA, NA, NA, NA, NA, NA, …
    ## $ SexOrientation   <fct> Heterosexual, NA, NA, NA, NA, Heterosexual, Heterosex…
    ## $ WTINT2YR         <dbl> 80100.544, 53901.104, 13953.078, 11664.899, 20090.339…
    ## $ WTMEC2YR         <dbl> 81528.772, 56995.035, 14509.279, 12041.635, 21000.339…
    ## $ SDMVPSU          <int> 1, 2, 1, 2, 2, 1, 2, 2, 2, 1, 1, 1, 2, 2, 1, 1, 1, 1,…
    ## $ SDMVSTRA         <int> 83, 79, 84, 86, 75, 88, 85, 86, 88, 77, 86, 79, 84, 7…
    ## $ PregnantNow      <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, U…

R is case sensitive. So, one of the things I recommend is to transform
all variable names to lower caps. This will prevent R throwing errors
because you mistyped a variable name.

``` r
### transform variable names to lower caps
NHANESraw <- NHANESraw |>
  janitor::clean_names()

### print dataset
NHANESraw
```

    ## # A tibble: 20,293 × 78
    ##       id survey_yr gender   age age_months race1  race3 education marital_status
    ##    <int> <fct>     <fct>  <int>      <int> <fct>  <fct> <fct>     <fct>         
    ##  1 51624 2009_10   male      34        409 White  <NA>  High Sch… Married       
    ##  2 51625 2009_10   male       4         49 Other  <NA>  <NA>      <NA>          
    ##  3 51626 2009_10   male      16        202 Black  <NA>  <NA>      <NA>          
    ##  4 51627 2009_10   male      10        131 Black  <NA>  <NA>      <NA>          
    ##  5 51628 2009_10   female    60        722 Black  <NA>  High Sch… Widowed       
    ##  6 51629 2009_10   male      26        313 Mexic… <NA>  9 - 11th… Married       
    ##  7 51630 2009_10   female    49        596 White  <NA>  Some Col… LivePartner   
    ##  8 51631 2009_10   female     1         12 White  <NA>  <NA>      <NA>          
    ##  9 51632 2009_10   male      10        124 Hispa… <NA>  <NA>      <NA>          
    ## 10 51633 2009_10   male      80         NA White  <NA>  Some Col… Married       
    ## # ℹ 20,283 more rows
    ## # ℹ 69 more variables: hh_income <fct>, hh_income_mid <int>, poverty <dbl>,
    ## #   home_rooms <int>, home_own <fct>, work <fct>, weight <dbl>, length <dbl>,
    ## #   head_circ <dbl>, height <dbl>, bmi <dbl>, bmi_cat_under20yrs <fct>,
    ## #   bmi_who <fct>, pulse <int>, bp_sys_ave <int>, bp_dia_ave <int>,
    ## #   bp_sys1 <int>, bp_dia1 <int>, bp_sys2 <int>, bp_dia2 <int>, bp_sys3 <int>,
    ## #   bp_dia3 <int>, testosterone <dbl>, direct_chol <dbl>, tot_chol <dbl>, …

The weights in the NHANES (wtmec2yr) were constructed assuming you have
2 years of data. However, we have 4 years of data. So, we are going to
modify the weights by dividing them by 2.

``` r
NHANESraw <- NHANESraw |> 
  mutate(new_wt = wtmec2yr / 2)
```

### Step 3: Creating a survey design object

Once your dataset is loaded and all variables you need are clean and
recoded create a survey design object

The survey design tells R what sampling design generated the data. The
survey design object for a complex sample has the following
information: - the data - weights (we are using the new weights we
created above) - strata - sample stages information

The NHANES has 4 sampling stages. However, we only need to declare the
first clustering stage (sdmvpsu).

``` r
nhanes_design <- NHANESraw |> 
  as_survey_design(strata = sdmvstra, 
                   id = sdmvpsu, 
                   weights = new_wt, 
                   nest = T)

nhanes_design
```

    ## Stratified 1 - level Cluster Sampling design (with replacement)
    ## With (62) clusters.
    ## Called via srvyr
    ## Sampling variables:
    ##  - ids: sdmvpsu
    ##  - strata: sdmvstra
    ##  - weights: new_wt
    ## Data variables: id (int), survey_yr (fct), gender (fct), age (int), age_months
    ##   (int), race1 (fct), race3 (fct), education (fct), marital_status (fct),
    ##   hh_income (fct), hh_income_mid (int), poverty (dbl), home_rooms (int),
    ##   home_own (fct), work (fct), weight (dbl), length (dbl), head_circ (dbl),
    ##   height (dbl), bmi (dbl), bmi_cat_under20yrs (fct), bmi_who (fct), pulse
    ##   (int), bp_sys_ave (int), bp_dia_ave (int), bp_sys1 (int), bp_dia1 (int),
    ##   bp_sys2 (int), bp_dia2 (int), bp_sys3 (int), bp_dia3 (int), testosterone
    ##   (dbl), direct_chol (dbl), tot_chol (dbl), urine_vol1 (int), urine_flow1
    ##   (dbl), urine_vol2 (int), urine_flow2 (dbl), diabetes (fct), diabetes_age
    ##   (int), health_gen (fct), days_phys_hlth_bad (int), days_ment_hlth_bad (int),
    ##   little_interest (fct), depressed (fct), n_pregnancies (int), n_babies (int),
    ##   age1st_baby (int), sleep_hrs_night (int), sleep_trouble (fct), phys_active
    ##   (fct), phys_active_days (int), tv_hrs_day (fct), comp_hrs_day (fct),
    ##   tv_hrs_day_child (int), comp_hrs_day_child (int), alcohol12plus_yr (fct),
    ##   alcohol_day (int), alcohol_year (int), smoke_now (fct), smoke100 (fct),
    ##   smoke_age (int), marijuana (fct), age_first_marij (int), regular_marij (fct),
    ##   age_reg_marij (int), hard_drugs (fct), sex_ever (fct), sex_age (int),
    ##   sex_num_partn_life (int), sex_num_part_year (int), same_sex (fct),
    ##   sex_orientation (fct), wtint2yr (dbl), wtmec2yr (dbl), sdmvpsu (int),
    ##   sdmvstra (int), pregnant_now (fct), new_wt (dbl)

### Step 4: Analyze Categorical Data

#### Exploring Categorical Data

##### Summarizing a categorical variable

We start by estimating the survey weighted frequencies of the variable
race.

``` r
race_tab <- nhanes_design |> 
  group_by(race1) |>
  summarise(freq = survey_total(), 
            prop = survey_prop() * 100) |>
  ### arrange table in descending order of prop
  arrange(desc(prop))

race_tab
```

    ## # A tibble: 5 × 5
    ##   race1          freq   freq_se  prop prop_se
    ##   <fct>         <dbl>     <dbl> <dbl>   <dbl>
    ## 1 White    193966274. 14939549. 63.7    2.64 
    ## 2 Black     37241616.  3195996. 12.2    1.28 
    ## 3 Mexican   30719158.  4239400. 10.1    1.56 
    ## 4 Other     23389002.  2270278.  7.69   0.738
    ## 5 Hispanic  18951150.  2885203.  6.23   1.00

Create a graph to visually examine the weighted distribution of race.

``` r
race_tab |>
  ggplot(aes(x = race1, y = prop)) + 
  geom_col() + 
  coord_flip() +
  scale_x_discrete(limits = race_tab$race1) + 
  xlab("") +
  ylab("%") +
  labs(title = "Survey-Weighted Race Distribution in the U.S.") +
  theme_classic()
```

![](Intro-to-survey-and-srvyr-package-and-categorical-data-analysis-in-tidy-R_files/figure-gfm/race%20graph-1.png)<!-- -->

##### Creating 2x2 tables

Suppose we are interested in the patterns of marijuana use by different
racial/ethnic groups.

We are going to create a 2x2 table of the weighted counts (frequencies)
of marijuana use by race and plot it.

``` r
mj_race_tab <- nhanes_design |>
  ### removing missings in the marijuana variable
  filter(!is.na(marijuana)) |>
  group_by(race1, marijuana) |>
  summarise(Freq = survey_total()) |>
  arrange(desc(marijuana))

mj_race_tab
```

    ## # A tibble: 10 × 4
    ## # Groups:   race1 [5]
    ##    race1    marijuana      Freq  Freq_se
    ##    <fct>    <fct>         <dbl>    <dbl>
    ##  1 Black    Yes       10281125. 1003805.
    ##  2 Hispanic Yes        3932857.  599802.
    ##  3 Mexican  Yes        5546273.  805596.
    ##  4 White    Yes       64414588. 5074528.
    ##  5 Other    Yes        4204466.  429334.
    ##  6 Black    No         7866513.  816261.
    ##  7 Hispanic No         5633062.  989714.
    ##  8 Mexican  No         8823639. 1303554.
    ##  9 White    No        33432309. 3082925.
    ## 10 Other    No         6806435.  820606.

We can visualize the table created using a stacked bar graph. Note that
the bar height corresponds to the total of the group.

``` r
mj_race_tab |> 
  ggplot(aes(x = race1, y = Freq, fill = marijuana)) +
  geom_col() + 
  coord_flip() + 
  xlab("Race group")
```

![](Intro-to-survey-and-srvyr-package-and-categorical-data-analysis-in-tidy-R_files/figure-gfm/mu%20by%20race%20plot-1.png)<!-- -->

We might be more interested in the survey weighted proportion marijuana
use by race group

``` r
mj_race_prop <- nhanes_design |>
  filter(!is.na(marijuana)) |>
  group_by(race1, marijuana) |>
  ### vartype = "ci" adds confidence intervals
  summarise(prop = survey_prop(vartype = "ci")) |>
  arrange(desc(marijuana), desc(prop))

mj_race_prop
```

    ## # A tibble: 10 × 5
    ## # Groups:   race1 [5]
    ##    race1    marijuana  prop prop_low prop_upp
    ##    <fct>    <fct>     <dbl>    <dbl>    <dbl>
    ##  1 White    Yes       0.658    0.623    0.693
    ##  2 Black    Yes       0.567    0.543    0.590
    ##  3 Hispanic Yes       0.411    0.354    0.469
    ##  4 Mexican  Yes       0.386    0.350    0.422
    ##  5 Other    Yes       0.382    0.317    0.447
    ##  6 Other    No        0.618    0.553    0.683
    ##  7 Mexican  No        0.614    0.578    0.650
    ##  8 Hispanic No        0.589    0.531    0.646
    ##  9 Black    No        0.433    0.410    0.457
    ## 10 White    No        0.342    0.307    0.377

Plotting the table above. Note that the height of the bar is equal to 1.

``` r
mj_race_prop |> 
  ggplot(aes(x = race1, y = prop, fill = marijuana)) + 
  geom_col() + 
  coord_flip() +
  ylab("Proportion") + 
  xlab("Race group")
```

![](Intro-to-survey-and-srvyr-package-and-categorical-data-analysis-in-tidy-R_files/figure-gfm/mu%20by%20race2%20plot2-1.png)<!-- -->

##### Hypothesis testing

We are going to run a Chi Square test of heterogeneity using the
function svychisq to see if there is any significant differences in
marijuana use between race groups.

``` r
svychisq(~race1 + marijuana, nhanes_design, statistic = "Chisq")
```

    ## 
    ##  Pearson's X^2: Rao & Scott adjustment
    ## 
    ## data:  NextMethod()
    ## X-squared = 1022.1, df = 4, p-value < 0.00000000000000022

##### Modeling categorical variables

Run a simple survey weighted logistic regression using the function
svyglm() from the survey package. We are going to use the function
tidy() from the broom package to tidy our model regression output. The
first argument of the svyglm() function is the outcome variable,
followed by the predictor variables. These should be written as a
formula, using the \~ sign to denote that you are regressing your
outcome on the predictors.

``` r
svyglm(marijuana ~ race1, design = nhanes_design, family = binomial(link = "logit")) |>
  ### exponentiate coefficients from logistic regression, get confidence intervals
  broom::tidy(exponentiate = T, conf.int = T)
```

    ## Warning in eval(family$initialize): non-integer #successes in a binomial glm!

    ## # A tibble: 5 × 7
    ##   term          estimate std.error statistic       p.value conf.low conf.high
    ##   <chr>            <dbl>     <dbl>     <dbl>         <dbl>    <dbl>     <dbl>
    ## 1 (Intercept)      1.31     0.0471      5.69 0.00000377       1.19      1.44 
    ## 2 race1Hispanic    0.534    0.101      -6.22 0.000000878      0.435     0.657
    ## 3 race1Mexican     0.481    0.0829     -8.83 0.00000000102    0.406     0.570
    ## 4 race1White       1.47     0.0897      4.32 0.000165         1.23      1.77 
    ## 5 race1Other       0.473    0.146      -5.15 0.0000167        0.351     0.637

The output from the svyglm is a table with regression coefficients. Here
the coefficients are exponentiated into Odds Ratios, because we set the
option exponentiated to TRUE in the function tidy(). You can set it to
FALSE to obtain the log odds instead.

You can specify different distributions in the function svyglm by
changing family to poisson to fit a poisson model, gaussian to fit a
linear regression, etc.

Another thing I want you to notice is the warning message that R threw
at us. Do not panic, glm is just picky when it comes to specifying
binomial (and Poisson) models. It warns if it detects that the number of
trials or successes is non-integral, but it goes ahead and fits the
model anyway. If you want to suppress the warning (and you’re sure it’s
not a problem), use family = quasibinomial(link = “logit”) instead.

We can add independent variables to the logistic regression model with
a + sign to run a multivariable logistic regression

``` r
svyglm(marijuana ~ race1 + gender, design = nhanes_design, family = binomial(link = "logit")) |>
  broom::tidy(exponentiate = T, conf.int = T)
```

    ## Warning in eval(family$initialize): non-integer #successes in a binomial glm!

    ## # A tibble: 6 × 7
    ##   term          estimate std.error statistic  p.value conf.low conf.high
    ##   <chr>            <dbl>     <dbl>     <dbl>    <dbl>    <dbl>     <dbl>
    ## 1 (Intercept)      1.08     0.0491      1.50 1.46e- 1    0.973     1.19 
    ## 2 race1Hispanic    0.521    0.104      -6.25 9.33e- 7    0.420     0.645
    ## 3 race1Mexican     0.457    0.0878     -8.92 1.14e- 9    0.382     0.547
    ## 4 race1White       1.45     0.0911      4.07 3.48e- 4    1.20      1.75 
    ## 5 race1Other       0.461    0.149      -5.19 1.66e- 5    0.340     0.626
    ## 6 gendermale       1.53     0.0476      8.97 9.91e-10    1.39      1.69

And add an interaction term between race and gender with the \* sign.
Notice that in R you don’t have to put the main effects when adding
interactions.

``` r
### logistic regression with main effects and interaction between race1 and gender (race1 * gender)
svyglm(marijuana ~ race1 + gender + race1 * gender, design = nhanes_design, family = binomial(link = "logit")) |>
  broom::tidy(exponentiate = T, conf.int = T)
```

    ## Warning in eval(family$initialize): non-integer #successes in a binomial glm!

    ## # A tibble: 10 × 7
    ##    term                  estimate std.error statistic p.value conf.low conf.high
    ##    <chr>                    <dbl>     <dbl>     <dbl>   <dbl>    <dbl>     <dbl>
    ##  1 (Intercept)              0.949    0.0692   -0.758  4.56e-1    0.823     1.09 
    ##  2 race1Hispanic            0.494    0.125    -5.66   7.92e-6    0.382     0.639
    ##  3 race1Mexican             0.439    0.126    -6.55   9.05e-7    0.339     0.569
    ##  4 race1White               1.74     0.0967    5.74   6.50e-6    1.43      2.13 
    ##  5 race1Other               0.552    0.234    -2.54   1.81e-2    0.340     0.895
    ##  6 gendermale               2.04     0.140     5.10   3.26e-5    1.53      2.72 
    ##  7 race1Hispanic:gender…    1.05     0.194     0.264  7.94e-1    0.705     1.57 
    ##  8 race1Mexican:genderm…    0.994    0.185    -0.0324 9.74e-1    0.678     1.46 
    ##  9 race1White:gendermale    0.666    0.161    -2.52   1.87e-2    0.478     0.929
    ## 10 race1Other:gendermale    0.677    0.286    -1.36   1.87e-1    0.375     1.22

``` r
### The model above with main effects is exactly the same as the following model with just the interaction term (without the main effects)
### logistic regression with only an interaction between race1 and gender (race1 * gender)
svyglm(marijuana ~ race1 * gender, design = nhanes_design, family = binomial(link = "logit")) |>
  broom::tidy(exponentiate = T, conf.int = T)
```

    ## Warning in eval(family$initialize): non-integer #successes in a binomial glm!

    ## # A tibble: 10 × 7
    ##    term                  estimate std.error statistic p.value conf.low conf.high
    ##    <chr>                    <dbl>     <dbl>     <dbl>   <dbl>    <dbl>     <dbl>
    ##  1 (Intercept)              0.949    0.0692   -0.758  4.56e-1    0.823     1.09 
    ##  2 race1Hispanic            0.494    0.125    -5.66   7.92e-6    0.382     0.639
    ##  3 race1Mexican             0.439    0.126    -6.55   9.05e-7    0.339     0.569
    ##  4 race1White               1.74     0.0967    5.74   6.50e-6    1.43      2.13 
    ##  5 race1Other               0.552    0.234    -2.54   1.81e-2    0.340     0.895
    ##  6 gendermale               2.04     0.140     5.10   3.26e-5    1.53      2.72 
    ##  7 race1Hispanic:gender…    1.05     0.194     0.264  7.94e-1    0.705     1.57 
    ##  8 race1Mexican:genderm…    0.994    0.185    -0.0324 9.74e-1    0.678     1.46 
    ##  9 race1White:gendermale    0.666    0.161    -2.52   1.87e-2    0.478     0.929
    ## 10 race1Other:gendermale    0.677    0.286    -1.36   1.87e-1    0.375     1.22
