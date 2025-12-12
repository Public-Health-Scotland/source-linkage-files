# Write Console Output to File

Sets up sink to capture console output and messages to .txt file.

## Usage

``` r
write_console_output(
  console_outputs = TRUE,
  file_type = c("episode", "individual", "targets"),
  year = NULL
)
```

## Arguments

- console_outputs:

  If TRUE, capture console output and messages to .txt file.

- file_type:

  Type of file being processed: "episode", "individual", or "targets".

- year:

  Financial year.
