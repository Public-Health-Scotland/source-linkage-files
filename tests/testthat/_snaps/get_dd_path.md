# Delayed discharges file is as expected

    Code
      dplyr::glimpse(latest_dd_file, width = 0)
    Output
      Rows: 198,751
      Columns: 14
      $ cennum                 <dbl> ~
      $ MONTHFLAG              <chr> ~
      $ chi                    <chr> ~
      $ OriginalAdmissionDate  <date> ~
      $ RDD                    <date> ~
      $ Delay_End_Date         <date> ~
      $ Delay_End_Reason       <chr> ~
      $ Primary_Delay_Reason   <chr> ~
      $ Secondary_Delay_Reason <chr> ~
      $ hbtreatcode            <chr> ~
      $ location               <chr> ~
      $ dd_responsible_lca     <chr> ~
      $ postcode               <chr> ~
      $ spec                   <chr> ~

