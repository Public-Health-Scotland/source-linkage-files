* Encoding: UTF-8.

* Pass.sps needs updating to include a new macro !connect_sc with the correct details for SC connection.
*Insert file = "pass.sps" Error = Stop.

Define !sc_extracts()
    "/conf/social-care/05-Analysts/All Sandpit Extracts/"
!EndDefine.

* Care Home data.
get file = !sc_extracts + "CH/CH_allyears.sav"
    /Keep ch_name ch_postcode sending_location social_care_id financial_year financial_quarter period ch_provider reason_for_admission nursing_care_provision ch_admission_date ch_discharge_date age.

Variable width ALL (15).

* Clean up types.
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

* Correct the period for 2017.
If financial_year = 2017 and financial_quarter = 4 period = "2017Q4".

* Work out the record date, which is the last day of the quarter e.g. 2017 Q4 = 2017-03-31.
* SPSS uses US quarters (Q1 = Jan-Apr etc.) so adjust the dates so it works for our FY quarters.
Numeric record_date (Date11).
compute record_date = Datesum(Datesum(date.qyr(financial_quarter, financial_year), 6, "months"), -1, "days").

* Filter out any episodes where the admission date is missing.
select if not(sysmis(ch_admission_date)).

* Filter out any episodes where the discharge date is before the admission date.
Compute dis_before_adm = ch_admission_date > ch_discharge_date and not(sysmis(ch_discharge_date)).
crosstabs dis_before_adm by period.
* April 2021: 1 record in 2019 Q4 submission, shouldn't be many / any of these, report to DM.
select if not dis_before_adm.

sort cases by sending_location social_care_id period ch_admission_date ch_discharge_date.

* Match on the demographics data (chi, gender, dob and postcode).
match files file = *
    /table = !SC_dir + "sc_demograpics_lookup_" + !LatestUpdate + ".zsav"
    /by sending_location social_care_id.

* Correct Postcode formatting.
* Remove any postcodes which are length 3 or 4 as these can not be valid (not a useful dummy either).
If range(Length(ch_postcode), 3, 4) ch_postcode = "".

* Remove spaces which deals with any 8-char postcodes.
* Shouldn't get these but we read all in as 8-char just in case.
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

* Fix some obvious typos.
* Double (or more spaces).
Loop If char.Index(ch_name, "  ") > 0.
    compute ch_name = replace(ch_name, "  ", " ").
End Loop.

* No space before brackets.
Do if char.Index(ch_name, "(") > 0.
    Do if char.substr(ch_name, char.Index(ch_name, "(") - 1, 1) NE " ".
        Compute ch_name = replace(ch_name, "(", " (").
    End if.
End if.

* Compare the initial data to the lookup.
Sort Cases by ch_postcode ch_name.
match files
    /file = *
    /Table = !Year_Extracts_dir + "Care_home_name_lookup-20" + !FY + ".sav"
    /Rename (CareHomePostcode CareHomeName = ch_postcode ch_name)
    /In = AccurateData0
    /Drop CareHomeCouncilAreaCode
    /By ch_postcode ch_name.
frequencies AccurateData0.

* Check what the name should be if we just look at the Care home postcode.
Sort cases by ch_postcode.
match files
    /file = *
    /Table = !Year_Extracts_dir + "Care_home_name_lookup-20" + !FY + ".sav"
    /Rename (CareHomePostcode CareHomeName = ch_postcode ch_name_real)
    /Drop ch_name_tidy CareHomeCouncilAreaCode
    /By ch_postcode.

* Fill in any remaining blank care_home names where we have a correct postcode.
* The lookup also counts how many Care Home names are associated with a postcode - ever an in the the given FY.
String Changed_name (A100).
Compute Changed_name = "No Change".
Do if n_at_postcode = 1.
    Compute changed_name = "Single name for postcode in lookup".
    If ch_name = "" changed_name = "Single name for postcode in lookup (submitted was blank)".
    Compute ch_name = ch_name_real.
Else if n_in_fy = 1.
    Do if ch_name = "".
        Compute ch_name = ch_name_real.
        Compute changed_name = "Single name open in " + !FY +  " for postcode (submitted was blank)".
    Else if Number(!altFY, F4.0) = financial_year.
        Compute ch_name = ch_name_real.
        Compute changed_name = "Single name open in " + !FY +  " for postcode (not blank but record submitted in " + !FY + ")".
    End if.
End if.
Frequencies changed_name.

* Now fill in any where the provided name is a substring of the real name.
* TODO - adjust the lookup to provide multiple names e.g. ch_name, ch_name2, ch_name3 - use those here for this fix.
Do if ch_name NE ch_name_real and ch_name_real NE "" and ch_name NE "".
    Compute name_is_subset = char.index(ch_name_real, ch_name) > 0.
    * And any where the supplied name contains the real name plus some extra bits.
    Compute name_is_extra = char.index(ch_name, ch_name_real) > 0.
End if.

temporary.
select if ch_name NE ch_name_real.
Frequencies name_is_subset name_is_extra.

If name_is_subset or name_is_extra ch_name = ch_name_real.

* Compare the current data to the lookup and check what (if any) improvements have been made.
Sort Cases by ch_postcode ch_name.
match files
    /file = *
    /Table = !Year_Extracts_dir + "Care_home_name_lookup-20" + !FY + ".sav"
    /Rename (CareHomePostcode CareHomeName = ch_postcode ch_name)
    /In = AccurateData1
    /Drop CareHomeCouncilAreaCode
    /By ch_postcode ch_name.
crosstabs AccurateData0 by AccurateData1.

* Guess some possible names for ones which don't match the lookup.
String TestName1 TestName2 (A73).
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
    /Table = !Year_Extracts_dir + "Care_home_name_lookup-20" + !FY + ".sav"
    /Rename (CareHomeName CareHomePostcode = TestName1 ch_postcode)
    /In = TestName1Correct
    /By ch_postcode TestName1.

*******************************************************************************************************.
* Check if TestName2 makes the record match the lookup.
Sort Cases by ch_postcode TestName2.
match files
    /file = *
    /Table = !Year_Extracts_dir + "Care_home_name_lookup-20" + !FY + ".sav"
    /Rename (CareHomeName CareHomePostcode = TestName2 ch_postcode)
    /In = TestName2Correct
    /Drop CareHomeCouncilAreaCode
    /By ch_postcode TestName2.

* If the name was correct take this as the new one, don't do it if both were correct.
Do If TestName1Correct = 1 and TestName2Correct = 0.
    Compute ch_name = TestName1.
Else If TestName2Correct = 1 and TestName1Correct = 0.
    Compute ch_name = TestName2.
End If.

* Find names where they are very simlar to more common names which have been supplied for the same postcode.
aggregate
    /break ch_postcode ch_name
    /n_records_using_name = n.

aggregate
    /break ch_postcode
    /max_records_using_name = max(n_records_using_name).

String best_guess_name (A73).
If max_records_using_name = n_records_using_name best_guess_name = ch_name.

aggregate outfile = * mode addvariables overwrite yes
    /break ch_postcode
    /best_guess_name= max(best_guess_name).

 * Python program which creates a similarity ratio.
Begin Program.
from difflib import SequenceMatcher

def similarity_ratio(s1, s2):
    if s1 == "":
        ratio = 0
    elif s1 == s2:
        ratio = 1
    else:
        seq = SequenceMatcher(lambda x: x==" ", s1.lower(), s2.lower())
        if seq.real_quick_ratio() >= 0.95:
            ratio = seq.ratio()
        else:
            ratio = 0
    return(ratio)
End Program.

SPSSINC TRANS result = ratio type = 0
    /formula similarity_ratio(ch_name, best_guess_name).

If ratio >= 0.95 ch_name = best_guess_name.

* Fill in more blank care home names by looking for cases where we have:.
* A postcode with a commonly occuring name and some blanks.
* in these cases use the name to fill in the blanks.

sort cases by ch_postcode ch_name.
Compute non_blank_name = ch_name NE "".
aggregate
    /presorted
    /break ch_postcode
    /n_pc_records = sum(non_blank_name).

aggregate
    /presorted
    /break ch_postcode ch_name
    /n_ch_records = sum(non_blank_name).

Do if n_pc_records > 20.
    Compute name_proportion = n_ch_records / n_pc_records.
End if.

sort cases by ch_postcode name_proportion (D).

String old_name (A100).
Do if ch_postcode = lag(ch_postcode) and lag(name_proportion) >= 0.8.
    Do if (ch_name = "" or lag(name_proportion) >= 0.95) and ch_name NE lag(ch_name).
        Compute old_name = ch_name.
        Compute ch_name = lag(ch_name).
        Compute name_proportion = lag(name_proportion).
    End if.
End if.
Temporary.
Select if old_name ne ch_name and name_proportion >= 0.8.
crosstabs old_name by ch_name.

*******************************************************************************************************.
* See which match now.
Sort Cases by ch_postcode ch_name.
match files
    /file = *
    /Table = !Year_Extracts_dir + "Care_home_name_lookup-20" + !FY + ".sav"
    /Rename (CareHomePostcode CareHomeName = ch_postcode ch_name)
    /In = AccurateData2
    /Drop CareHomeCouncilAreaCode
    /By ch_postcode ch_name.
crosstabs AccurateData1 by AccurateData2 by AccurateData0.

* Refresh the variables to drop all the ones we no longer need.
save outfile = !SC_dir + "TEMP-Care_Home_end_of_name_changes.zsav"
    /keep sending_location social_care_id chi ch_name ch_postcode ch_admission_date ch_discharge_date financial_year financial_quarter period record_date ch_provider reason_for_admission nursing_care_provision age gender dob postcode
    /zcompressed.
get file =  !SC_dir + "TEMP-Care_Home_end_of_name_changes.zsav".

* Correct missing nursing_care_provision.
* Sort into reverse order so we can use lag() to fill in below.
sort cases by sending_location social_care_id ch_admission_date period (D).

* Sometimes nursing_care provision is missing on the first record but present on the next, in these cases fill it in.
Do If lag(sending_location) = sending_location and lag(social_care_id) = social_care_id.
    Do If lag(ch_admission_date) = ch_admission_date and sysmis(nursing_care_provision) and Not(sysmis(lag(nursing_care_provision))).
        Compute nursing_care_provision = lag(nursing_care_provision).
    End If.
End if.

* Sort back to a sensible order.
sort cases by sending_location social_care_id ch_admission_date period ch_discharge_date.

* Highlight episodes where the ch_provider changes within submission quarters.
aggregate
    /Break period sending_location social_care_id ch_admission_date nursing_care_provision
    /min_provider = min(ch_provider)
    /max_provider = max(ch_provider).

* If the reason_for_admission has changed within a quarter (Duplicate) make it 6 (Other).
* If min and max are the same all values must be the same, otherwise at least one must be different.
If min_provider NE max_provider ch_provider = 6.

* Where we have multiple social care IDs from the same sending location for a single CHI, merge the IDs into the first one.
* Apply the latest submitted social_care_id to all instances of the same CHI within a single sending_location.
sort cases by chi sending_location period.
aggregate
    /Presorted
    /Break chi sending_location
    /latest_sc_id = last(social_care_id).

Do if chi NE "" and social_care_id NE latest_sc_id.
    Compute changed_sc_id = 1.
    Compute social_care_id = latest_sc_id.
End if.

Frequencies changed_sc_id.

save outfile = !SC_dir + "TEMP-Care_Home_pre-aggregate.zsav"
    /Keep chi sending_location social_care_id ch_name ch_postcode ch_admission_date ch_discharge_date record_date period All
    /Drop min_provider max_provider latest_sc_id changed_sc_id
    /zcompressed.
get file = !SC_dir + "TEMP-Care_Home_pre-aggregate.zsav".

* Sort to ensure the latest submitted records come last.
sort cases by chi sending_location social_care_id ch_admission_date period nursing_care_provision ch_provider.

* Remove exact duplicates as they will be removed in the aggregate anyway and they make the below calculations more complicated.
aggregate
    /presorted
    /break chi sending_location social_care_id ch_admission_date period nursing_care_provision ch_provider
    /Duplicate_count = n.
*Frequencies Duplicate_count.
Select if Duplicate_count = 1.

aggregate
    /presorted
    /break chi sending_location social_care_id ch_admission_date period
    /Duplicate_submission_count = n.

Compute Duplicate = Duplicate_submission_count > 1.

* Create a counter to track changes in Nursing Care / CH provider to use in the aggregate.
* This deals with cases where the NC changes more than once.
Compute episode_counter = 1.
Do if lag(sending_location) = sending_location and lag(social_care_id) = social_care_id.
    Do if ch_admission_date = lag(ch_admission_date).
        Do if Duplicate.
            Compute episode_counter = lag(episode_counter) + 1.
            If lag(Duplicate, 2) and ch_provider = lag(ch_provider, 2) and nursing_care_provision = lag(nursing_care_provision, 2) episode_counter = lag(episode_counter, 2).
        Else.
            Compute episode_counter = lag(episode_counter).
            If ch_provider ne lag(ch_provider) or nursing_care_provision ne lag(nursing_care_provision) episode_counter = lag(episode_counter) + 1.
        End if.
    End if.
End if.

* Track when the discharge date is missing (open record), if this is the latest submission we need to preserve it.
String dis_date_missing (A6).
If sysmis(ch_discharge_date) dis_date_missing = period.

Missing values ch_name ch_postcode("").
* Aggregate to episode level, splitting episodes where the ch_provider or nursing_care changes.
aggregate outfile = *
    /Break chi sending_location social_care_id ch_admission_date ch_provider nursing_care_provision episode_counter
    /ch_discharge_date = last(ch_discharge_date)
    /record_date = max(record_date)
    /sc_latest_submission = max(period)
    /lastest_submission_dis_missing = max(dis_date_missing)
    /ch_name = last(ch_name)
    /ch_postcode = last(ch_postcode)
    /reason_for_admission = last(reason_for_admission)
    /gender dob postcode = first(gender dob postcode)
    /Duplicate = max(duplicate).

* Check the discharge date and if there was a missing date in the latest submission use that.
* However some (~1/3) episodes have subsequent episodes starting on the same day, in this case keep the episode closed.
sort cases by chi sending_location social_care_id (A) ch_admission_date record_date (D) .
* Find cases where dis was missing in last submission but isn't after the aggregate.
Do if lastest_submission_dis_missing = sc_latest_submission and not sysmis(ch_discharge_date).
    * Clear case where the dis 'should' be missing but this would result in an overlap.
    Do if lag(sending_location) = sending_location and lag(social_care_id) = social_care_id and lag(ch_admission_date) = ch_discharge_date.
        Compute corrected_open_end_date = 0.
    Else.
        * Usual case (2/3) where we 're-open' the episode and ignore the dis date which was supplied earlier.
        Compute corrected_open_end_date = 1.
        Compute ch_discharge_date = $sysmis.
    End if.
End if.
Frequencies corrected_open_end_date.

sort cases by chi sending_location social_care_id ch_admission_date record_date ch_discharge_date.
* Count records (where episodes are split because of changes in ch_provider or nursing_care).
* Create a marker to link split episodes together and link across CHI.
Numeric record_count split_ep_marker (F6.0).
Compute record_count = 1.
Compute split_ep_marker = 1.

Do if chi = lag(chi) and lag(sending_location) = sending_location and lag(social_care_id) = social_care_id.
    Do If lag(ch_admission_date) = ch_admission_date.
        * Normal records.
        * These are records for the same person, same admission date submitted in different quarters.
        Compute split_ep_marker = lag(split_ep_marker).
        Do if lag(record_date) NE record_date.
            Compute record_count = lag(record_count) + 1.
            * Duplicate records.
            * These are conflicting records submitted in the same quarter with the same admission dates.
        Else.
            Compute record_count = lag(record_count).
        End if.
    Else.
        * Normal records.
        * These are different episodes (new admission date) for the same person.
        Compute split_ep_marker = lag(split_ep_marker) + 1.
    End if.
End if.

sort cases by chi sending_location social_care_id split_ep_marker record_date.
* Highlight the last episode of the split_ep_marker to take the discharge date from.
* Can't use aggregate as that will ignore missing dates.
aggregate
    /Presorted
    /break chi sending_location social_care_id split_ep_marker
    /n_records = max(record_count).

Compute first_record = record_count = 1.
Compute last_record = record_count = n_records.

* Where the episodes are split (> 1 record) change the admission and discharge dates to the start and end of the quarters using the record_date as appropriate.
Do if n_records > 1.
    Do if first_record.
        Compute changed_dis_date = 1.
        Compute ch_discharge_date = record_date.
    Else if last_record.
        Compute changed_adm_date = 1.
        Compute ch_admission_date = lag(record_date).
        If Duplicate and lag(Duplicate) ch_admission_date = lag(ch_admission_date).
    Else.
        Compute changed_dis_date = 1.
        Compute ch_discharge_date = record_date.
        Compute changed_adm_date = 1.
        Compute ch_admission_date = lag(record_date).
        If Duplicate and lag(Duplicate) ch_admission_date = lag(ch_admission_date).
    End if.
End if.

Frequencies changed_adm_date changed_dis_date.

sort cases by chi split_ep_marker ch_admission_date ch_discharge_date.

* Adjust discharge dates according to death dates.
* Match on the death dates from the deceased lookup (year specific).
match files file = *
    /table = !Deaths_dir + "all_deaths.zsav"
    /by chi.

* Create a flag to identify the last record where an episode has been split.
* Episodes where the death_date is within 1-5 days of the dis date.
Do if range(datediff(ch_discharge_date, death_date, "days"), 1, 5).
    * Some tracking variables.
    Compute changed_dis_date = 1.
    Compute old_ch_discharge_date = ch_discharge_date.
    * Overwrite the discharge dates with the death date as appropriate.
    Compute ch_discharge_date = death_date.
    * Episodes not affected by the above but where the CHI death date fits the criteria (most CHIs have the same death date so this is a small number).
else if range(datediff(ch_discharge_date, death_date_CHI, "days"), 1, 5).
    * Some tracking variables.
    Compute changed_dis_date = 2.
    Compute old_ch_discharge_date = ch_discharge_date.
    * Overwrite the discharge dates with the death date as appropriate.
    Compute ch_discharge_date = death_date_CHI.
End if.

Alter type ch_discharge_date (Date11).
Value labels changed_dis_date
    1 "Changed to match NRS death date (<= 5 days before dis)"
    2 "Changed to match CHI death date (<= 5 days before dis)".

Frequencies changed_dis_date.

* Remove any episodes which now have an admission after discharge i.e. they were admitted after death.
* As of April 2021 this removes 34 episodes.
Compute death_before_adm = ch_admission_date > ch_discharge_date and not(sysmis(ch_discharge_date)).
Frequencies death_before_adm.
Select if not(death_before_adm).

* Create two 'continuous markers' one based on CHI, one based on sc_id + send_loc.

* sc_id + send_loc - this will apply to all clients but won't link up stays between sending locations.
sort cases by chi sending_location social_care_id ch_admission_date sc_latest_submission.
Compute sc_id_cis = 1.
Do if lag(sending_location) = sending_location and lag(social_care_id) = social_care_id.
    Compute sc_id_cis = lag(sc_id_cis).
    If ch_admission_date > lag(ch_discharge_date) sc_id_cis = lag(sc_id_cis) + 1.
End if.

* CHI - This won't apply to clients without a CHI but will link up stays across sending locations.
sort cases by chi ch_admission_date sc_latest_submission.
Compute sc_chi_cis = 1.
Do if chi = lag(chi) and chi NE "".
    Compute sc_chi_cis = lag(sc_chi_cis).
    If ch_admission_date > lag(ch_discharge_date) sc_chi_cis = lag(sc_chi_cis) + 1.
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

* Include the sc_id as a unique person identifier (first merge with sending loc).
String person_id (A13).
Compute person_id = concat(sending_location, "-", social_care_id).

sort cases by sending_location social_care_id chi split_ep_marker record_keydate1 record_keydate2.

save outfile = !SC_dir + "all_ch_episodes" + !LatestUpdate + ".zsav"
    /Keep chi
    person_id
    gender
    dob
    postcode
    sending_location
    social_care_id
    ch_name
    ch_postcode
    record_keydate1
    record_keydate2
    sc_chi_cis
    sc_id_cis
    ch_provider
    ch_nursing
    ch_adm_reason
    sc_latest_submission
    /zcompressed.
get file = !SC_dir + "all_ch_episodes" + !LatestUpdate + ".zsav".

* Clean up.
Erase file = !SC_dir + "TEMP-Care_Home_pre-aggregate.zsav".
Erase file = !SC_dir + "TEMP-Care_Home_end_of_name_changes.zsav".

