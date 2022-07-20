# monthly beddays errors properly

    `discharge_date` must not be earlier than `admission_date`
    i See case 9 where `admission_date` = '2022-01-01' and `discharge_date` = '2020-01-01'
    There are 2 errors in total.

# monthly beddays work as expected

    Code
      as.data.frame(create_monthly_beddays(input_data, year = "1819", adm_date,
        dis_date))
    Output
          adm_date   dis_date apr_beddays may_beddays jun_beddays jul_beddays
      1 2020-01-02 2021-01-01           0           0           0           0
      2 2020-04-05 2021-02-01           0           0           0           0
      3 2020-09-20 2020-12-31           0           0           0           0
      4 2017-01-01 2022-12-01          30          31          30          31
      5 2021-03-01 2021-03-05           0           0           0           0
      6 2019-01-01       <NA>           0           0           0           0
      7 2020-01-01       <NA>           0           0           0           0
      8 2021-01-01       <NA>           0           0           0           0
        aug_beddays sep_beddays oct_beddays nov_beddays dec_beddays jan_beddays
      1           0           0           0           0           0           0
      2           0           0           0           0           0           0
      3           0           0           0           0           0           0
      4          31          30          31          30          31          31
      5           0           0           0           0           0           0
      6           0           0           0           0           0          30
      7           0           0           0           0           0           0
      8           0           0           0           0           0           0
        feb_beddays mar_beddays
      1           0           0
      2           0           0
      3           0           0
      4          28          31
      5           0           0
      6          28          31
      7           0           0
      8           0           0

---

    Code
      as.data.frame(create_monthly_beddays(input_data, year = "1920", adm_date,
        dis_date))
    Output
          adm_date   dis_date apr_beddays may_beddays jun_beddays jul_beddays
      1 2020-01-02 2021-01-01           0           0           0           0
      2 2020-04-05 2021-02-01           0           0           0           0
      3 2020-09-20 2020-12-31           0           0           0           0
      4 2017-01-01 2022-12-01          30          31          30          31
      5 2021-03-01 2021-03-05           0           0           0           0
      6 2019-01-01       <NA>          30          31          30          31
      7 2020-01-01       <NA>           0           0           0           0
      8 2021-01-01       <NA>           0           0           0           0
        aug_beddays sep_beddays oct_beddays nov_beddays dec_beddays jan_beddays
      1           0           0           0           0           0          29
      2           0           0           0           0           0           0
      3           0           0           0           0           0           0
      4          31          30          31          30          31          31
      5           0           0           0           0           0           0
      6          31          30          31          30          31          31
      7           0           0           0           0           0          30
      8           0           0           0           0           0           0
        feb_beddays mar_beddays
      1          29          31
      2           0           0
      3           0           0
      4          29          31
      5           0           0
      6          29          31
      7          29          31
      8           0           0

---

    Code
      as.data.frame(create_monthly_beddays(input_data, year = "2021", adm_date,
        dis_date))
    Output
          adm_date   dis_date apr_beddays may_beddays jun_beddays jul_beddays
      1 2020-01-02 2021-01-01          30          31          30          31
      2 2020-04-05 2021-02-01          25          31          30          31
      3 2020-09-20 2020-12-31           0           0           0           0
      4 2017-01-01 2022-12-01          30          31          30          31
      5 2021-03-01 2021-03-05           0           0           0           0
      6 2019-01-01       <NA>          30          31          30          31
      7 2020-01-01       <NA>          30          31          30          31
      8 2021-01-01       <NA>           0           0           0           0
        aug_beddays sep_beddays oct_beddays nov_beddays dec_beddays jan_beddays
      1          31          30          31          30          31           1
      2          31          30          31          30          31          31
      3           0          10          31          30          31           0
      4          31          30          31          30          31          31
      5           0           0           0           0           0           0
      6          31          30          31          30          31          31
      7          31          30          31          30          31          31
      8           0           0           0           0           0          30
        feb_beddays mar_beddays
      1           0           0
      2           1           0
      3           0           0
      4          28          31
      5           0           4
      6          28          31
      7          28          31
      8          28          31

