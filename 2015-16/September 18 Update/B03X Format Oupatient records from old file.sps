* Encoding: UTF-8.
 * Get the outpatients reocrds.
 * This is just a select if recid = "00B".

GET  FILE = !File + "source-episode-file-20" + !FY + "-Outpatients-only.zsav".


 * Recode GP Practice into a 5 digit number.
 * We assume that if it starts with a letter it's an English practice and so recode to 99995.
Do if Range(char.Substr(gpprac, 1, 1), "A", "Z").
   Compute gpprac = "99995".
End if. 
Alter Type GPprac (F5.0).

Alter type refsource (A3).

Alter type attendance_status (F1.0).

 * reset the cost variable.
Compute Cost_Total_Net = Cost_Total_Net_incDNAs.

Rename Variables
    pc7 = Postcode
    april_cost = apr_cost
    june_cost = jun_cost
    july_cost = jul_cost
    august_cost = aug_cost
    sept_cost = sep_cost.

alter type dob (A8).
alter type dob (sdate10).

Recode nhshosp commhosp ('1' = 'Y') ('0' = 'N').

 * Save out in the exact form that will be expected.
save outfile = !file + 'outpatients_for_source-20'+!FY+'.zsav'
    /keep year
    recid
    record_keydate1
    record_keydate2
    chi
    gender
    dob
    gpprac
    hbpraccode
    postcode
    hbrescode
    lca
    location
    hbtreatcode
    spec
    sigfac
    conc
    cat
    age
    refsource
    reftype
    attendance_status
    clinic_type
    alcohol_adm
    submis_adm
    falls_adm
    selfharm_adm
    commhosp
    nhshosp
    cost_total_net
    apr_cost may_cost jun_cost jul_cost aug_cost sep_cost oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost
    /zcompressed.


get file = !file + 'outpatients_for_source-20'+!FY+'.zsav'.
