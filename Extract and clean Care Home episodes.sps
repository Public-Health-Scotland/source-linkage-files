* Encoding: UTF-8.

* Pass.sps needs updating to include a new macro !connect_sc with the correct details for SC connection.
Insert file = "pass.sps" Error = Stop.

Define !sc_extracts()
    "/conf/social-care/05-Analysts/All Sandpit Extracts/"
!EndDefine.

define !output_dir()
    "/conf/sourcedev/James/sc_test_extracts/"
!enddefine.

* This is just needed for the CH lookup which is used for repairing names where possible.
* Need to re-work this to use a generic lookup, currently the lookup is filtered to only CHs which were open in the given year.
Define !FY()
    "1819"
!EndDefine.

* Extract files - "home".
Define !Extracts()
    !Quote(!Concat("/conf/sourcedev/Source Linkage File Updates/", !Unquote(!Eval(!FY)), "/Extracts/"))
!EndDefine.

* Care Home data.
get file = !sc_extracts + "CH/CH_allyears.sav"
    /Keep ch_name ch_postcode sending_location social_care_id financial_year financial_quarter period ch_provider reason_for_admission nursing_care_provision ch_admission_date ch_discharge_date age.

Variable width ALL (15).

alter type 
    sending_location (A3)
    financial_year (F4.0)
    financial_quarter (F1.0)
    period (A6)
    social_care_id (A10)
    nursing_care_provision (F1.0)
    reason_for_admission (F2.0)
    ch_provider (F1.0)
    ch_postcode (A8)
    ch_name (A73).

sort cases by sending_location social_care_id period ch_admission_date, ch_discharge_date.

* Match on the demographics data (chi, gender, dob and postcode).
match files file = *
    /table = !Extracts_Alt + "Social Care Demographics lookup.zsav"
    /by sending_location social_care_id.

* Correct Postcode formatting.
* Remove any postcodes which are length 3 or 4 as these can not be valid (not a useful dummy either).
If range(Length(ch_postcode), 3, 4) ch_postcode = "".

* Remove spaces which deals with any 8-char postcodes.
* Shouldn't get these but we read all in as 8-char just incase.
* Also make it upper-case.
Compute ch_postcode = Replace(Upcase(ch_postcode), " ", "").

* Add spaces to create a 7-char postcode.
Loop if range(Length(ch_postcode), 5, 6).
    Compute #current_length = Length(ch_postcode).
    Compute ch_postcode = Concat(char.substr(ch_postcode, 1,  #current_length - 3), " ", char.substr(ch_postcode,  #current_length - 2, 3)).
End Loop.

alter type ch_postcode (A7).

*******************************************************************************************************.
* Tidy up care home names.
* Use custom Python as it's twice as quick as built in SPSS.
Begin Program.
import spss

# Open the dataset with write access
# Read in the CareHomeNames, which must be the first variable "spss.Cursor([0]..."
cur = spss.Cursor([0], accessType = 'w')

# Create a new variable, string length 73
cur.AllocNewVarsBuffer(80)
cur.SetOneVarNameAndType('ch_name_tidy', 73)
cur.CommitDictionary()

# Loop through every case and write the tidied care home name
for i in range(cur.GetCaseCount()):
    # Read a case and save the care home name
    # We need to strip trailing spaces
    care_home_name = cur.fetchone()[0].rstrip()
    
    # Write the tidied name to the SPSS dataset
    cur.SetValueChar('ch_name_tidy', str(care_home_name).title())
    cur.CommitCase()

# Close the connection to the dataset
cur.close()
End Program.

* Overwrite the original care home name.
Compute ch_name = ch_name_tidy.

* First fill in any blank care_home names where we have a correct postcode.
Sort cases by ch_postcode.
match files
    /file = *
    /Table = !Extracts + "Care_home_name_lookup-20" + !FY + ".sav"
    /Rename (CareHomePostcode CareHomeName = ch_postcode ch_name_real)
    /Drop ch_name_tidy CareHomeCouncilName MainClientGroup Sector CareHomeCouncilAreaCode
    /By ch_postcode.

If ch_name = "" and ch_name_real NE "" ch_name = ch_name_real.

Sort Cases by ch_postcode ch_name.
match files
    /file = *
    /Table = !Extracts + "Care_home_name_lookup-20" + !FY + ".sav"
    /Rename (CareHomePostcode CareHomeName = ch_postcode ch_name)
    /In = AccurateData1
    /Drop CareHomeCouncilName MainClientGroup Sector CareHomeCouncilAreaCode
    /By ch_postcode ch_name.

* Guess some possible names for ones which don't match the lookup.
String TestName1 TestName2(A73).
Do if AccurateData1 = 0.
    * Try adding 'Care Home' or 'Nursing Home' on the end.
    Compute TestName1 = Concat(Rtrim(ch_name), " Care Home").
    Compute TestName2 = Concat(Rtrim(ch_name), " Nursing Home").
    * If they have the above name ending already, try removing / replacing it.
    Do if char.index(ch_name, "Care Home") > 1.
        Compute TestName1 = Strunc(ch_name, char.index(ch_name, "Care Home") - 1).
        Compute TestName2 = Replace(ch_name, "Care Home", "Nursing Home").
    Else if char.index(ch_name, "Nursing Home") > 1.
        Compute TestName1 = Strunc(ch_name, char.index(ch_name, "Nursing Home") - 1).
        Compute TestName2 = Replace(ch_name, "Nursing Home", "Care Home").
    Else if char.index(ch_name, "Nursing") > 1.
        Compute TestName1 = Strunc(ch_name, char.index(ch_name, "Nursing") - 1).
        Compute TestName2 = Replace(ch_name, "Nursing", "Care Home").
        * If ends in brackets replace it.
    Else if char.index(ch_name, "(") > 1.
        Compute TestName1 = Concat(Rtrim(Strunc(ch_name, char.index(ch_name, "(") - 1)), " Care Home").
        Compute TestName2 = Concat(Rtrim(Strunc(ch_name, char.index(ch_name, "(") - 1)), " Nursing Home").
    End if.
End if.

*******************************************************************************************************.
* Check if TestName1 makes the record match the lookup.
Sort Cases by ch_postcode TestName1.
match files
    /file = *
    /Table = !Extracts + "Care_home_name_lookup-20" + !FY + ".sav"
    /Rename (CareHomeName CareHomePostcode = TestName1 ch_postcode)
    /In = TestName1Correct
    /By ch_postcode TestName1.

*******************************************************************************************************.
* Check if TestName2 makes the record match the lookup.
Sort Cases by ch_postcode TestName2.
match files
    /file = *
    /Table = !Extracts + "Care_home_name_lookup-20" + !FY + ".sav"
    /Rename (CareHomeName CareHomePostcode = TestName2 ch_postcode)
    /In = TestName2Correct
    /Drop CareHomeCouncilName MainClientGroup Sector CareHomeCouncilAreaCode
    /By ch_postcode TestName2.

* If the name was correct take this as the new one, don't do it if both were correct.
Do If TestName1Correct = 1 AND TestName2Correct = 0.
    Compute ch_name = TestName1.
Else If TestName2Correct = 1 AND TestName1Correct = 0.
    Compute ch_name = TestName2.
End If.

*******************************************************************************************************.
* See which match now.
Sort Cases by ch_postcode ch_name.
match files
    /file = *
    /Table = !Extracts + "Care_home_name_lookup-20" + !FY + ".sav"
    /Rename (CareHomePostcode CareHomeName = ch_postcode ch_name)
    /In = AccurateData2
    /Drop CareHomeCouncilName MainClientGroup Sector CareHomeCouncilAreaCode
    /By ch_postcode ch_name.

* Highlight where an episode has at least one row of good data.
aggregate
    /break sending_location chi ch_admission_date
    /Any_accurate = max(AccurateData2).

* Apply the good data to other rows in the episode.
sort cases by sending_location chi ch_admission_date (A) AccurateData2 (D).

aggregate
    /presorted
    /break sending_location chi ch_admission_date
    /real_ch_name = first(ch_name)
    /real_ch_postcode = first(ch_postcode).

Do if AccurateData2 = 0 AND real_ch_name NE "".
    Compute ch_name = real_ch_name.
    Compute ch_postcode = real_ch_postcode.
End if.

crosstabs AccurateData2 by Any_accurate.
* Fixes around 8000 rows.

Delete Variables TestName1 TestName2 TestName1Correct TestName2Correct AccurateData1 AccurateData2 Any_accurate ch_name_real real_ch_name real_ch_postcode.

* Sort into reverse order so we can use lag() to fill in below.
sort cases by sending_location chi ch_admission_date financial_year financial_quarter (D).

* Correct missing nursing_care_provision.
* Sometimes nursing_care provision is missing on the first record but present on the next, in these cases fill it in.
Do If lag(sending_location) = sending_location AND lag(chi) = chi.
    Do If lag(ch_admission_date) = ch_admission_date AND sysmis(nursing_care_provision) AND Not(sysmis(lag(nursing_care_provision))).
        Compute nursing_care_provision = lag(nursing_care_provision).
    End If.
End if.

* Sort back to a sensible order.
sort cases by sending_location chi ch_admission_date financial_year financial_quarter ch_discharge_date.

* Work out the record date, which is the last day of the quarter e.g. 2017 Q4 = 2017-03-31.
* SPSS uses US quarters (Q1 = Jan-Apr etc.) so adjust the dates so it works for our FY quarters.
Numeric record_date (Date12).
compute record_date = Datesum(Datesum(date.qyr(financial_quarter, financial_year), 6, "months"), -1, "days").

* Highlight episodes where the ch_provider changes within submission quarters.
aggregate
    /Break record_date sending_location social_care_id ch_admission_date nursing_care_provision
    /min_provider = min(ch_provider)
    /max_provider = max(ch_provider).

* If the reason_for_admission has changed within a quarter (Duplicate) make it 6 (Other).
* If min and max are the same all values must be the same, otherwise at least one must be different.
If min_provider NE max_provider ch_provider = 6.

* Sort to ensure the latest submitted records come last.
Sort cases by sending_location social_care_id chi ch_admission_date ch_provider nursing_care_provision record_date.

* Aggregate to episode level, splitting episodes where the ch_provider or nursing_care changes.
aggregate outfile = *
    /Break sending_location social_care_id chi ch_admission_date ch_provider nursing_care_provision
    /gender dob postcode = first(gender dob postcode)
    /ch_discharge_date = last(ch_discharge_date)
    /record_date = Max(record_date)
    /sc_latest_submission = Max(period)
    /ch_name = last(ch_name)
    /ch_postcode = last(ch_postcode)
    /reason_for_admission = last(reason_for_admission).

sort cases by sending_location social_care_id ch_admission_date record_date.

* Highlight the duplicate records.
* These are conflicting records submitted in the same quarter with the same admission dates.
Compute Duplicate = 0.
Do If lag(sending_location) = sending_location AND lag(social_care_id) = social_care_id AND lag(ch_admission_date) = ch_admission_date AND lag(record_date) = record_date.
    Compute Duplicate = 1.
End if.

* Count records (where episodes are split because of changes in ch_provider or nursing_care).
* Create a marker to link split episodes together.
Compute record_count = 1.
Compute scem = 1. /*scem = Social Care Episode Marker - name hopefully to be changed */.

* If the episode is split keep the marker the same and increase the record count (unless it's flagged as a duplicate).
Do If lag(sending_location) = sending_location AND lag(social_care_id) = social_care_id AND lag(ch_admission_date) = ch_admission_date AND lag(record_date) NE record_date.
    Compute record_count = lag(record_count) + 1.
    Compute scem = lag(scem).
Else if lag(sending_location) = sending_location AND lag(social_care_id) = social_care_id.
    Do if duplicate NE 1.
        Compute scem = lag(scem) + 1.
    Else.
        Compute scem = lag(scem).
    End if.
End if.

sort cases by sending_location social_care_id scem record_date.
* Highlight the last episode of the scem to take the discharge date from.
* Can't use aggregate as that will ignore missing dates.
add files file = *
    /by sending_location social_care_id scem record_date
    /last = Last_record.

If last_record last_ch_discharge_date = ch_discharge_date.

* For all episodes set the sc_dates to be the first admission and last discharge (these are the actual dates for the episode).
* This will only be useful for split episodes, in the normal case they will match the single line episode dates.
* Also add on the maximum number of records for each episode so we can identify the split episodes.
aggregate
    /break sending_location social_care_id scem
    /n_records = max(record_count)
    /sc_date_1 = min(ch_admission_date)
    /sc_date_2 = max(last_ch_discharge_date).

* Where the episodes are split (> 1 record) change the admission and discharge dates to the start and end of the quarters using the record_date as appropriate.
Do if n_records > 1.
    Do if record_count = 1.
        Compute ch_discharge_date = record_date.
    Else if record_count = n_records.
        Compute ch_admission_date = lag(record_date).
    Else.
        Compute ch_discharge_date = record_date.
        Compute ch_admission_date = lag(record_date).
    End if.
End if.

Rename Variables
    ch_admission_date = record_keydate1
    ch_discharge_date = record_keydate2
    reason_for_admission = ch_adm_reason
    nursing_care_provision = ch_nursing.

Value Labels ch_adm_reason
    1 'Respite'
    2 'Intermediate Care (includes Step Up/Step Down)'
    3 'Emergency'
    4 'Palliative Care'
    5 'Dementia'
    6 'Elderly Mental Health'
    7 'Learning Disability'
    8 'High Dependency'
    9 'Choice'
    10 'Other'.

Value Labels ch_nursing
    0 'No'
    1 'Yes'.

Value Labels ch_provider
    1 'Local Authority / Health & Social Care Partnership'
    2 'Private'
    3 'Other Local Authority'
    4 'Third Sector'
    5 'NHS Board'
    6 'Other'.

save outfile = !Extracts_Alt + "All Care Home episodes.zsav"
    /Keep chi
    gender
    dob
    postcode
    sending_location
    social_care_id
    ch_name
    ch_postcode
    record_keydate1
    record_keydate2
    sc_date_1
    sc_date_2
    ch_provider
    ch_nursing
    ch_adm_reason
    scem
    sc_latest_submission
    /zcompressed.
get file = !Extracts_Alt + "All Care Home episodes.zsav".

