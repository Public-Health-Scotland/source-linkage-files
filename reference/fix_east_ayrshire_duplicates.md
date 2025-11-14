# Fix the East Ayrshire duplicates - Homelessness

Takes the homelessness data and filters out the East Ayrshire duplicates
where one has an app_number e.g. "ABC12345" and another has
"ABC/12/345". It first modifies IDs of this type and then filters where
this 'creates' a duplicate. The IDs with the `/` are more common so we
add these rather than remove them.

## Usage

``` r
fix_east_ayrshire_duplicates(data)
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
