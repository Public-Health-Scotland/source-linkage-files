# Add smrtype variable based on record ID

Add smrtype variable based on record ID

## Usage

``` r
add_smrtype(
  recid,
  mpat = NULL,
  ipdc = NULL,
  hc_service = NULL,
  main_applicant_flag = NULL,
  consultation_type = NULL
)
```

## Arguments

- recid:

  A vector of record IDs

- mpat:

  A vector of management of patient values

- ipdc:

  A vector of inpatient/day case markers

- hc_service:

  A vector of Home Care service markers

- main_applicant_flag:

  A vector of Homelessness applicant flags

- consultation_type:

  A vector of GP Out of hours consultation types

## Value

A vector of `smrtype`
