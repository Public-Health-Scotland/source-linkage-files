* Encoding: UTF-8.
* Create maternity costed extract in suitable format for PLICS.

* Read in the maternity extract.  Rename/reformat/recode columns as appropriate. 

* Program by Denise Hastie, July 2016.
* Updated by Denise Hastie, August 2016.  Added in a section that was in the master PLICS file creation program
* with regards to calculating the length of stay for maternity.  

********************************************************************************************************.
 * Run 01-Set up Macros first!.
********************************************************************************************************.

* Read in CSV output file.
GET DATA  /TYPE=TXT
    /FILE = !Extracts + 'Maternity-episode-level-extract-20' + !FY + '.csv'
    /ENCODING='UTF8'
    /DELIMITERS=","
    /QUALIFIER='"'
    /ARRANGEMENT=DELIMITED
    /FIRSTCASE=2
    /VARIABLES=
    CostsFinancialYear A4
    DateofAdmissionFullDate A10
    DateofDischargeFullDate A10
    PatUPIC A10
    PatDateOfBirthC A10
    PracticeLocationCode A5
    PracticeNHSBoardCode A9
    GeoPostcodeC A7
    NHSBoardofResidenceCode A9
    HSCP2016 A9
    GeoCouncilAreaCode A2
    TreatmentLocationCode A7
    TreatmentNHSBoardCode A9
    OccupiedBedDays F4.2
    SpecialtyClassification1497Code A3
    SignificantFacilityCode A2
    ConsultantHCPCode A8
    ManagementofPatientCode A1
    AdmissionReasonCode A2
    AdmittedTransferfromCodenew A2
    AdmittedtransferfromLocationCode A5
    DischargeTypeCode A2
    DischargeTransfertoCodenew A2
    DischargedtoLocationCode A5
    ConditionOnDischargeCode F1.0
    ContinuousInpatientJourneyMarker A5
    CIJPlannedAdmissionCode F1.0
    CIJInpatientDayCaseIdentifierCode A2
    CIJTypeofAdmissionCode A2
    CIJAdmissionSpecialtyCode A3
    CIJDischargeSpecialtyCode A3
    TotalNetCosts F8.2
    Diagnosis1DischargeCode A6
    Diagnosis2DischargeCode A6
    Diagnosis3DischargeCode A6
    Diagnosis4DischargeCode A6
    Diagnosis5DischargeCode A6
    Diagnosis6DischargeCode A6
    Operation1ACode A4
    Operation2ACode A4
    Operation3ACode A4
    Operation4ACode A4
    DateofMainOperationFullDate A10
    AgeatMidpointofFinancialYear F3.0
    NHSHospitalFlag A1
    CommunityHospitalFlag A1
    AlcoholRelatedAdmission A1
    SubstanceMisuseRelatedAdmission A1
    FallsRelatedAdmission A1
    SelfHarmRelatedAdmission A1.
CACHE.
Execute.

rename variables
    AdmittedTransferFromCodenew = adtf
    AdmittedTransferFromLocationCode = admloc
    AgeatMidpointofFinancialYear = age
    AlcoholRelatedAdmission = alcohol_adm
    CIJAdmissionSpecialtyCode = CIJadm_spec
    CIJDischargeSpecialtyCode = CIJdis_spec
    CIJPlannedAdmissionCode = newpattype_ciscode
    CIJTypeofAdmissionCode = newcis_admtype
    CommunityHospitalFlag = commhosp
    ConditionOnDischargeCode = discondition
    ConsultantHCPCode = conc
    ContinuousInpatientJourneyMarker = cis_marker
    CostsFinancialYear = costsfy
    Diagnosis1DischargeCode = diag1
    Diagnosis2DischargeCode = diag2
    Diagnosis3DischargeCode = diag3
    Diagnosis4DischargeCode = diag4
    Diagnosis5DischargeCode = diag5
    Diagnosis6DischargeCode = diag6
    DischargeTransferToCodenew = dischto
    DischargeTypeCode = disch
    DischargedtoLocationCode = dischloc
    FallsRelatedAdmission = falls_adm
    GeoCouncilAreaCode = lca
    GeoPostcodeC = postcode
    ManagementofPatientCode = mpat
    NHSBoardofResidenceCode = hbrescode
    NHSHospitalFlag = nhshosp
    OccupiedBedDays = yearstay
    Operation1ACode = op1a
    Operation2ACode = op2a
    Operation3ACode = op3a
    Operation4ACode = op4a
    PatUPIC = chi
    PracticeLocationCode = gpprac
    PracticeNHSBoardCode = hbpraccode
    SelfHarmRelatedAdmission = selfharm_adm
    SignificantFacilityCode = sigfac
    SpecialtyClassification1497Code = spec
    SubstanceMisuseRelatedAdmission = submis_adm
    TotalNetCosts = cost_total_net
    TreatmentLocationCode = location
    TreatmentNHSBoardCode = hbtreatcode.

* Create a variable for gender.
numeric gender (F1.0).
compute gender = 2.

string year (a4) recid (a3) ipdc (a1) newcis_ipdc (a1) newpattype_cis (a13).
compute year = !FY.
compute recid = '02B'.

 * Recode GP Practice into a 5 digit number.
 * We assume that if it starts with a letter it's an English practice and so recode to 99995.
Do if Range(char.Substr(gpprac, 1, 1), "A", "Z").
   Compute gpprac = "99995".
End if. 
Alter Type GPprac (F5.0).

 * Set the IPDC marker for the CIJ.
Recode CIJInpatientDayCaseIdentifierCode ("IP" = "I") ("DC" = "D") into newcis_ipdc.

 * Recode newpattype.
Recode newpattype_ciscode
    (2 = "Maternity")
    (0 = "Non-elective")
    (1 = "Elective")
    Into newpattype_cis.

Rename Variables
    DateofAdmissionFullDate = record_keydate1
    DateofDischargeFullDate = record_keydate2
    DateofMainOperationFullDate = dateop1
    PatDateOfBirthC = dob.

alter type record_keydate1 record_keydate2 dob dateop1 (SDate10).
alter type record_keydate1 record_keydate2 dob dateop1 (Date12).

Numeric stay (F7.0).
Compute stay = Datediff(record_keydate2, record_keydate1, "days").

Frequencies stay yearstay.

 * BedDays.
* This Python program will call the 'BedDaysPerMonth' macro (Defined in A01) for each month in FY order.
Begin Program.
from calendar import month_name
import spss

#Loop through the months by number in FY order
for month in (4, 5, 6, 7, 8, 9, 10, 11, 12, 1, 2, 3):
   #To show what is happening print some stuff to the screen
   print(month, month_name[month])
   
   #Set up the syntax
   syntax = "!BedDaysPerMonth Month_abbr = " + month_name[month][:3]
   
   #Use the correct admission and discharge variables
   syntax += " AdmissionVar = record_keydate1 DischargeVar = record_keydate2."
   
   #print the syntax to the screen
   print(syntax)
   
   #run the syntax
   spss.Submit(syntax)
End Program.

* Costs.
* Declare Variables.
Numeric apr_cost may_cost jun_cost jul_cost aug_cost sep_cost oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost (F8.2).

* Calculate Cost per month from beddays and cost_total_net.
Do Repeat Beddays = Apr_beddays to Mar_beddays
    /Cost = Apr_cost to Mar_cost
    /MonthNum = 4 5 6 7 8 9 10 11 12 1 2 3.

    * Fix the instances where the episode is a daycase;
        * these will sometimes have 0.33 for the yearstay, this should be applied to the relevant month.
    Do if (record_keydate1 = record_keydate2).
        Do if  xdate.Month(record_keydate1) = MonthNum.
            Compute Cost = cost_total_net.
        Else.
            Compute Cost = 0.
        End if.
    Else.
        Compute Cost = (BedDays / yearstay) * cost_total_net.
    End if.
End Repeat.

 
 * Put record_keydate back into numeric.
Compute record_keydate1 = xdate.mday(record_keydate1) + 100 * xdate.month(record_keydate1) + 10000 * xdate.year(record_keydate1).
Compute record_keydate2 = xdate.mday(record_keydate2) + 100 * xdate.month(record_keydate2) + 10000 * xdate.year(record_keydate2).

alter type record_keydate1 record_keydate2 (F8.0).

sort cases by chi record_keydate1.

save outfile = !file + 'maternity_for_source-20' + !FY + '.zsav'
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
    stay
    yearstay
    spec
    sigfac
    conc
    mpat
    adtf
    admloc
    disch
    dischto
    dischloc
    diag1
    diag2
    diag3
    diag4
    diag5
    diag6
    op1a
    dateop1
    op2a
    op3a
    op4a
    age
    discondition
    cis_marker
    newcis_admtype
    newcis_ipdc
    newpattype_ciscode
    newpattype_cis
    CIJadm_spec
    CIJdis_spec
    alcohol_adm
    submis_adm
    falls_adm
    selfharm_adm
    commhosp
    nhshosp
    cost_total_net
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
    /zcompressed.

get file = !file + 'maternity_for_source-20' + !FY + '.zsav'.

 * zip up the raw data.
Host Command = ["gzip '" + !Extracts + "Maternity-episode-level-extract-20" + !FY + ".csv'"].






