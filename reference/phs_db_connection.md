# Open a connection to a PHS database

Opens a connection to PHS database given a Data Source Name (DSN) it
will try to get the username, asking for input if in an interactive
session. It will also use
[keyring](https://keyring.r-lib.org/reference/keyring-package.html) to
find an existing keyring called 'createslf' which should contain a
`db_password` key with the users database password.

## Usage

``` r
phs_db_connection(dsn, username)
```

## Arguments

- dsn:

  The Data Source Name (DSN) passed on to
  [`odbc::dbConnect()`](https://dbi.r-dbi.org/reference/dbConnect.html)
  the DSN must be set up first. e.g. `SMRA` or `DVPROD`

- username:

  The username to use for authentication, if not supplied it will try to
  find it automatically and if possible ask the user for input.

## Value

a connection to the specified Data Source.
