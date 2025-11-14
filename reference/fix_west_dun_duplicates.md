# Fix the West Dunbartonshire duplicates - Homelessness

Takes the homelessness data and filters out the West Dun duplicates
where one has an app_number e.g. "ABC123" and another has "00ABC123". It
first modifies IDs of this type and then filters where this 'creates' a
duplicate.

## Usage

``` r
fix_west_dun_duplicates(data)
```

## Arguments

- data:

  the homelessness data - It must contain the
  `sending_local_authority_name`, `application_reference_number`,
  `client_unique_identifier`, `assessment_decision_date` and
  `case_closed_date`.

## Value

The fixed data

## See also

process_homelessness_extract
