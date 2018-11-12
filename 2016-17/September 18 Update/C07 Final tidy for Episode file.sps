* Encoding: UTF-8.
get file = !File + "temp-source-episode-file-6-" + !FY + ".zsav".

variable labels
    year "Year"
    recid "Record Identifier"
    record_keydate1 "Record Keydate 1"
    record_keydate2 "Record Keydate 2"
    keydate1_dateformat "Record Key date 1 in Date format"
    keydate2_dateformat "Record Key date 2 in Date format"
    keyTime1 "Record KeyTime 1"
    keyTime2 "Record KeyTime 2"
    SMRType "Record type"
    chi "Community Health Index number"
    gender "Gender"
    dob "Date of Birth"
    gpprac "GP Practice code"
    hbpraccode "NHS Board of GP Practice"
    postcode "7 character postcode"
    hbrescode "NHS Board of Residence"
    lca "Local Council Authority"
    hbtreatcode "NHS Board of Treatment"
    location "Treatment location code"
    yearstay "Stay within year "
    stay "Length of Stay"
    ipdc "Inpatient/Day case marker"
    spec "Specialty "
    sigfac "Significant Facility"
    conc "Consultant Code"
    mpat "Management of Patient"
    cat "Patient Category"
    tadm "Type of Admission"
    adtf "Admitted/Transferred from"
    admloc "Admitted/Transferred from location"
    oldtadm "Old Type of Admission"
    disch "Discharge Type"
    dischto "Discharged To"
    dischloc "Discharged To Location"
    diag1 "Main condition"
    diag2 "Co-morbidity/other condition 1"
    diag3 "Co-morbidity/other condition 2"
    diag4 "Co-morbidity/other condition 3"
    diag5 "Co-morbidity/other condition 4"
    diag6 "Co-morbidity/other condition 5"
    op1a "Main operation code (A part)"
    op1b "Main operation code (B part)"
    dateop1 "Date of Main Operation"
    op2a "Other operation 1 (A Part)"
    op2b "Other operation 1 (B Part)"
    dateop2 "Date of Other operation 1"
    op3a "Other operation 2 (A Part)"
    op3b "Other operation 2 (B Part)"
    dateop3 "Date of Other operation 2"
    op4a "Other operation 3 (A Part)"
    op4b "Other operation 3 (B Part)"
    dateop4 "Date of Other operation 3"
    smr01_cis "CIS marker from SMR01 record"
    discondition "Condition on Discharge"
    stadm "Status on Admission"
    adcon1 "Admission Condition 1"
    adcon2 "Admission Condition 2"
    adcon3 "Admission Condition 3"
    adcon4 "Admission Condition 4"
    reftype "Referral Type"
    refsource "Referral Source"
    attendance_status "Attendance Status"
    clinic_type "Clinic Type"
    ae_arrivalmode "Arrival Mode"
    ae_attendcat "Attendance Category"
    ae_disdest "Discharge Destination"
    ae_patflow "Patient Flow"
    ae_placeinc "Place Incident Occurred"
    ae_reasonwait "Reason for Wait"
    ae_bodyloc "Bodily Location"
    ae_alcohol "Alcohol Involved"
    death_location_code "Death location"
    death_board_occurrence "NHS Board of Occurrence of death"
    place_death_occurred "Place death occurred"
    deathdiag1 "Main cause of death"
    deathdiag2 "Secondary Cause 0"
    deathdiag3 "Secondary Cause 1"
    deathdiag4 "Secondary Cause 2"
    deathdiag5 "Secondary Cause 3"
    deathdiag6 "Secondary Cause 4"
    deathdiag7 "Secondary Cause 5"
    deathdiag8 "Secondary Cause 6"
    deathdiag9 "Secondary Cause 7"
    deathdiag10 "Secondary Cause 8"
    deathdiag11 "Secondary Cause 9"
    age "Age of patient at midpoint of financial year"
    cost_total_net "Total Net Cost excluding Outpatient and OoH DNA costs"
    Cost_Total_Net_incDNAs "Total Net Cost including Outpatient and OoH DNA costs"
    nhshosp "NHS Hospital flag"
    apr_beddays "Number of Bed days from episode in April"
    may_beddays "Number of Bed days from episode in May"
    jun_beddays "Number of Bed days from episode in June"
    jul_beddays "Number of Bed days from episode in July"
    aug_beddays "Number of Bed days from episode in August"
    sep_beddays "Number of Bed days from episode in September"
    oct_beddays "Number of Bed days from episode in October"
    nov_beddays "Number of Bed days from episode in November"
    dec_beddays "Number of Bed days from episode in December"
    jan_beddays "Number of Bed days from episode in January"
    feb_beddays "Number of Bed days from episode in February"
    mar_beddays "Number of Bed days from episode in March"
    apr_cost "Cost from episode in April"
    may_cost "Cost from episode in May"
    jun_cost "Cost from episode in June"
    jul_cost "Cost from episode in July"
    aug_cost "Cost from episode in August"
    sep_cost "Cost from episode in September"
    oct_cost "Cost from episode in October"
    nov_cost "Cost from episode in November"
    dec_cost "Cost from episode in December"
    jan_cost "Cost from episode in January"
    feb_cost "Cost from episode in February"
    mar_cost "Cost from episode in March"
    uri "Unique record identifier"
    cis_marker "CIJ (Continuous Inpatient Journey) marker"
    newcis_admtype "CIJ admission type"
    newcis_ipdc "CIJ inpatient day case identifier"
    newpattype_ciscode "CIJ patient type code"
    newpattype_cis "CIJ patient type"
    CIJadm_spec "Specialty on first record in CIJ"
    CIJdis_spec "Specialty on last record in CIJ"
    alcohol_adm "Indicates alcohol related admission or attendance"
    submis_adm "Indicates substance misuse related admission or attendance"
    falls_adm "Indicates fall related admission or attendance"
    selfharm_adm "Indicates self-harm related admission or attendance"
    commhosp "Community Hospital flag"
    post_mortem "Post Mortem Indicator"
    death_date "Derived Date of Death"
    no_dispensed_items "Number of dispensed items"
    deceased "Deceased flag"
    cvd "Cardiovascular disease (CVD) LTC marker"
    copd "Chronic Obstructive Pulmonary Disease (COPD) LTC marker"
    dementia "Dementia LTC marker"
    diabetes "Diabetes LTC marker"
    chd "Coronary heart disease (CHD) LTC marker"
    hefailure "Heart Failure LTC marker"
    refailure "Renal Failure LTC marker"
    epilepsy "Epilepsy LTC marker"
    asthma "Asthma LTC marker"
    atrialfib "Atrial Fibrillation LTC marker"
    cancer "Cancer LTC marker"
    arth "Arthritis Artherosis LTC marker"
    parkinsons "Parkinsons LTC marker"
    liver "Chronic Liver Disease LTC marker"
    ms "Multiple Sclerosis LTC marker"
    congen "Congenital Problems LTC marker"
    bloodbfo "Diseases of Blood and Blood Forming Organs LTC marker"
    endomet "Other Endocrine Metabolic Diseases LTC marker"
    digestive "Other Diseases of Digestive System LTC marker"
    arth_date "Arthritis Artherosis LTC incidence date"
    asthma_date "Asthma LTC incidence date"
    atrialfib_date "Atrial Fibrillation LTC incidence date"
    cancer_date "Cancer LTC incidence date"
    cvd_date "Cardiovascular disease (CVD) LTC incidence date"
    liver_date "Chronic Liver Disease LTC incidence date"
    copd_date "Chronic Obstructive Pulmonary Disease (COPD) LTC incidence date"
    dementia_date "Dementia LTC incidence date"
    diabetes_date "Diabetes LTC incidence date"
    epilepsy_date "Epilepsy LTC incidence date"
    chd_date "Coronary heart disease (CHD) LTC incidence date"
    hefailure_date "Heart failure LTC incidence date"
    ms_date "Multiple Sclerosis LTC incidence date"
    parkinsons_date "Parkinsons LTC incidence date"
    refailure_date "Renal failure LTC incidence date"
    congen_date "Congenital Problems LTC incidence date"
    bloodbfo_date "Diseases of Blood and Blood Forming Organs LTC incidence date"
    endomet_date "Other Endocrine Metabolic Diseases LTC incidence date"
    digestive_date "Other Diseases of Digestive System LTC incidence date"
    CIS_PPA "CIS episode that began in a Potentially Preventable Admission (PPA)"
    SPARRA_Start_FY "SPARRA 12-month risk score from the start of the financial year"
    SPARRA_End_FY "SPARRA 12-month risk score from the end of the financial year"
    Locality "HSCP Locality. Based on postcode and are correct at time of update"
    Cluster "GP Practice cluster. Based on gpprac and are correct at time of update".

 * Gender flags.
Value Labels gender
   '0' "Not Known"
   '1' "Male"
   '2' "Female"
   '9' "Not Specified".

Value Labels year
   '1011' "2010/11"
   '1112' "2011/12"
   '1213' "2012/13"
   '1314' "2013/14"
   '1415' "2014/15"
   '1516' "2015/16"
   '1617' "2016/17"
   '1718' "2017/18"
   '1819' "2018/19"
   '1920' "2019/20"
   '2021' "2020/21"
   '2122' "2021/22"
   '2223' "2022/23"
   '2324' "2023/24"
   '2425' "2024/25".

Add value labels location
    '1' "CHAD - Hospital including Day Hospitals"
    '2' "CHAD - Health Centre"
    '3' "CHAD - GP Surgery"
    '5' "CHAD - Nursing Home, Care Home or Residential Home"
    '6' "CHAD - Patient or client home / residence"
    '7' "CHAD - Day Centre"
    '8' "CHAD - Other".

Define !AddHBDictionaryInfo (HB = !CMDEND)
    Add Value Labels !HB
        'S08000015' "Ayrshire and Arran"
        'S08000016' "Borders"
        'S08000017' "Dumfries and Galloway"
        'S08000018' "Fife"
        'S08000019' "Forth Valley"
        'S08000020' "Grampian"
        'S08000021' "Greater Glasgow and Clyde"
        'S08000022' "Highland"
        'S08000023' "Lanarkshire"
        'S08000024' "Lothian"
        'S08000025' "Orkney"
        'S08000026' "Shetland"
        'S08000027' "Tayside"
        'S08000028' "Western Isles"
        'S08200001' 'Out-with Scotland'
        'S08200002' 'No Fixed Abode'
        'S08200003' 'Not Known'
        'S08200004' 'Outside UK'.
!EndDefine.

!AddHBDictionaryInfo HB = hbrescode hbtreatcode hbpraccode death_board_occurrence.

Define !AddLCADictionaryInfo (LCA = !CMDEND)
   Value Labels !LCA
      '01' "Aberdeen City"
      '02' "Aberdeenshire"
      '03' "Angus"
      '04' "Argyll and Bute"
      '05' "Scottish Borders"
      '06' "Clackmannanshire"
      '07' "West Dunbartonshire"
      '08' "Dumfries and Galloway"
      '09' "Dundee City"
      '10' "East Ayrshire"
      '11' "East Dunbartonshire"
      '12' "East Lothian"
      '13' "East Renfrewshire"
      '14' "City of Edinburgh"
      '15' "Falkirk"
      '16' "Fife"
      '17' "Glasgow City"
      '18' "Highland"
      '19' "Inverclyde"
      '20' "Midlothian"
      '21' "Moray"
      '22' "North Ayrshire"
      '23' "North Lanarkshire"
      '24' "Orkney Islands"
      '25' "Perth and Kinross"
      '26' "Renfrewshire"
      '27' "Shetland Islands"
      '28' "South Ayrshire"
      '29' "South Lanarkshire"
      '30' "Stirling"
      '31' "West Lothian"
      '32' "Na h-Eileanan Siar"
!EndDefine.

!AddLCADictionaryInfo LCA = LCA sc_send_lca ch_lca.

Value Labels ipdc newcis_ipdc
   'I' "Inpatient"
   'D' "Daycase".

Value Labels recid
    '00B' "Outpatient (SMR00) appointments"
    '01B' "Acute (SMR01) discharges"
    '02B' "Maternity (SMR02) discharges"
    '04B' "Mental Health (SMR04) admissions/discharges"
    'AE2' "Accident & Emergency attendances"
    'CH' "Care Home records"
    'DD' "Delayed Discharge episode"
    'DN' "District Nursing episode"
    'CMH' 'Community Mental Health episiode'
    'GLS' "Geriatric Long Stay (SMR01) discharges"
    'NRS' "National Records Service death registrations"
    'NSU' "Non-Service-User (Included for whole population analysis)"
    'OoH' "GP Out of Hours contact"
    'PIS' "Community Prescribing summary".

Add Value Labels SMRType
    'Acute-DC' 'Acute - Daycase'
    'Acute-IP' 'Acute - Inpatient'
    'Care-Home' 'Care Home resident'
    'DD-CIS' 'Delayed Discharge - Linked to a CIS episode'
    'DD-No CIS' 'Delayed Discharge - Not linked to a CIS episode'
    'DN' 'District Nursing'
    'Comm-MH' 'Community Mental Health'
    'GLS-IP' 'Geriatric Long Stay - Inpatient'
    'Matern-DC' 'Maternity - Daycase'
    'Matern-IP' 'Maternity - Inpatient'
    'Non-User' 'Non-Service-User'
    'PIS' 'Community Prescribing summary'
    'Psych-IP' 'Psychiatric - Inpatient'.

Value Labels spec CIJadm_spec CIJdis_spec
    'A1' "General Medicine"
    'A11' "Acute Medicine"
    'A2' "Cardiology"
    'A3' "Clinical Genetics"
    'A4' "Tropical Medicine"
    'A6' "Infectious Diseases"
    'A7' "Dermatology"
    'A8' "Endocrinology & Diabetes"
    'A81' "Endocrine"
    'A82' "Diabetes"
    'A9' "Gastroenterology"
    'AA' "Genito-Urinary Medicine"
    'AB' "Geriatric Medicine"
    'AC' "Homoeopathy"
    'AD' "Medical Oncology"
    'AF' "Paediatrics"
    'AG' "Renal Medicine"
    'AH' "Neurology"
    'AJ' "Integrative Care"
    'AM' "Palliative Medicine"
    'AP' "Rehabilitation Medicine"
    'AQ' "Respiratory Medicine"
    'AR' "Rheumatology"
    'AV' "Clinical Neurophysiology"
    'AW' "Allergy"
    'C1' "General Surgery"
    'C11' "General Surgery (excl. Vascular)"
    'C12' "Vascular Surgery"
    'C13' "Oral & Maxillofacial Surgery"
    'C2' "Accident & Emergency"
    'C3' "Anaesthetics"
    'C31' "Pain Management"
    'C4' "Cardiothoracic Surgery"
    'C41' "Cardiac Surgery"
    'C42' "Thoracic Surgery"
    'C5' "Ear, Nose & Throat"
    'C51' "Audiological Medicine"
    'C6' "Neurosurgery"
    'C7' "Ophthalmology"
    'C8' "Trauma & Orthopaedic Surgery"
    'C9' "Plastic Surgery"
    'C91' "Cleft Lip & Palate Surgery"
    'CA' "Paediatric Surgery"
    'CB' "Urology"
    'D1' "Community Dental Practice"
    'D3' "Oral Surgery(ex. C13)"
    'D4' "Oral Medicine"
    'D5' "Orthodontics"
    'D6' "Restorative Dentistry"
    'D8' "Paediatric Dentistry"
    'E12' "GP Other than Obstetrics"
    'F2' "Gynaecology"
    'F4' "Community Sexual & Reproductive Health"
    'H1' "Clinical  Radiology (Diagnostic Radiology)"
    'H2' "Clinical Oncology"
    'J3' "Chemical Pathology"
    'J4' "Haematology"
    'J5' "Immunology"
    'R11' "Surgical Podiatry".


Value Labels sigfac
   '11' "Other (inc. Clinical Facilities of Standard Specialty Ward 1K, Day Bed Unit 1J)"
   '13' "Intensive Care Unit"
   '14' "Cardiac Care Unit"
   '16' "Children's Unit"
   '17' "Accident & Emergency (A&E) Ward"
   '18' "Ward for Younger Physically Disabled"
   '19' "Spinal Unit"
   '1A' "Geriatric Orthopaedic Rehabilitation Unit (GORU)"
   '1B' "Rehabilitation Ward (except GORU & PRU)"
   '1C' "Burns Unit"
   '1D' "Geriatric Assessment Unit"
   '1E' "Long Stay Unit for Care of the Elderly"
   '1F' "Convalescent Unit"
   '1G' "Palliative Care Unit"
   '1H' "High Dependency Unit"
   '1M' "Transplant Unit"
   '1P' "Stroke Unit"
   '39' "Ambulatory Emergency Care Unit"
   '40' "Acute Assessment Unit (AAU)".

Value Labels cat
   '1' "Amenity"
   '4' "Overseas visitor - liable to pay for treatment"
   '2' "Paying"
   '5' "Overseas visitor - not liable to pay"
   '3' "NHS"
   '8' "Other (including Hospice)".

Value Labels attendance_status
   1 "Patient attended and was seen"
   5 "Patient attended but was not seen (CNW - Could Not Wait)"
   8 "Patient did not attend (DNA)".

Value Labels deceased
   '1' "Deceased"
   '0' "Alive".


Variable Width
    year (4)
    ipdc mpat cat alcohol_adm submis_adm falls_adm selfharm_adm commhosp nhshosp clinic_type ae_patflow post_mortem newcis_ipdc (1)
    lca sigfac tadm adtf disch dischto newcis_admtype ae_arrivalmode ae_attendcat ae_alcohol sc_send_lca ch_lca ch_admreas (2)
    ooh_outcome.1 ooh_outcome.2 ooh_outcome.3 ooh_outcome.4 (2)
    age (3)
    newpattype_cis recid spec CIJadm_spec CIJdis_spec refsource ae_disdest ae_placeinc ae_reasonwait ae_bodyloc (3)
    op1a op1b op2a op2b op3a op3b op4a op4b (4)
    deathdiag1 deathdiag2 deathdiag3 deathdiag4 deathdiag5 deathdiag6 deathdiag7 deathdiag8 deathdiag9 deathdiag10 deathdiag11 (4)
    gpprac (5)
    smr01_cis (5)
    CCM (5)
    admloc dischloc cis_marker death_location_code (5)
    diag1 diag2 diag3 diag4 diag5 diag6 (6)
    adcon1 adcon2 adcon3 adcon4 (6)
    gender (6)
    apr_beddays may_beddays jun_beddays jul_beddays aug_beddays sep_beddays oct_beddays nov_beddays dec_beddays jan_beddays feb_beddays mar_beddays (6)
    apr_cost may_cost jun_cost jul_cost aug_cost sep_cost oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost (6)
    location (7)
    postcode (8)
    conc (8)
    hbpraccode hbrescode HSCP2016 DataZone2011 hbtreatcode  death_board_occurrence (9)
    stay (7)
    SMRType chi ch_name (10)
    cost_total_net cost_total_net_incDNAs (10)
    record_keydate1 record_keydate2 keydate1_dateformat keydate2_dateformat dob death_date dateop1 dateop2 dateop3 dateop4(10).

*********************************************************************************************.
Sort Cases by CHI record_keydate1 record_keydate2.

* Reorder and keep vars.
 * New vars;
 * GPOOH - KIS_accessed ConsultationStartTime ConsultationEndTime ooh_outcome.1 ooh_outcome.2 ooh_outcome.3 ooh_outcome.4 ooh_CC 
 * Care Homes - sc_send_lca ch_name ch_lca ch_admreas
 * DN - CCM TotalnoDNcontacts TotalDurationofContacts

Save Outfile = !File + "source-episode-file-20" + !FY + ".zsav"
    /keep
    year
    recid
    record_keydate1
    record_keydate2
    keydate1_dateformat
    keydate2_dateformat
    keyTime1
    KeyTime2
    SMRType
    chi
    gender
    dob
    age
    gpprac
    hbpraccode
    postcode
    hbrescode
    hbtreatcode
    location
    yearstay
    stay
    ipdc
    spec
    sigfac
    diag1
    diag2
    diag3
    diag4
    diag5
    diag6
    op1a
    op1b
    dateop1
    op2a
    op2b
    dateop2
    op3a
    op3b
    dateop3
    op4a
    op4b
    dateop4
    stadm
    adcon1
    adcon2
    adcon3
    adcon4
    conc
    mpat
    cat
    tadm
    adtf
    admloc
    oldtadm
    disch
    dischto
    dischloc
    discondition
    reftype
    refsource
    Delay_End_Reason
    Primary_Delay_Reason
    Secondary_Delay_Reason
    DD_Quality
    clinic_type
    attendance_status
    ae_arrivalmode
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
    CIS_PPA
    death_location_code
    death_board_occurrence
    place_death_occurred
    post_mortem
    deathdiag1
    deathdiag2
    deathdiag3
    deathdiag4
    deathdiag5
    deathdiag6
    deathdiag7
    deathdiag8
    deathdiag9
    deathdiag10
    deathdiag11
    deceased
    death_date
    KIS_accessed
    ooh_outcome.1
    ooh_outcome.2
    ooh_outcome.3
    ooh_outcome.4
    ooh_CC
    CCM
    TotalnoDNcontacts
    sc_send_lca
    ch_name
    ch_lca
    ch_admreas
    no_dispensed_items
    nhshosp
    commhosp
    smr01_cis
    cis_marker
    newcis_ipdc
    newcis_admtype
    newpattype_ciscode
    newpattype_cis
    CIJadm_spec
    CIJdis_spec
    uri
    arth
    asthma
    atrialfib
    cancer
    cvd
    liver
    copd
    dementia
    diabetes
    epilepsy
    chd
    hefailure
    ms
    parkinsons
    refailure
    congen
    bloodbfo
    endomet
    digestive
    arth_date
    asthma_date
    atrialfib_date
    cancer_date
    cvd_date
    liver_date
    copd_date
    dementia_date
    diabetes_date
    epilepsy_date
    chd_date
    hefailure_date
    ms_date
    parkinsons_date
    refailure_date
    congen_date
    bloodbfo_date
    endomet_date
    digestive_date
    cost_total_net
    Cost_Total_Net_incDNAs
    apr_beddays
    may_beddays
    jun_beddays
    jul_beddays
    aug_beddays
    sep_beddays
    oct_beddays
    nov_beddays
    dec_beddays
    jan_beddays
    feb_beddays
    mar_beddays
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
    HSCP2016
    LCA
    CA2011
    Locality
    DataZone2011
    simd2016rank
    simd2016_sc_decile
    simd2016_sc_quintile
    simd2016_HB2014_decile
    simd2016_HB2014_quintile
    simd2016_HSCP2016_decile
    simd2016_HSCP2016_quintile
    UR8_2016
    UR6_2016
    UR3_2016
    UR2_2016
    Cluster
    Demographic_Cohort
    Service_Use_Cohort
    SPARRA_Start_FY
    SPARRA_End_FY
    /zcompressed.
get file = !File + "source-episode-file-20" + !FY + ".zsav".


* Housekeeping.
* May get some errors if files have already been deleted to save space.
erase file = !File + "temp-source-episode-file-1-" + !FY + ".zsav".
erase file = !File + "temp-source-episode-file-2-" + !FY + ".zsav".
erase file = !File + "temp-source-episode-file-3-" + !FY + ".zsav".
erase file = !File + "temp-source-episode-file-4-" + !FY + ".zsav".
erase file = !File + "temp-source-episode-file-5-" + !FY + ".zsav".
erase file = !File + "temp-source-episode-file-6-" + !FY + ".zsav".
erase file = !File + "temp-source-episode-file-7-" + !FY + ".zsav".
