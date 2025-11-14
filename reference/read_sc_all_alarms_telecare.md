# Read Social Care Alarms Telecare data

Read Social Care Alarms Telecare data

## Usage

``` r
read_sc_all_alarms_telecare(
  sc_dvprod_connection = phs_db_connection(dsn = "DVPROD")
)
```

## Arguments

- sc_dvprod_connection:

  Connection to the SC platform

## Value

an extract of the data as a
[tibble](https://tibble.tidyverse.org/reference/tibble-package.html).
