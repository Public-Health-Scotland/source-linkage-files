# Process the cost lookup files

This takes a `file_name` which must be in the `Rmarkdown/` directory it
will quietly render the `.Rmd` file with
[`rmarkdown::render()`](https://pkgs.rstudio.com/rmarkdown/reference/render.html)
and try to open the rendered html doc.

## Usage

``` r
process_costs_rmd(file_name)
```

## Arguments

- file_name:

  Rmd file to process
