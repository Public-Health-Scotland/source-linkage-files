# Read development SLF files (using SLFhelper)

Read development SLF files (using SLFhelper)

## Usage

``` r
read_dev_slf_file(year, type = c("episode", "individual"), col_select = NULL)
```

## Arguments

- year:

  Year of the file to be read, you can specify multiple years which will
  then be returned as one file. See SLFhelper for more info.

- type:

  Type of file to be read. Supply either Episode or Individual file.

- col_select:

  Supply the columns you would like to select.

## Value

a tibble with development SLF file
