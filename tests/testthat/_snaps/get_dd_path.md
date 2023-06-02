# Delayed discharges file is as expected

    Code
      dplyr::glimpse(latest_dd_file, width = 0)
    Output
      Rows: 178,635
      Columns: 14
      $ cennum                 <dbl> ~
      $ MONTHFLAG              <chr> ~
      $ chi                    <chr> ~
      $ OriginalAdmissionDate  <date> ~
      $ RDD                    <date> ~
      $ Delay_End_Date         <date> ~
      $ Delay_End_Reason       <chr> ~
      $ primary_delay_reason   <chr> ~
      $ secondary_delay_reason <chr> ~
      $ hbtreatcode            <chr> ~
      $ location               <chr> ~
      $ dd_responsible_lca     <chr> ~
      $ postcode               <chr> ~
      $ spec                   <chr> ~

