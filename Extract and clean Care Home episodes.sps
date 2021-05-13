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
    /table = !Extracts_Alt + "Social Care Demographics lookup.zsav"
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

 * Check what the name should be if we just look at the Care home postcode.
Sort cases by ch_postcode.
match files
    /file = *
    /Table = !Extracts + "Care_home_name_lookup-20" + !FY + ".sav"
    /Rename (CareHomePostcode CareHomeName = ch_postcode ch_name_real)
    /Drop ch_name_tidy CareHomeCouncilAreaCode
    /By ch_postcode.

Compute has_real_ch_name = ch_name_real NE "".

aggregate
    /break ch_postcode sending_location
    /uses_real_name = max(has_real_ch_name).

* If the Sending Location has ever used the 'real' name, then just overwrite with it (mostly will overwrite blanks).
If uses_real_name ch_name = ch_name_real.

* Fill in any remaining blank care_home names where we have a correct postcode.
If ch_name = "" and ch_name_real NE "" ch_name = ch_name_real.

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

Compute #diff_name = ch_name NE ch_name_real and ch_name_real NE "".

* Now fill in any where the provided name is a substring of the real name.
Do if #diff_name.
    Compute #name_is_subset = char.index(ch_name_real, ch_name) > 1.
    * And any where the supplied name contains the real name plus some extra bits.
    Compute #name_is_extra = char.index(ch_name, ch_name_real) > 1.
End if.

If #name_is_subset or #name_is_extra ch_name = ch_name_real.

* Compare the current data to the lookup.
Sort Cases by ch_postcode ch_name.
match files
    /file = *
    /Table = !Extracts + "Care_home_name_lookup-20" + !FY + ".sav"
    /Rename (CareHomePostcode CareHomeName = ch_postcode ch_name)
    /In = AccurateData1
    /Drop CareHomeCouncilAreaCode
    /By ch_postcode ch_name.
frequencies AccurateData1.

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
    /Drop CareHomeCouncilAreaCode
    /By ch_postcode TestName2.

* If the name was correct take this as the new one, don't do it if both were correct.
Do If TestName1Correct = 1 and TestName2Correct = 0.
    Compute ch_name = TestName1.
Else If TestName2Correct = 1 and TestName1Correct = 0.
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
    /Drop CareHomeCouncilAreaCode
    /By ch_postcode ch_name.
frequencies AccurateData2.

* Highlight where an episode has at least one row of good data.
aggregate
    /break sending_location chi ch_admission_date
    /Any_accurate = max(AccurateData2).

* Apply the good data to other rows in the episode.
sort cases by sending_location social_care_id ch_admission_date (A) AccurateData2 (D).

aggregate
    /presorted
    /break sending_location social_care_id ch_admission_date
    /real_ch_name = first(ch_name)
    /real_ch_postcode = first(ch_postcode).

Do if AccurateData2 = 0 and real_ch_name NE "".
    Compute ch_name = real_ch_name.
    Compute ch_postcode = real_ch_postcode.
End if.

crosstabs AccurateData2 by Any_accurate.
* Fixes around 8000 rows.

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
        if seq.real_quick_ratio() > 0.9:
            ratio = seq.ratio()
        else:
            ratio = 0
    return(ratio)
End Program.

SPSSINC TRANS result = ratio type = 0
    /formula similarity_ratio(ch_name, best_guess_name).

If ratio >= 0.95 ch_name = best_guess_name.

 * Fill in more blank care home names by looking for cases where we have:
 * A postcode with only a single name other than blanks
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
Do if ch_postcode = lag(ch_postcode) and lag(name_proportion) > 0.8.
    Do if (ch_name = "" or lag(name_proportion) > 0.9) and ch_name NE lag(ch_name).
        Compute old_name = ch_name.
        If ch_name = "" ch_name = lag(ch_name).
        If lag(name_proportion) > 0.9 ch_name = lag(ch_name).
        Compute name_proportion = lag(name_proportion).
    End if.
End if.
Temporary.
Select if old_name ne ch_name and name_proportion > 0.8.
crosstabs old_name by ch_name.

* Refresh the variables to drop all the ones we no longer need.
add files file = *
    /keep = sending_location social_care_id chi ch_name ch_postcode ch_admission_date ch_discharge_date financial_year financial_quarter period record_date ch_provider reason_for_admission nursing_care_provision age gender dob postcode.

* Sort into reverse order so we can use lag() to fill in below.
sort cases by sending_location social_care_id ch_admission_date period (D).

* Correct missing nursing_care_provision.
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
 * First identify the earliest submitted social_care_id.
aggregate 
    /break sending_location social_care_id
    /earliest_submission = min(period).

 * Apply the earliest submitted social_care_id to all instances of the same CHI within a single sending_location.
sort cases by chi sending_location earliest_submission social_care_id.
aggregate
    /Presorted
    /Break chi sending_location
    /first_sc_id = first(social_care_id).
If chi NE "" social_care_id = first_sc_id.

save outfile = !Extracts_Alt + "TEMP - Care Home pre aggregate.zsav"
    /Keep chi sending_location social_care_id ch_name ch_postcode ch_admission_date ch_discharge_date record_date period All
    /Drop min_provider max_provider first_sc_id
    /zcompressed.
get file = !Extracts_Alt + "TEMP - Care Home pre aggregate.zsav".

* Sort to ensure the latest submitted records come last.
sort cases by chi ch_admission_date period sending_location social_care_id ch_provider nursing_care_provision.

Missing values ch_name ch_postcode postcode ("").
* Aggregate to episode level, splitting episodes where the ch_provider or nursing_care changes.
aggregate outfile = *
    /Break chi sending_location social_care_id ch_provider nursing_care_provision ch_admission_date
    /ch_discharge_date = last(ch_discharge_date)
    /record_date = Max(record_date)
    /sc_latest_submission = Max(period)
    /ch_name = last(ch_name)
    /ch_postcode = last(ch_postcode)
    /reason_for_admission = last(reason_for_admission)
    /gender dob postcode = first(gender dob postcode).

sort cases by chi ch_admission_date record_date ch_discharge_date.

* Count records (where episodes are split because of changes in ch_provider or nursing_care).
* Create a marker to link split episodes together and link across CHI.
Numeric record_count scem (F6.0).
Compute record_count = 1.
Compute scem = 1. /*scem = Social Care Episode Marker - name hopefully to be changed */.

Do if chi = lag(chi) and CHI NE "".
    Do If lag(ch_admission_date) = ch_admission_date.
        * Normal records.
        * These are records for the same person, same admission date submitted in different quarters.
        Compute scem = lag(scem).
        * Duplicate records.
        * These are conflicting records submitted in the same quarter with the same admission dates.
        * Or same CHI, same start date, different SC id.
        If lag(record_date) NE record_date and lag(sending_location) = sending_location and lag(social_care_id) = social_care_id record_count = lag(record_count) + 1.
    Else.
        * Normal records.
        * These are different episodes (new admission date) for the same person.
        Compute scem = lag(scem) + 1.
    End if.
End if.

* For missing CHI records.
sort cases by sending_location social_care_id ch_admission_date record_date ch_discharge_date.

Do if chi = "" and lag(sending_location) = sending_location and lag(social_care_id) = social_care_id.
    Do If lag(ch_admission_date) = ch_admission_date.
        * Normal records.
        * These are records for the same person, same admission date submitted in different quarters.
        Compute scem = lag(scem).
        * Duplicate records.
        * These are conflicting records submitted in the same quarter with the same admission dates.
        If lag(record_date) NE record_date record_count = lag(record_count) + 1.
    Else.
        * Normal records.
        * These are different episodes (new admission date) for the same person.
        Compute scem = lag(scem) + 1.
    End if.
End if.

sort cases by chi sending_location social_care_id scem record_date.
* Highlight the last episode of the scem to take the discharge date from.
* Can't use aggregate as that will ignore missing dates.
add files file = *
    /by chi sending_location social_care_id scem
    /last = Last_record.

Numeric last_ch_discharge_date (Date11).
If last_record last_ch_discharge_date = ch_discharge_date.

* For all episodes set the sc_dates to be the first admission and last discharge (these are the actual dates for the episode).
* This will only be useful for split episodes, in the normal case they will match the single line episode dates.
* Also add on the maximum number of records for each episode so we can identify the split episodes.
aggregate
    /break chi sending_location social_care_id scem
    /n_records = max(record_count)
    /sc_date_1 = min(ch_admission_date)
    /sc_date_2 = max(last_ch_discharge_date).

* Where the episodes are split (> 1 record) change the admission and discharge dates to the start and end of the quarters using the record_date as appropriate.
Do if n_records > 1.
    Do if record_count = 1.
        Compute changed_dis_date = 1.
        Compute ch_discharge_date = record_date.
    Else if record_count = n_records.
        Compute changed_adm_date = 1.
        Compute ch_admission_date = lag(record_date).
    Else.
        Compute changed_dis_date = 1.
        Compute ch_discharge_date = record_date.
        Compute changed_adm_date = 1.
        Compute ch_admission_date = lag(record_date).
    End if.
End if.

Frequencies changed_adm_date changed_dis_date.

* Remove SCEM for records without a CHI.
if chi = "" scem = $sysmis.

sort cases by chi scem ch_admission_date ch_discharge_date.

* Adjust discharge dates according to death dates.
* Match on the death dates from the deceased lookup (year specific).
match files file = *
    /table = !Extracts_Alt + "All Deaths.zsav"
    /by chi.

* Create a flag to identify the last record where an episode has been split.
add files file = *
    /last = last_scem_ep
    /by chi scem.

* Episodes where the death_date is within 1-5 days of the dis date.
do if range(datediff(sc_date_2, death_date, "days"), 1, 5).
    * Some tracking variables.
    Compute changed_dis_date = 1.
    Compute old_ch_discharge_date = ch_discharge_date.
    Compute old_sc_date_2 = sc_date_2.
    * Overwrite the discharge dates with the death date as appropriate.
    Compute sc_date_2 = death_date.
    Do if last_scem_ep.
        Compute ch_discharge_date = death_date.
    Else if ch_discharge_date > death_date.
        Compute ch_discharge_date = death_date.
        Compute none_last_ep_changed = 1.
    End if.
    * Episodes not affected by the above but where the CHI death date fits the criteria (most CHIs have the same death date so this is a small number).
else if range(datediff(sc_date_2, death_date_CHI, "days"), 1, 5).
    * Some tracking variables.
    Compute changed_dis_date = 2.
    Compute old_ch_discharge_date = ch_discharge_date.
    Compute old_sc_date_2 = sc_date_2.
    * Overwrite the discharge dates with the death date as appropriate.
    Compute old_ch_discharge_date = ch_discharge_date.
    Compute old_sc_date_2 = sc_date_2.
    Compute sc_date_2 = death_date_CHI.
    Do if last_scem_ep.
        Compute ch_discharge_date = death_date_CHI.
    Else if ch_discharge_date > death_date_CHI.
        Compute ch_discharge_date = death_date_CHI.
        Compute none_last_ep_changed = 2.
    End if.
end if.
Alter type ch_discharge_date old_sc_date_2 (Date11).
Value labels changed_dis_date none_last_ep_changed
    1 "Changed to match NRS death date (<= 5 days before dis)"
    2 "Changed to match CHI death date (<= 5 days before dis)".

Frequencies changed_dis_date none_last_ep_changed.

 * Remove any episodes which now have an admission after discharge i.e. they were admitted after death.
 * As of April 2021 this removes 34 episodes.
Compute death_before_adm = ch_admission_date > ch_discharge_date and not(sysmis(ch_discharge_date)).
Frequencies death_before_adm.
Select if not(death_before_adm).

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

sort cases by sending_location social_care_id chi scem record_keydate1 record_keydate2.

save outfile = !Extracts_Alt + "All Care Home episodes.zsav"
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
    sc_date_1
    sc_date_2
    ch_provider
    ch_nursing
    ch_adm_reason
    scem
    sc_latest_submission
    /zcompressed.
get file = !Extracts_Alt + "All Care Home episodes.zsav".

* Clean up.
Erase file = !Extracts_Alt + "TEMP - Care Home pre aggregate.zsav".

