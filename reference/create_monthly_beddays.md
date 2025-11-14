# Create Monthly Beddays

Generate counts of beddays per month for an episode with an admission
and discharge date

## Usage

``` r
create_monthly_beddays(
  data,
  year,
  admission_date,
  discharge_date,
  count_last = FALSE
)
```

## Arguments

- data:

  Data to calculate beddays for.

- year:

  The financial year in '1718' format.

- admission_date:

  The admission/start date variable.

- discharge_date:

  The admission/start date variable

- count_last:

  (default `FALSE`) - The first day be counted, instead of the last.

## Value

a [tibble](https://tibble.tidyverse.org/reference/tibble-package.html)
with additional variables `apr_beddays` to `mar_beddays` that count the
beddays which occurred in the month.

## See also

create_monthly_costs
