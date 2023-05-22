ICC example in tidy R
================
Analysis of Complex Survey Data @episummer
2023-05-18

- <a
  href="#r-markdown-demonstration-on-calculating-the-intraclass-correlation-coefficient-icc"
  id="toc-r-markdown-demonstration-on-calculating-the-intraclass-correlation-coefficient-icc">R
  Markdown demonstration on calculating the Intraclass Correlation
  Coefficient (ICC)</a>
  - <a href="#step-1-load-packages-and-dataset"
    id="toc-step-1-load-packages-and-dataset">Step 1: Load Packages and
    Dataset</a>
  - <a href="#step-2-explore-the-clustering-variable-of-school-district"
    id="toc-step-2-explore-the-clustering-variable-of-school-district">Step
    2: Explore the clustering variable of school district</a>
  - <a href="#step-3-calculating-the-icc"
    id="toc-step-3-calculating-the-icc">Step 3: Calculating the ICC</a>

## R Markdown demonstration on calculating the Intraclass Correlation Coefficient (ICC)

This Rmarkdown file accompanies Video 7 on how to compute the ICC. The
ICC is one way we can assess the degree of correlation between
individuals within a cluster.

Remember the ICC = Between cluster variance / Total variance

An ICC = 1 suggests high correlation within cluster, that is most of the
variance is explained by the cluster. On the other hand, an ICC = 0
suggests low correlation within cluster, that is less variance is
explained by the cluster.

### Step 1: Load Packages and Dataset

We will use two packages for this session.

The package tidyverse is a collection of packages designed for data
science. All packages included in tidyverse share an underlying coding
grammar often called tidy. You can learn more about coding using tidy
language in the book R for Data Science by Hadley Wickham. An online
version can be found here: <https://r4ds.hadley.nz>

The package survey is an R package that provides functions to analyze
data from complex surveys. Documentation for this package can be found
here: <https://r-survey.r-forge.r-project.org/survey/>

We are going to use the dataset called apiclus2 that comes with the
survey package. The dataset “apiclus2” is a dataset of schools within
districts in California.

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
### Load data
data(api) 
```

### Step 2: Explore the clustering variable of school district

We use the function glimpse() to explore the whole dataset.

For this example, we will use the following variables: - api00: Academic
Performance Index in 2000  
- dname: district name - dnum: district number

``` r
### Explore the whole dataset
glimpse(apiclus2)
```

    ## Rows: 126
    ## Columns: 40
    ## $ cds      <chr> "31667796031017", "55751846054837", "41688746043517", "416887…
    ## $ stype    <fct> E, E, E, M, E, E, E, E, M, H, E, M, E, E, E, E, H, E, E, M, E…
    ## $ name     <chr> "Alta-Dutch Flat", "Tenaya Elementa", "Panorama Elemen", "Lip…
    ## $ sname    <chr> "Alta-Dutch Flat Elementary", "Tenaya Elementary", "Panorama …
    ## $ snum     <dbl> 3269, 5979, 4958, 4957, 4956, 4915, 2548, 2550, 2549, 348, 34…
    ## $ dname    <chr> "Alta-Dutch Flat Elem", "Big Oak Flat-Grvlnd Unif", "Brisbane…
    ## $ dnum     <int> 15, 63, 83, 83, 83, 117, 132, 132, 132, 152, 152, 152, 173, 1…
    ## $ cname    <chr> "Placer", "Tuolumne", "San Mateo", "San Mateo", "San Mateo", …
    ## $ cnum     <int> 30, 54, 40, 40, 40, 39, 19, 19, 19, 5, 5, 5, 36, 36, 36, 36, …
    ## $ flag     <int> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ pcttest  <int> 100, 100, 98, 100, 98, 100, 100, 100, 100, 96, 98, 100, 100, …
    ## $ api00    <int> 821, 773, 600, 740, 716, 811, 472, 520, 568, 591, 544, 612, 9…
    ## $ api99    <int> 785, 718, 632, 740, 711, 779, 432, 494, 589, 585, 554, 583, 9…
    ## $ target   <int> 1, 4, 8, 3, 4, 1, 18, 15, 11, 11, 12, 11, NA, NA, NA, NA, 18,…
    ## $ growth   <int> 36, 55, -32, 0, 5, 32, 40, 26, -21, 6, -10, 29, 14, 2, 30, -5…
    ## $ sch.wide <fct> Yes, Yes, No, No, Yes, Yes, Yes, Yes, No, No, No, Yes, Yes, Y…
    ## $ comp.imp <fct> Yes, Yes, No, No, Yes, Yes, Yes, Yes, No, No, No, Yes, Yes, Y…
    ## $ both     <fct> Yes, Yes, No, No, Yes, Yes, Yes, Yes, No, No, No, Yes, Yes, Y…
    ## $ awards   <fct> Yes, Yes, No, No, Yes, Yes, Yes, Yes, No, No, No, Yes, Yes, Y…
    ## $ meals    <int> 27, 43, 33, 11, 5, 25, 78, 76, 68, 42, 63, 54, 0, 4, 1, 6, 47…
    ## $ ell      <int> 0, 0, 5, 4, 2, 5, 38, 34, 34, 23, 42, 24, 3, 6, 2, 1, 37, 14,…
    ## $ yr.rnd   <fct> No, No, No, No, No, No, No, No, No, No, No, No, No, No, No, N…
    ## $ mobility <int> 14, 12, 9, 8, 6, 19, 13, 13, 15, 4, 15, 15, 24, 19, 14, 14, 7…
    ## $ acs.k3   <int> 17, 18, 19, NA, 18, 20, 19, 25, NA, NA, 20, NA, 19, 18, 19, 1…
    ## $ acs.46   <int> 20, 34, 29, 30, 28, 22, NA, 23, 24, NA, NA, 27, 27, 25, 27, 2…
    ## $ acs.core <int> NA, NA, NA, 24, NA, 31, NA, NA, 25, 21, NA, 18, NA, NA, NA, N…
    ## $ pct.resp <int> 89, 98, 79, 96, 98, 93, 100, 46, 91, 94, 93, 88, 90, 99, 0, 8…
    ## $ not.hsg  <int> 4, 8, 8, 5, 3, 5, 48, 30, 63, 20, 29, 27, 0, 1, 0, 1, 50, 24,…
    ## $ hsg      <int> 16, 33, 28, 27, 14, 9, 32, 27, 16, 18, 32, 25, 0, 7, 0, 5, 21…
    ## $ some.col <int> 53, 37, 30, 35, 22, 30, 15, 21, 13, 27, 26, 24, 4, 8, 0, 8, 1…
    ## $ col.grad <int> 21, 15, 32, 27, 58, 37, 4, 13, 6, 28, 7, 18, 51, 42, 0, 42, 1…
    ## $ grad.sch <int> 6, 7, 1, 6, 3, 19, 1, 9, 2, 7, 6, 7, 44, 41, 100, 45, 1, 6, 3…
    ## $ avg.ed   <dbl> 3.07, 2.79, 2.90, 3.03, 3.44, 3.56, 1.77, 2.42, 1.68, 2.84, 2…
    ## $ full     <int> 100, 100, 100, 82, 100, 94, 96, 86, 75, 100, 100, 97, 100, 10…
    ## $ emer     <int> 0, 0, 0, 18, 8, 6, 8, 24, 21, 4, 4, 3, 0, 4, 0, 4, 28, 18, 11…
    ## $ enroll   <int> 152, 312, 173, 201, 147, 234, 184, 512, 543, 332, 217, 520, 5…
    ## $ api.stu  <int> 120, 270, 151, 179, 136, 189, 158, 419, 423, 303, 182, 438, 4…
    ## $ pw       <dbl> 18.925, 18.925, 18.925, 18.925, 18.925, 18.925, 18.925, 18.92…
    ## $ fpc1     <dbl> 757, 757, 757, 757, 757, 757, 757, 757, 757, 757, 757, 757, 7…
    ## $ fpc2     <int[1d]> <array[26]>

``` r
### How many schools are within school district?
apiclus2 |>
  group_by(dname) %>%
  count() %>%
  print(n = Inf)
```

    ## # A tibble: 40 × 2
    ## # Groups:   dname [40]
    ##    dname                         n
    ##    <chr>                     <int>
    ##  1 Alta-Dutch Flat Elem          1
    ##  2 Big Oak Flat-Grvlnd Unif      1
    ##  3 Brisbane Elementary           3
    ##  4 Cayucos Elementary            1
    ##  5 Chowchilla Elementary         3
    ##  6 Colusa Unified                3
    ##  7 Del Mar Union Elementary      4
    ##  8 Delano Joint Union High       1
    ##  9 Eastside Union Elem           4
    ## 10 El Centro Elementary          5
    ## 11 Fairfax Elementary            2
    ## 12 Geyserville Unified           1
    ## 13 Healdsburg Unified            5
    ## 14 Hillsborough City Elem        4
    ## 15 Los Gatos Union Elem          5
    ## 16 Mojave Unified                4
    ## 17 Montague Elementary           1
    ## 18 Natomas Unified               5
    ## 19 Oroville Union High           2
    ## 20 Palo Verde Unified            5
    ## 21 Piedmont City Unified         5
    ## 22 Pioneer Union Elem (Char)     2
    ## 23 Pomona Unified                5
    ## 24 Potter Valley Community       1
    ## 25 Poway Unified                 5
    ## 26 Rincon Valley Union Elem      5
    ## 27 Sacramento City Unified       5
    ## 28 San Lorenzo Unified           5
    ## 29 San Lorenzo Valley Unif       5
    ## 30 Sebastopol Union Elem         2
    ## 31 Sequoia Union High            4
    ## 32 Sierra-Plumas Jt. Unified     3
    ## 33 South Bay Elementary          2
    ## 34 Spreckels Union Elem          2
    ## 35 Strathmore Union High         1
    ## 36 Sylvan Union Elementary       5
    ## 37 Three Rivers Union Elem       1
    ## 38 Valle Lindo Elementary        2
    ## 39 Walnut Creek Elementary       5
    ## 40 Weed Union Elementary         1

### Step 3: Calculating the ICC

We learned in class that we can assess the effect of clustering by
calculating the ICC.

#### Fit a linear regression

First, we fit a linear model with the group variable as the exposure or
independent variable.

``` r
### Linear model
model <- lm(api00 ~ as.factor(dname), data = apiclus2)
```

#### Obtain the variances from the linear model

Second, from this model we obtain the anova table.

In this table, Sum Sq of the exposure variable is the variance between
groups. Sum Sq of the residuals is the variance not explained by the
groups. The sum of both is the total variance.

``` r
### anova table from the model.
model_anova <- anova(model) |>
  broom::tidy()

### print results
model_anova 
```

    ## # A tibble: 2 × 6
    ##   term                df    sumsq meansq statistic   p.value
    ##   <chr>            <int>    <dbl>  <dbl>     <dbl>     <dbl>
    ## 1 as.factor(dname)    39 2028811. 52021.      20.3  1.64e-29
    ## 2 Residuals           86  220740.  2567.      NA   NA

#### Calculate the ICC

Third, calculate the ICC.

Now we have the elements to calculate the ICC: the between cluster
variance and the total variance.

Calculate the total variance by summing the sum of squares of the
clustering variable and the residuals. Save the results in an object
called total_var.

``` r
### calculate total variance
total_var <- model_anova |>
  summarise(total_var = sum(sumsq))
```

The total variance is 2249551.4285714

Then save the variance between clusters in an object called cluster_var

``` r
### extract variance between clusters
cluster_var <- model_anova |>
  filter(term == "as.factor(dname)") |>
  select(sumsq)
```

The between cluster variance is 2028810.9785714

Divide the between cluster variance over the total variance to obtain
the ICC.

``` r
### calculate the ICC by dividing the between group variance by the total variance.
icc_estimate <- cluster_var / total_var 
```

We obtain an ICC of 0.9018736, meaning that 90% of the variability in
Academic Performance Index is explained by differences between school
districts–between groups.
