* Encoding: UTF-8.
* Create Acute costed extract in suitable format for PLICS.

* Read in the acute extract. Rename/reformat/recode columns as appropriate. 

* Program by Denise Hastie, June 2016.
* Program updated by Denise Hastie, September 2016.
* September 2016 updates - reading in data from an BO output, not NSS IT output. 
* - adding in a section To match on the length of stay by uri (amendments required at a few places).                       
* - added in new code that populates newpattype_cis based on the admission type for records without a
                           upi number (chi). Note that transfers will be coded as Other. This will be handled in program 20. 

* Create macros for file path.
*Last ran 17/05/18AnitaGeorge


********************************************************************************************************.
 * Run 01-Set up Macros first!.
********************************************************************************************************.

* Read in CSV output file.
GET DATA /TYPE=TXT
   /FILE= !Extracts + 'Acute-episode-level-extract-20' + !FY + '.csv'
   /ENCODING='UTF8'
   /DELIMITERS=","
   /QUALIFIER='"'
   /ARRANGEMENT=DELIMITED
   /FIRSTCASE=2
   /VARIABLES=
      CostsFinancialYear01 A4
      CostsFinancialMonthName01 A9
      GLSRecord A1
      DateofAdmission01 A10
      DateofDischarge01 A10
      PatUPI A10
      PatGenderCode F1.0
      PatDateOfBirthC A10
      PracticeLocationCode A5
      PracticeNHSBoardCode A9
      GeoPostcodeC A7
      NHSBoardofResidenceCode A9
      GeoCouncilAreaCode A2
      HSCPCode A9
      GeoDataZone2011 A9
      TreatmentLocationCode A7
      TreatmentNHSBoardCode A9
      OccupiedBedDays01 F8.2
      InpatientDayCaseIdentifierCode A2
      SpecialtyClassificat.1497Code A3
      SignificantFacilityCode A2
      LeadConsultantHCPCode A8
      ManagementofPatientCode A1
      PatientCategoryCode A1
      AdmissionTypeCode A2
      AdmittedTransFromCode A2
      LocationAdmittedTransFromCode A5
      OldSMR1TypeofAdmissionCode F1.0
      DischargeTypeCode A2
      DischargeTransToCode A2
      LocationDischargedTransToCode A5
      Diagnosis1Code6char A6
      Diagnosis2Code6char A6
      Diagnosis3Code6char A6
      Diagnosis4Code6char A6
      Diagnosis5Code6char A6
      Diagnosis6Code6char A6
      Operation1ACode4char A4
      Operation1BCode4char A4
      DateofOperation101 A10
      Operation2ACode4char A4
      Operation2BCode4char A4
      DateofOperation201 A10
      Operation3ACode4char A4
      Operation3BCode4char A4
      DateofOperation301 A10
      Operation4ACode4char A4
      Operation4BCode4char A4
      DateofOperation401 A10
      AgeatMidpointofFinancialYear01 F3.0
      ContinuousInpatientStaySMR01 F5.0
      ContinuousInpatientStaySMR01incGLS F5.0
      ContinuousInpatientJourneyMarker01 A5
      CIJPlannedAdmissionCode01 F1.0
      CIJInpatientDayCaseIdentifierCode01 A2
      CIJTypeofAdmissionCode01 A2
      CIJAdmissionSpecialtyCode01 A3
      CIJDischargeSpecialtyCode01 A3
      TotalDirectCosts01 F8.2
      TotalAllocatedCosts01 F8.2
      TotalNetCosts01 F8.2
      NHSHospitalFlag01 A1
      CommunityHospitalFlag01 A1
      AlcoholRelatedAdmission01 A1
      SubstanceMisuseRelatedAdmission01 A1
      FallsRelatedAdmission01 A1
      SelfHarmRelatedAdmission01 A1
      UniqueRecordIdentifier A8.
CACHE.

rename variables
    PatUPI = chi
    UniqueRecordIdentifier = uri
    PatGenderCode = gender
    PracticeLocationCode = gpprac
    PracticeNHSBoardCode = hbpraccode
    GeoPostcodeC = postcode
    NHSBoardofResidenceCode = hbrescode
    GeoCouncilAreaCode = lca
    HSCPCode = HSCP2016
    GeoDatazone2011 = DataZone2011
    TreatmentLocationCode = location
    TreatmentNHSBoardCode = hbtreatcode
    OccupiedBedDays01 = yearstay
    SpecialtyClassificat.1497Code = spec
    SignificantFacilityCode = sigfac
    LeadConsultantHCPCode = conc
    ManagementofPatientCode = mpat
    PatientCategoryCode = cat
    AdmissionTypeCode = tadm
    AdmittedTransFromCode = adtf
    LocationAdmittedTransFromCode = admloc
    OldSMR1TypeofAdmissionCode = oldtadm
    DischargeTypeCode = disch
    DischargeTransToCode = dischto
    LocationDischargedTransToCode = dischloc
    Diagnosis1Code6char = diag1
    Diagnosis2Code6char = diag2
    Diagnosis3Code6char = diag3
    Diagnosis4Code6char = diag4
    Diagnosis5Code6char = diag5
    Diagnosis6Code6char = diag6
    Operation1ACode4char = op1a
    Operation1BCode4char = op1b
    Operation2ACode4char = op2a
    Operation2BCode4char = op2b
    Operation3ACode4char = op3a
    Operation3BCode4char = op3b
    Operation4ACode4char = op4a
    Operation4BCode4char = op4b
    ContinuousInpatientStaySMR01 = smr01_cis
    ContinuousInpatientJourneyMarker01 = cis_marker
    CIJTypeofAdmissionCode01 = newcis_admtype
    CIJAdmissionSpecialtyCode01 = CIJadm_spec
    CIJDischargeSpecialtyCode01 = CIJdis_spec
    AlcoholRelatedAdmission01 = alcohol_adm
    SubstanceMisuseRelatedAdmission01 = submis_adm
    FallsRelatedAdmission01 = falls_adm
    SelfHarmRelatedAdmission01 = selfharm_adm
    TotalDirectCosts01 = cost_direct_net
    TotalAllocatedCosts01 = cost_allocated_net
    TotalNetCosts01 = cost_total_net
    NHSHospitalFlag01 = nhshosp
    CommunityHospitalFlag01 = commhosp
    AgeatMidpointofFinancialYear01 = age
    CostsFinancialYear01 = costsfy
    CostsFinancialMonthName01 = costsfmth
    CIJPlannedAdmissionCode01 = newpattype_ciscode.


string year (a4) recid (a3) ipdc (a1) newcis_ipdc (a1) newpattype_cis (a13).
compute year = !FY.
compute recid = '01B'.

 * Recode GP Practice into a 5 digit number.
 * We assume that if it starts with a letter it's an English practice and so recode to 99995.
Do if Range(char.Substr(gpprac, 1, 1), "A", "Z").
   Compute gpprac = "99995".
End if. 
Alter Type GPprac (F5.0).

if (glsrecord EQ 'Y') recid = 'GLS'.

Do if (InpatientDayCaseIdentifierCode EQ 'IP').
   Compute ipdc = 'I'.
Else if (InpatientDayCaseIdentifierCode EQ 'DC').
   Compute ipdc = 'D'.
End If.

Do if (CIJInpatientDayCaseIdentifierCode01 EQ 'IP').
   Compute newcis_ipdc = 'I'.
Else if (CIJInpatientDayCaseIdentifierCode01 EQ 'DC').
   Compute newcis_ipdc = 'D'.
End if.


Do if (newpattype_ciscode EQ 2).
   Compute newpattype_cis = 'Maternity'.
Else if (newpattype_ciscode EQ 0).
   Compute newpattype_cis = 'Non-elective'.
Else if (newpattype_ciscode EQ 1).
   Compute newpattype_cis = 'Elective'.
End if.

 * Numeric  record_keydate1 record_keydate2 (F8.0).
 * compute record_keydate1 = Number(concat(char.substr(DateofAdmission01, 1, 4), char.substr(DateofAdmission01, 6, 2), char.substr(DateofAdmission01, 9, 2)), F8.0).
 * compute record_keydate2 = Number(concat(char.substr(DateofDischarge01, 1, 4), char.substr(DateofDischarge01, 6, 2), char.substr(DateofDischarge01, 9, 2)), F8.0).

Rename Variables (DateofAdmission01 DateofDischarge01 PatDateOfBirthC DateofOperation101 DateofOperation201 DateofOperation301 DateofOperation401
   = record_keydate1 record_keydate2 dob dateop1 dateop2 dateop3 dateop4).

alter type record_keydate1 record_keydate2 dob dateop1 dateop2 dateop3 dateop4 (SDate10).
alter type record_keydate1 record_keydate2 dob dateop1 dateop2 dateop3 dateop4 (Date12).

sort cases by uri.

save outfile = !file + 'acute_temp.zsav'
   /keep year recid record_keydate1 record_keydate2 chi gender dob gpprac hbpraccode postcode hbrescode lca HSCP2016 DataZone2011 location hbtreatcode
      yearstay ipdc spec sigfac conc mpat cat tadm adtf admloc oldtadm disch dischto dischloc diag1 diag2 diag3 diag4 diag5 diag6
      op1a op1b dateop1 op2a op2b dateop2 op3a op3b dateop3 op4a op4b dateop4 smr01_cis age cis_marker newcis_admtype newcis_ipdc
      newpattype_ciscode newpattype_cis CIJadm_spec CIJdis_spec alcohol_adm submis_adm falls_adm selfharm_adm commhosp
      cost_direct_net cost_allocated_net cost_total_net costsfy costsfmth uri
   /zcompressed.
  

* Create a file that contains uri and costsfmth and net cost. Make this look like a 'crosstab' ready for matching back To the acute_temp file. 

get file = !file + 'acute_temp.zsav'
   /keep uri cost_total_net costsfmth.

numeric costmonthnum (f2.0).

Do If (costsfmth EQ 'APRIL').
   Compute costmonthnum = 1.
Else If (costsfmth EQ 'MAY').
   Compute costmonthnum = 2.
Else If (costsfmth EQ 'JUNE').
   Compute costmonthnum = 3.
Else If (costsfmth EQ 'JULY').
   Compute costmonthnum = 4.
Else If (costsfmth EQ 'AUGUST').
   Compute costmonthnum = 5.
Else If (costsfmth EQ 'SEPTEMBER').
   Compute costmonthnum = 6.
Else If (costsfmth EQ 'OCTOBER').
   Compute costmonthnum = 7.
Else If (costsfmth EQ 'NOVEMBER').
   Compute costmonthnum = 8.
Else If (costsfmth EQ 'DECEMBER').
   Compute costmonthnum = 9.
Else If (costsfmth EQ 'JANUARY').
   Compute costmonthnum = 10.
Else If (costsfmth EQ 'FEBRUARY').
   Compute costmonthnum = 11.
Else If (costsfmth EQ 'MARCH').
   Compute costmonthnum = 12.
End If.


do repeat x = col1 To col12
   /y = 1 To 12.
   compute x = 0.
   if (y = costmonthnum) x = cost_total_net.
end repeat.

rename variables (col1 col2 col3 col4 col5 col6 col7 col8 col9 col10 col11 col12 = 
                  apr_cost may_cost jun_cost jul_cost aug_cost sep_cost 
                  oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost).

aggregate outfile = !file + 'acute_monthly_costs_by_uri.sav'
   /Presorted
   /break uri
   /apr_cost may_cost jun_cost jul_cost aug_cost sep_cost oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost =
       Sum(apr_cost may_cost jun_cost jul_cost aug_cost sep_cost oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost).


* Create a file that contains uri and costsfmth and yearstay. Make this look like a 'crosstab' ready for matching back To the acute_temp file. 

get file = !file + 'acute_temp.zsav'
   /keep uri yearstay costsfmth.

numeric costmonthnum (f2.0).
Do If (costsfmth EQ 'APRIL').
   Compute costmonthnum = 1.
Else If (costsfmth EQ 'MAY').
   Compute costmonthnum = 2.
Else If (costsfmth EQ 'JUNE').
   Compute costmonthnum = 3.
Else If (costsfmth EQ 'JULY').
   Compute costmonthnum = 4.
Else If (costsfmth EQ 'AUGUST').
   Compute costmonthnum = 5.
Else If (costsfmth EQ 'SEPTEMBER').
   Compute costmonthnum = 6.
Else If (costsfmth EQ 'OCTOBER').
   Compute costmonthnum = 7.
Else If (costsfmth EQ 'NOVEMBER').
   Compute costmonthnum = 8.
Else If (costsfmth EQ 'DECEMBER').
   Compute costmonthnum = 9.
Else If (costsfmth EQ 'JANUARY').
   Compute costmonthnum = 10.
Else If (costsfmth EQ 'FEBRUARY').
   Compute costmonthnum = 11.
Else If (costsfmth EQ 'MARCH').
   Compute costmonthnum = 12.
End If.

do repeat x = col1 To col12
   /y = 1 To 12.
   compute x = 0.
   if (y = costmonthnum) x = yearstay.
end repeat.

rename variables (col1 col2 col3 col4 col5 col6 col7 col8 col9 col10 col11 col12 =
   apr_beddays may_beddays jun_beddays jul_beddays aug_beddays sep_beddays
   oct_beddays nov_beddays dec_beddays jan_beddays feb_beddays mar_beddays).

aggregate outfile = !file + 'acute_monthly_beddays_by_uri.sav'
   /Presorted
   /break uri
   /apr_beddays may_beddays jun_beddays jul_beddays aug_beddays sep_beddays oct_beddays nov_beddays dec_beddays jan_beddays feb_beddays mar_beddays =
       Sum(apr_beddays may_beddays jun_beddays jul_beddays aug_beddays sep_beddays oct_beddays nov_beddays dec_beddays jan_beddays feb_beddays mar_beddays).


* Match both these files back To the main acute file and then create totals adding across the months for each of the costs 
 and yearstay variables.  
* Need To reduce each uri To one row only. All columns will have the same information except for the costs month variable.

match files file = !file + 'acute_temp.zsav'
   /table = !file + 'acute_monthly_beddays_by_uri.sav'
   /table = !file + 'acute_monthly_costs_by_uri.sav'
   /by uri.
execute.

aggregate outfile = *
   /Presorted
   /break uri
   /year recid record_keydate1 record_keydate2 chi gender dob gpprac hbpraccode postcode hbrescode lca HSCP2016 DataZone2011 location hbtreatcode
      yearstay ipdc spec sigfac conc mpat cat tadm adtf admloc oldtadm disch dischto dischloc diag1 diag2 diag3 diag4 diag5 diag6
      op1a op1b dateop1 op2a op2b dateop2 op3a op3b dateop3 op4a op4b dateop4 smr01_cis age cis_marker newcis_admtype newcis_ipdc
      newpattype_ciscode newpattype_cis CIJadm_spec CIJdis_spec alcohol_adm submis_adm falls_adm selfharm_adm commhosp
      apr_beddays may_beddays jun_beddays jul_beddays aug_beddays sep_beddays oct_beddays nov_beddays dec_beddays jan_beddays feb_beddays mar_beddays
      apr_cost may_cost jun_cost jul_cost aug_cost sep_cost oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost =
       First(year recid record_keydate1 record_keydate2 chi gender dob gpprac hbpraccode postcode hbrescode lca HSCP2016 DataZone2011 location hbtreatcode
      yearstay ipdc spec sigfac conc mpat cat tadm adtf admloc oldtadm disch dischto dischloc diag1 diag2 diag3 diag4 diag5 diag6
      op1a op1b dateop1 op2a op2b dateop2 op3a op3b dateop3 op4a op4b dateop4 smr01_cis age cis_marker newcis_admtype newcis_ipdc
      newpattype_ciscode newpattype_cis CIJadm_spec CIJdis_spec alcohol_adm submis_adm falls_adm selfharm_adm commhosp
      apr_beddays may_beddays jun_beddays jul_beddays aug_beddays sep_beddays oct_beddays nov_beddays dec_beddays jan_beddays feb_beddays mar_beddays
      apr_cost may_cost jun_cost jul_cost aug_cost sep_cost oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost).


compute yearstay = apr_beddays + may_beddays + jun_beddays + jul_beddays + aug_beddays + sep_beddays + oct_beddays + nov_beddays + dec_beddays + jan_beddays + feb_beddays + mar_beddays.
compute cost_total_net = apr_cost + may_cost + jun_cost + jul_cost + aug_cost + sep_cost + oct_cost + nov_cost + dec_cost + jan_cost + feb_cost + mar_cost.


* Create the SMRtype variable that was first introduced for 2013/14. Note that the line number
* is required for sorting the acute records, so SMRType will be created here. An extract has been taking by URI and LINE NO and this 
* needs To be matched on first. 


match files file = *
   /table = !file + 'acute_line_number_by_uri_20' + !FY +'.zsav'
   /by uri.
execute.

* Create the column SMRType.
string SMRType(a10).
Do if (recid EQ '01B').
   Do if (lineno NE '330').
      If ipdc EQ 'I' SMRType = 'Acute-IP'.
      If ipdc EQ 'D' SMRType = 'Acute-DC'.
   Else If (lineno EQ '330' and ipdc EQ 'I').
      Compute SMRType = 'GLS-IP'.
   End If.
Else If (recid EQ 'GLS').
   Compute SMRType = 'GLS-IP'.
End If.
frequencies SMRType.

* Calculate the length of stay 'manually'. Due To the grain of the data for costs and the grain of the non-cost 
* data, too large a file is created from Business Objects (data since the start of the catalogue). This is not 
* suitable for extracting, sorting and finally matching as the acute data in the data mart is currently in excess 
* of 40 million records and will only continue To grow in size.
* DH, September 2016.  

Numeric stay (F7.0).
Compute stay = Datediff(record_keydate2, record_keydate1, "days").

 * Put record_keydate back into numeric.
Compute record_keydate1 = xdate.mday(record_keydate1) + 100 * xdate.month(record_keydate1) + 10000 * xdate.year(record_keydate1).
Compute record_keydate2 = xdate.mday(record_keydate2) + 100 * xdate.month(record_keydate2) + 10000 * xdate.year(record_keydate2).
alter type record_keydate1 record_keydate2 (F8.0).

frequencies stay yearstay.

sort cases by chi record_keydate1.

save outfile = !file + 'acute_for_source-20' + !FY + '.zsav'
   /keep year recid record_keydate1 record_keydate2 SMRType chi gender dob gpprac hbpraccode postcode hbrescode lca HSCP2016 DataZone2011 location hbtreatcode
      yearstay stay ipdc spec sigfac conc mpat cat tadm adtf admloc oldtadm disch dischto dischloc diag1 diag2 diag3 diag4 diag5 diag6
      op1a op1b dateop1 op2a op2b dateop2 op3a op3b dateop3 op4a op4b dateop4 smr01_cis age cis_marker newcis_admtype newcis_ipdc
      newpattype_ciscode newpattype_cis CIJadm_spec CIJdis_spec alcohol_adm submis_adm falls_adm selfharm_adm commhosp
      cost_total_net
      apr_beddays may_beddays jun_beddays jul_beddays aug_beddays sep_beddays oct_beddays nov_beddays dec_beddays jan_beddays feb_beddays mar_beddays
      apr_cost may_cost jun_cost jul_cost aug_cost sep_cost oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost uri
    /zcompressed.

get file = !file + 'acute_for_source-20' + !FY + '.zsav'.

* Housekeeping.
erase file = !file + 'acute_temp.zsav'.
erase file = !file + 'acute_monthly_beddays_by_uri.sav'.
erase file = !file + 'acute_monthly_costs_by_uri.sav'.
erase file = !file + 'acute_line_number_by_uri_20' + !FY +'.zsav'.

 * zip up the raw data.
Host Command = ["zip -m '" + !Extracts + "Acute-episode-level-extract-20" + !FY + ".zip' '" +
   !Extracts + "Acute-episode-level-extract-20" + !FY + ".csv'"].
Host Command = ["zip -m '" + !Extracts + "Acute-line-number-by-URI-20" + !FY + ".zip' '" + !Extracts + "Acute-line-number-by-URI-20" + !FY + ".csv'"].


