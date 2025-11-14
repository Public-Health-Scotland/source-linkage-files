# Calculate total length of stay

Calculate the total length of stay between `start_date` and `end_date`.
If the `end_date` is missing then use the dummy discharge date.

## Usage

``` r
calculate_stay(year, start_date, end_date, sc_qtr = NULL)
```

## Arguments

- year:

  The financial year in '1920' format

- start_date:

  The admission/start date variable. e.g. `record_keydate1`

- end_date:

  The discharge/end date variable. e.g. `record_keydate2`

- sc_qtr:

  The latest submitted quarter. e.g. `sc_latest_submission`

## Value

a [tibble](https://tibble.tidyverse.org/reference/tibble-package.html)
with additional variable `stay`. If there is no end date use dummy
discharge to calculate the total length of stay. If there is no end date
but sc_qtr is supplied then set this to the end of the quarter. If
quarter `end_date < start_date` and `sc_qtr` is supplied then set this
to the end of the next quarter.

## See also

Other date functions:
[`compute_mid_year_age()`](https://public-health-scotland.github.io/source-linkage-files/reference/compute_mid_year_age.md),
[`convert_date_to_numeric()`](https://public-health-scotland.github.io/source-linkage-files/reference/convert_date_to_numeric.md),
[`convert_numeric_to_date()`](https://public-health-scotland.github.io/source-linkage-files/reference/convert_numeric_to_date.md),
[`end_fy()`](https://public-health-scotland.github.io/source-linkage-files/reference/end_fy.md),
[`end_fy_quarter()`](https://public-health-scotland.github.io/source-linkage-files/reference/end_fy_quarter.md),
[`end_next_fy_quarter()`](https://public-health-scotland.github.io/source-linkage-files/reference/end_next_fy_quarter.md),
[`fy_interval()`](https://public-health-scotland.github.io/source-linkage-files/reference/fy_interval.md),
[`is_date_in_fyyear()`](https://public-health-scotland.github.io/source-linkage-files/reference/is_date_in_fyyear.md),
[`last_date_month()`](https://public-health-scotland.github.io/source-linkage-files/reference/last_date_month.md),
[`midpoint_fy()`](https://public-health-scotland.github.io/source-linkage-files/reference/midpoint_fy.md),
[`next_fy()`](https://public-health-scotland.github.io/source-linkage-files/reference/next_fy.md),
[`start_fy()`](https://public-health-scotland.github.io/source-linkage-files/reference/start_fy.md),
[`start_fy_quarter()`](https://public-health-scotland.github.io/source-linkage-files/reference/start_fy_quarter.md),
[`start_next_fy_quarter()`](https://public-health-scotland.github.io/source-linkage-files/reference/start_next_fy_quarter.md)
