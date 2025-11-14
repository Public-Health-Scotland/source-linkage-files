# Create the Person ID variable

Creates the Person ID, this depends on the data set used

- Social Care - uses the `sending_location` code and the client's
  `social_care_id`

## Usage

``` r
create_person_id(data, type = c("SC"))
```

## Arguments

- data:

  the data containing the variables to compute the person id from

- type:

  the dataset type to use to create the ID options are:

  - 'SC' (Social Care)

## Value

The data with the `person_id` variable added
