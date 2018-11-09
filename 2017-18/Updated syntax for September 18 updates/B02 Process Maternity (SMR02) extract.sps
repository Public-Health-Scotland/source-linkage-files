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

 * Need to have Year as the first variable.
add files file = *
    /Keep Year All.
 * Count the beddays.
 * Similar method to that used in Care homes.
 * 1) Declare an SPSS macro which will set the beddays for each month.
 * 2) Use python to run the macro with the correct parameters.
 * This means that different month lengths and leap years are handled correctly.
Define !BedDaysAndCostsPerMonth (Month = !Tokens(1) 
   /MonthNum = !Tokens(1) 
   /DaysInMonth = !Tokens(1) 
   /Year = !Tokens(1))

 * Store the start and end date of the given month.
Compute #StartOfMonth = Date.DMY(1, !MonthNum, !Year).
Compute #EndOfMonth = Date.DMY(!DaysInMonth, !MonthNum, !Year).

 * Create the names of the variables e.g. April_beddays and April_cost.
!Let !BedDays = !Concat(!Month, "_beddays").
!Let !Costs = !Concat(!Month, "_cost").

 * Create variables for the month.
Numeric !Costs (F8.2).
Numeric !BedDays (F8.2).

 * Go through all possibilities to decide how many days to be allocated.
Do if record_keydate1 LE #StartOfMonth.
   Do if record_keydate2 GE #EndOfMonth.
      Compute !BedDays = !DaysInMonth.
   Else.
      Compute !BedDays = DateDiff(record_keydate2, #StartOfMonth, "days").
   End If.
Else if record_keydate1 LE #EndOfMonth.
   Do if record_keydate2 GT #EndOfMonth.
      Compute !BedDays = DateDiff(#EndOfMonth, record_keydate1, "days") + 1.
   Else.
       Compute !BedDays = DateDiff(record_keydate2, record_keydate1, "days").
    End If.
Else.
   Compute !BedDays = 0.
End If.

 * Months after the discharge date will end up with negatives.
If !BedDays < 0 !BedDays = 0.

 * Now set costs.
 * First deal with the single day cases; we want to keep the beddays and can assign all costs to that month.
 * The next bit sets zeros for other months in the above case.
Do if (record_keydate1 = record_keydate2 and Range(record_keydate1, #StartOfMonth, #EndOfMonth)).
    Compute !BedDays = yearstay.
    Compute !Costs = cost_total_net.
Else if (record_keydate1 = record_keydate2).
    Compute !BedDays = 0.
    Compute !Costs = 0.
Else if yearstay NE 0.
    Compute !Costs = (!BedDays / yearstay) * cost_total_net.
Else.
    Compute !Costs = 0.
End if.
!EndDefine.

 * This python program will call the macro for each month with the right variables.
 * They will also be in FY order.
Begin Program.
from calendar import month_name, monthrange
from datetime import date
import spss

#Set the financial year, this line reads the first variable ('year')
fin_year = int((int(spss.Cursor().fetchone()[0]) // 100) + 2000)

#This line generates a 'dictionary' which will hold all the info we need for each month
#month_name is a list of all the month names and just needs the number of the month
#(m < 4) + 2015 - This will set the year to be 2015 for April onwards and 2016 other wise
#monthrange takes a year and a month number and returns 2 numbers, the first and last day of the month, we only need the second.
months = {m: [month_name[m], (m < 4) + fin_year, monthrange((m < 4) + fin_year, m)[1]]  for m in range(1,13)}
print(months) #Print to the output window so you can see how it works

#This will make the output look a bit nicer
print("\n\n***This is the syntax that will be run:***")

#This loops over the months above but first sorts them by year, meaning they are in correct FY order
for month in sorted(months.items(), key=lambda x: x[1][1]):
   syntax = "!BedDaysAndCostsPerMonth Month = " + month[1][0][:3]
   syntax += " MonthNum = " + str(month[0])
   syntax += " DaysInMonth = " + str(month[1][2])
   syntax += " Year = " + str(month[1][1]) + "."
   
   print(syntax)
   spss.Submit(syntax)
spss.Submit("execute.")
End Program.

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
    oct_cost
    nov_beddays
    dec_beddays
    jan_beddays
    feb_beddays
    mar_beddays
    /zcompressed.

get file = !file + 'maternity_for_source-20' + !FY + '.zsav'.

 * zip up the raw data.
Host Command = ["gzip -m '" + !Extracts + "Maternity-episode-level-extract-20" + !FY + ".csv'"].






