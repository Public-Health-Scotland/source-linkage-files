# 04 Package Development

## Background

The Source Linkage Files (SLFs) project was created using SPSS syntax
until March 2022 when this was transformed into R programming language.
The project has evolved into it’s own R package called `createslf` which
contains functions for maintaining the Reproducible Analytical Pipeline
(RAP) to create the SLFs on a quarterly basis.

The package bundles together code, data, documentation, and tests, and
is easy to share with others. To create the package `createslf` we refer
to the [R Packages](https://r-pkgs.org/introduction.html) guide by
Hadley Wickham.

This package is intended to be in continuous development to support the
quarterly update process of the SLFs which takes place each March, June,
September and December.

## Developing createslf - setup

The `createslf` package has a clear structure for development. There are
a few important features which are essential for the setup of the
package:

- **README.md** - Readme file contains important information about the
  package.
- **R/ directory** - Main development folder where all functions are
  stored. See the
  [article](https://public-health-scotland.github.io/source-linkage-files/articles/R%20Project%20Structure.html)
  for more information on function setup.
- **DESCRIPTION file** - The **DESCRIPTION** file provides overall
  metadata about the package, such as the package name and which other
  packages it depends on.
- **NAMESPACE file** - The **NAMESPACE** file specifies which functions
  the package makes available for others to use and, optionally, imports
  functions from other packages. This file is generated automatically
  when the package is build and should not be edited by hand. Changes
  should be made on individual functions by editing the roxygen2
  documentation.
- **man/** - Documentation is stored in the **man/** directory. The
  documentation files are generated automatically when the package is
  build and should not be edited by hand. Changes should be made on
  individual functions by editing the roxygen2 documentaiton.
- **tests/** - Package tests are stored in the **tests/** directory.
  Testing is a vital part of package development as it ensures that our
  code is working. Testing, however, adds an additional step to the
  workflow. See chapter [testing
  basics](https://r-pkgs.org/testing-basics.html) for more info on
  package tests. Please note, this **tests/** directory is completely
  separate to SLF quarterly tests and is intented to test the functions
  within the `createslf` package.

### Developing a new function - Best Practice:

- All function names should be in lower case, with words separated by an
  underscore
- Put a space after a comma, never before
- Put a space before and after infix operators such as \<-, == and +
- Limit code to 80 characters per line
- Function documentation should be generated using roxygen2
- Functions should be tested using testthat where possible
- The package should always pass devtools::check()

## Documentation

Function documentation is important for maintaining the package
`createslf`. For Hadley Wickham’s guide see this
[chapter](https://r-pkgs.org/man.html) on documentation.

In summary, documentation is important for each function as this is
where users will use the help page to search with `?XXXfunction`.

The package `createslf` uses roxygen2 format for documenting functions.
Here are some of the advantages:

- Code and documentation are co-located. When you modify your code, it’s
  easy to remember to also update your documentation.

- You can use markdown, rather than having to learn a one-off markup
  language that only applies to `.Rd` files. In addition to formatting,
  the automatic hyperlinking functionality makes it much, much easier to
  create richly linked documentation.

- There’s a lot of `.Rd` boilerplate that’s automated away.

- roxygen2 provides a number of tools for sharing content across
  documentation topics and even between topics and vignettes.

*Documentation example:*

The function below comes from **00-update_refs** and simply returns the
delayed discharges period for the update as a `STRING`. This is used in
the set up of functions, allowing the correct path to the latest delayed
discharges extract. The *roxygen2* documentation is well documented
with:

- **Title** - Title of function

- **Description** - Brief description of the functions purpose.

- **Return** - What should the function return?

- **export** - Include to export this during the package load.

- **family** - Groups similar functions together.

As this function is already documented, a `.Rd` file will exist in the
**man/** folder. However, if there were any changes to this function or
if the documentation was updated, the `.Rd` file would also need to be
updated. To do this, you can run `devtools::document()` to generate (or
update) the package’s .Rd files. The `.Rd` files should not be edited by
hand and should be done by running `devtools::document()`.

``` r
#' Delayed Discharge period
#'
#' @description Get the period for Delayed Discharge
#'
#' @return The period for the Delayed Discharge file
#' as MMMYY_MMMYY
#' @export
#'
#' @family initialisation
get_dd_period <- function() {
  first_part <- substr(previous_update(), 1, 3)
  end_part <- substr(previous_update(), 7, 8)

  dd_period <- as.character(stringr::str_glue("Jul16_{first_part}{end_part}"))

  return(dd_period)
}
```

## Checking an R package - R CMD check

Base R provides various command line tools and R CMD check is the
official method for checking that an R package is valid. It is essential
to pass R CMD check if you plan to submit your package to CRAN, but we
highly recommend holding yourself to this standard even if you don’t
intend to release your package on CRAN. R CMD check detects many common
problems that you’d otherwise discover the hard way.

Our recommended way to run R CMD check is in the R console via devtools:

`devtools::check()`

We recommend this because it allows you to run R CMD check from within
R, which dramatically reduces friction and increases the likelihood that
you will `check()` early and often! This emphasis on fluidity and fast
feedback is exactly the same motivation as given for `load_all()`. In
the case of check(), it really is executing R CMD check for you. It’s
not just a high fidelity simulation, which is the case for `load_all()`.

## Workflows

The workflow for checking a package is simple, but tedious:

- Run `devtools::check()`, or press `Ctrl/Cmd + Shift + E`.

- Fix the first problem.

- Repeat until there are no more problems.

- R CMD check returns three types of messages:

- **ERRORs:** Severe problems that you should fix regardless of whether
  or not you’re submitting to CRAN.

- **WARNINGs:** Likely problems that you must fix if you’re planning to
  submit to CRAN (and a good idea to look into even if you’re not).

- **NOTEs:** Mild problems or, in a few cases, just an observation. If
  you are submitting to CRAN, you should strive to eliminate all NOTEs,
  even if they are false positives. If you have no NOTEs, human
  intervention is not required, and the package submission process will
  be easier. If it’s not possible to eliminate a NOTE, you’ll need
  describe why it’s OK in your submission comments, as described in
  Section 22.7. If you’re not submitting to CRAN, carefully read each
  NOTE. If it’s easy to eliminate the NOTEs, it’s worth it, so that you
  can continue to strive for a totally clean result. But if eliminating
  a NOTE will have a net negative impact on your package, it is
  reasonable to just tolerate it. Make sure that doesn’t lead to you
  ignoring other issues that really should be addressed.

## Testing the package

Testing is a vital part of developing the `createslf` as it ensures that
the code does what we want. Testing, however, adds an additional step to
the workflow. Please see this
[chapter](https://r-pkgs.org/testing-basics.html) for more information
on setting up tests.

`createslf` tests sit on the `tests/testthat/` directory. To set up a
new test you can run `usethis::use_test()` to create a new test file.

To test the file run: `testthat::test_file("tests/testthat/test-XXX.R")`

### Expectations

An expectation is the finest level of testing. It makes a binary
assertion about whether or not an object has the properties you expect.
This object is usually the return value from a function in your package.

All expectations have a similar structure:

- They start with `expect_`.

- They have two main arguments: the first is the actual result, the
  second is what you expect.

- If the actual and expected results don’t agree, testthat throws an
  error.

- Some expectations have additional arguments that control the finer
  points of comparing an actual and expected result.

An example of one of our tests is to check that the `convert_ca_to_lca`
function is working correctly and returns the correct lca code.

``` r
library(testthat)
library(createslf)
#> 
#> Attaching package: 'createslf'
#> The following object is masked _by_ '.GlobalEnv':
#> 
#>     get_dd_period

test_that("Can convert ca code to lca code", {
  ca <- c(
    "S12000033",
    "S12000049",
    "S12000048",
    NA,
    "S12345678"
  )

  expect_equal(
    convert_ca_to_lca(ca),
    c(
      "01",
      "17",
      "25",
      NA,
      NA
    )
  )
})
#> Test passed with 1 success 🥇.
```
