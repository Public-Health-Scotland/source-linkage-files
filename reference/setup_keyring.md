# Interactively set up the keyring

This is meant to be used with
[`phs_db_connection()`](https://public-health-scotland.github.io/source-linkage-files/reference/phs_db_connection.md),
it can only be used interactively i.e. not in targets or in a workbench
job.

With the default options it will go through the steps to set up a
keyring which can be used to supply passwords to
[`odbc::dbConnect()`](https://dbi.r-dbi.org/reference/dbConnect.html)
(or others) in a secure and seamless way.

1.  Create an .Renviron file in the project and add a password (for the
    keyring) to it.

2.  Create a keyring with the password - Since we have saved the
    password as an environment variable it can be picked unlocked and
    used automatically.

3.  Add the database password to the keyring.

## Usage

``` r
setup_keyring(
  keyring = "createslf",
  key = "db_password",
  keyring_exists = FALSE,
  key_exists = FALSE,
  env_var_pass_exists = FALSE
)
```

## Arguments

- keyring:

  Name of the keyring

- key:

  Name of the key

- keyring_exists:

  Does the keyring already exist

- key_exists:

  Does the key already exist

- env_var_pass_exists:

  Does the password for the keyring already exist in the environment.

## Value

NULL (invisibly)
