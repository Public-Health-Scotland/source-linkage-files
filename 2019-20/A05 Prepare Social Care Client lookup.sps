* Encoding: UTF-8.
* Get the client extract from DVPROD / social_care_2.
Insert file = "pass.sps".

DEFINE !get_client_data (fin_year = !tokens(1)).
GET DATA
   /TYPE=ODBC
   /CONNECT= !Eval(!connect_sc)
   /SQL=!Quote(!Concat("SELECT sending_location, social_care_id, financial_year, financial_quarter, ",
    "dementia, mental_health_problems, learning_disability, physical_and_sensory_disability, drugs, alcohol, palliative_care, carer, ",
    "elderly_frail, neurological_condition, autism, other_vulnerable_groups, ",
    "living_alone, support_from_unpaid_carer, social_worker, type_of_housing, meals, day_care ",
    "FROM social_care_2.client WHERE financial_year = ", !unquote(!fin_year),
    "ORDER BY sending_location, social_care_id, financial_year, financial_quarter"))
   /ASSUMEDSTRWIDTH=255.
CACHE.
EXECUTE.
!ENDDEFINE.

!get_client_data fin_year = !altFY.

* Variables are all really wide for some reason so tidy this up.
Variable width ALL (8).

* Change the flags to numerics.
Alter type
    sending_location (A3)
    financial_year (F4.0)
    financial_quarter (F1.0)
    social_care_id (A10)
    dementia TO day_care (F1.0).

Missing values
    support_from_unpaid_carer social_worker meals living_alone day_care (9)
    type_of_housing (6).

aggregate outfile = *
    /presorted
    /break sending_location social_care_id
    /dementia mental_health_problems learning_disability physical_and_sensory_disability drugs alcohol palliative_care carer elderly_frail
    neurological_condition autism other_vulnerable_groups living_alone support_from_unpaid_carer social_worker type_of_housing meals day_care =
    last(dementia mental_health_problems learning_disability physical_and_sensory_disability drugs alcohol palliative_care carer elderly_frail
    neurological_condition autism other_vulnerable_groups living_alone support_from_unpaid_carer social_worker type_of_housing meals day_care).

Missing values support_from_unpaid_carer social_worker meals living_alone day_care type_of_housing ().

Recode support_from_unpaid_carer social_worker meals living_alone day_care (sysmis = 9).
Recode type_of_housing (sysmis = 6).

* Add labels to the flag variables.
Variable Labels living_alone 'Indicator of whether the client/service user lives alone.'.
Variable Labels support_from_unpaid_carer 'Indicator of whether the client/service user received support from an unpaid carer at any point during the quarter.'.
Variable Labels social_worker 'Indicator of whether the client/service user has an assigned Social Worker or a Support Worker.'.
Variable Labels type_of_housing 'Housing status of the client at the end of the reporting period.'.
Variable Labels meals 'Indicator of whether the client/service user received a Meals Service at any point during the quarter.'.
Variable Labels day_care 'Indicator of whether the client/service user has received a day care service within the reporting period.'.

* Add some value labels.
Value Labels dementia mental_health_problems learning_disability physical_and_sensory_disability drugs alcohol palliative_care carer elderly_frail
    neurological_condition autism other_vulnerable_groups living_alone support_from_unpaid_carer social_worker type_of_housing meals day_care
    0 "No"
    1 "Yes".

Value Labels living_alone support_from_unpaid_carer social_worker meals, day_care
    0 "No"
    1 "Yes"
    9 "Not Known".

Value Labels type_of_housing
    1 "Mainstream"
    2 "Supported"
    3 "Long Stay Care Home"
    4 "Hospital or other medical establishment"
    5 "Other"
    6 "Not Known".

Rename Variables
    dementia = sc_dementia
    mental_health_problems = sc_mental_health_problems
    learning_disability = sc_learning_disability
    physical_and_sensory_disability = sc_physical_and_sensory_disability
    drugs = sc_drugs
    alcohol = sc_alcohol
    palliative_care = sc_palliative_care
    carer = sc_carer
    elderly_frail = sc_elderly_frail
    neurological_condition = sc_neurological_condition
    autism = sc_autism
    other_vulnerable_groups = sc_other_vulnerable_groups
    living_alone = sc_living_alone
    support_from_unpaid_carer = sc_support_from_unpaid_carer
    social_worker = sc_social_worker
    type_of_housing = sc_type_of_housing
    meals = sc_meals
    day_care = sc_day_care.

* Save and reorder flag variables so they're in the same order as Social Care Dataset definition.
save outfile =  !Year_dir + "Client_for_Source-20" + !FY + ".zsav"
    /Keep
    sending_location
    social_care_id
    sc_living_alone
    sc_support_from_unpaid_carer
    sc_social_worker
    sc_type_of_housing
    sc_meals
    sc_day_care
    /zcompressed.

get file = !Year_dir + "Client_for_Source-20" + !FY + ".zsav".
