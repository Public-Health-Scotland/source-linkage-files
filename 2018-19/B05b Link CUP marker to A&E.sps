* Encoding: UTF-8.
* James McMahon July 2019
    * Extract CUP variables from UCD and link to
    ********************************************************************************************************.
* Run 01-Set up Macros first!.
********************************************************************************************************.
GET DATA  /TYPE=TXT
    /FILE= !Year_Extracts_dir + "A&E-UCD-CUP-extract-20" + !FY + ".csv"
    /ENCODING='UTF8'
    /DELIMITERS=","
    /QUALIFIER='"'
    /ARRANGEMENT=DELIMITED
    /FIRSTCASE=2
    /VARIABLES=
    ArrivalDate A10
    ArrivalTime Time5
    CaseReferenceNumber A100
    CUPMarker F2.0
    CUPPathwayName A30.
CACHE.
EXECUTE.

Rename Variables
    ArrivalDate = record_keydate1
    ArrivalTime = keyTime1
    CUPMarker = CUP_marker
    CUPPathwayName = CUP_pathway.

Compute record_keydate1 = Replace(record_keydate1, "/", "").

Alter Type record_keydate1 (F8.0).

* Sort for linking onto data extract.
* And remove any duplicates.

aggregate outfile = *
    /Break record_keydate1 keyTime1 CaseReferenceNumber
    /CUP_marker CUP_pathway = First(CUP_marker CUP_pathway).

match files
    /file = !Year_dir + "a&e_data-20" + !FY + ".zsav"
    /table = *
    /by record_keydate1 keyTime1 CaseReferenceNumber.

sort cases by chi record_keydate1 keyTime1 record_keydate2 keyTime2.

 * Don't keep the CaseReferenceNumber as it's not a very good unique ID.
save outfile = !Year_dir + 'a&e_for_source-20' + !FY + '.zsav'
    /keep year
    recid
    record_keydate1
    record_keydate2
    keyTime1
    keyTime2
    chi
    gender
    dob
    gpprac
    postcode
    lca
    HSCP
    location
    hbrescode
    hbtreatcode
    diag1
    diag2
    diag3
    ae_arrivalmode
    refsource
    ae_attendcat
    ae_disdest
    ae_patflow
    ae_placeinc
    ae_reasonwait
    ae_bodyloc
    ae_alcohol
    alcohol_adm
    submis_adm
    falls_adm
    selfharm_adm
    cost_total_net
    age
    apr_cost
    may_cost
    jun_cost
    jul_cost
    aug_cost
    sep_cost
    oct_cost
    nov_cost
    dec_cost
    jan_cost
    feb_cost
    mar_cost
    CUP_marker
    CUP_pathway
    /zcompressed.

get file = !Year_dir + 'a&e_for_source-20' + !FY + '.zsav'.

* Housekeeping.
Erase file = !Year_dir + 'a&e_data-20' + !FY + '.zsav'.

* Zip up raw data.
Host Command = ["gzip '" + !Year_Extracts_dir + "A&E-UCD-CUP-extract-20" + !FY + ".csv'"].

