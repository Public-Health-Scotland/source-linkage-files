* Encoding: UTF-8.

********************************************************************************************************.
* Run 01-Set up Macros first!.
********************************************************************************************************.

GET DATA  /TYPE=TXT
    /FILE= !Year_Extracts_dir + 'A&E-episode-level-extract-20' + !FY + '.csv'
    /ENCODING='UTF8'
    /DELIMITERS=","
    /QUALIFIER='"'
    /ARRANGEMENT=DELIMITED
    /FIRSTCASE=2
    /VARIABLES=
    ArrivalDate A10
    DischargeDate A10
    PatCHINumberC A10
    PatDateOfBirthC A10
    PatGenderCode F1.0
    ResidenceNHSBoardCypher A1
    TreatmentNHSBoardCypher A1
    TreatmentLocationCode A7
    GPPracticeCode A5
    CouncilAreaCode A2
    PostcodeepiC A8
    PostcodeCHIC A8
    HSCPCode A9
    ArrivalTime Time5
    DischargeTime Time5
    ArrivalModeCode A2
    ReferralSourceCode A3
    AttendanceCategoryCode A2
    DischargeDestinationCode A3
    PatientFlowCode A1
    PlaceofIncidentCode A3
    ReasonforWaitCode A3
    Disease1Code A6
    Disease2Code A6
    Disease3Code A6
    BodilyLocationOfInjuryCode A3
    AlcoholInvolvedCode A2
    AlcoholRelatedAdmission A1
    SubstanceMisuseRelatedAdmission A1
    FallsRelatedAdmission A1
    SelfHarmRelatedAdmission A1
    TotalNetCosts F8.2
    AgeatMidpointofFinancialYear F3.0
    CaseReferenceNumber A100.
CACHE.
Execute.

Rename Variables
    AgeatMidpointofFinancialYear = age
    AlcoholInvolvedCode = ae_alcohol
    AlcoholRelatedAdmission = alcohol_adm
    ArrivalModeCode = ae_arrivalmode
    ArrivalTime = keyTime1
    AttendanceCategoryCode = ae_attendcat
    BodilyLocationOfInjuryCode = ae_bodyloc
    CouncilAreaCode = lca
    DischargeDestinationCode = ae_disdest
    DischargeTime = keyTime2
    Disease1Code = diag1
    Disease2Code = diag2
    Disease3Code = diag3
    FallsRelatedAdmission = falls_adm
    GPPracticeCode = gpprac
    HSCPCode = HSCP
    PatCHINumberC = chi
    PatGenderCode = gender
    PatientFlowCode = ae_patflow
    PlaceofIncidentCode = ae_placeinc
    ReasonforWaitCode = ae_reasonwait
    ReferralSourceCode = refsource
    SelfHarmRelatedAdmission = selfharm_adm
    SubstanceMisuseRelatedAdmission = submis_adm
    TotalNetCosts = cost_total_net
    TreatmentLocationCode = location.

string year (a4) recid (a3).
compute year = !FY.
compute recid = 'AE2'.

* Recode GP Practice into a 5 digit number.
* We assume that if it starts with a letter it's an English practice and so recode to 99995.
Do if Range(char.Substr(gpprac, 1, 1), "A", "Z").
    Compute gpprac = "99995".
End if.
Alter Type GPprac (F5.0).

Rename Variables
    ArrivalDate = record_keydate1
    DischargeDate = record_keydate2
    PatDateofBirthC = dob.

alter type record_keydate1 record_keydate2 dob (SDate10).
alter type record_keydate1 record_keydate2 dob (Date12).

* Postcode - use the CHI postcode and if that is blank, then use the epi postcode.
String Postcode (A8).
Compute Postcode = PostcodeCHIC.
If Postcode = "" Postcode = PostcodeepiC.

String hbtreatcode hbrescode(A9).

* Recode the cipher type HB codes into 9-char.
* Currently using HB2018 set-up.
Recode TreatmentNHSBoardCypher ResidenceNHSBoardCypher
    ("A" = "S08000015")
    ("B" = "S08000016")
    ("F" = "S08000029")
    ("G" = "S08000021")
    ("H" = "S08000022")
    ("L" = "S08000023")
    ("N" = "S08000020")
    ("R" = "S08000025")
    ("S" = "S08000024")
    ("T" = "S08000030")
    ("V" = "S08000019")
    ("W" = "S08000028")
    ("Y" = "S08000017")
    ("Z" = "S08000026")
    Into hbtreatcode hbrescode.

* Allocate the costs to the correct month.

* Set up the variables.
Numeric apr_cost may_cost jun_cost jul_cost aug_cost sep_cost oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost (F8.2).

* Get the month number.
compute month = xdate.Month(record_keydate1).

* Loop through the months (in the correct FY order and assign the cost to the relevant month.
Do Repeat month_num = 4 5 6 7 8 9 10 11 12 1 2 3
    /month_cost = apr_cost to mar_cost.
    Do if month = month_num.
        Compute month_cost = cost_total_net.
    Else.
        Compute month_cost = 0.
    End if.
End Repeat.

* Put record_keydate back into numeric.
Compute record_keydate1 = xdate.mday(record_keydate1) + 100 * xdate.month(record_keydate1) + 10000 * xdate.year(record_keydate1).
Compute record_keydate2 = xdate.mday(record_keydate2) + 100 * xdate.month(record_keydate2) + 10000 * xdate.year(record_keydate2).
alter type record_keydate1 record_keydate2 (F8.0).

* Add A&E specific value labels.
Value Labels ae_arrivalmode
    '01' "Ambulance (road) Excludes involvement of an A&E retrieval team."
    '02' "Ambulance (air) Travel for all or any part of journey by an aircraft operating as an ambulance."
    '03' "Ambulance and A&E retrieval team. Includes both road and air ambulance modes of transport."
    '04' "Out of Hours transport OOH has arranged transport (includes PTS transport but not emergency ambulance)."
    '05' "Private transport Includes car, taxi, motorbike, bicycle, etc"
    '06' "Public transport Includes bus, train, etc."
    '07' "Walking On foot."
    '08' "Police/prison transport Patient is brought to A&E in a police or prison vehicle."
    '98' "Other The true value to be recorded is not covered by any of the specific given categories. Includes mortuary van."
    '99' "Not known".

Value Labels ae_attendcat
    '01' "New"
    '02' "Return - Planned"
    '03' "Return - Unplanned"
    '04' "Recall".

Value Labels ae_disdest
    '00' "Death"
    '01' "Private Residence"
    '01A' "Usual place of residence"
    '01B' "Not usual place of residence e.g. staying with relatives or friends"
    '02' "Residential institution"
    '02A' "Usual place of residence"
    '02B' "Not usual place of residence"
    '03' "Temporary residence"
    '03A' "Holiday accommodation"
    '03B' "Student accommodation"
    '03C' "Legal establishment /prison"
    '03D' "No fixed abode"
    '03Z' "Other temporary residence"
    '04' "Admission to same NHS healthcare provider / hospital"
    '04A' "A&E Ward Includes A&E observation ward, A&E short stay ward, etc"
    '04B' "Assessment unit"
    '04C' "Medical Ward Includes medical admissions unit, coronary care unit"
    '04D' "Surgical Ward Includes surgical admissions unit, orthopaedic ward"
    '04Z' "Other Ward"
    '05' "Transfer to same/other hospital"
    '05A' "Psychiatric hospital"
    '05B' "Other specialist centre e.g. eye hospital, paediatric hospital"
    '05C' "Community hospital"
    '05D' "Transferred to Out of Hours (triaged in A&E)"
    '05E' "Transferred to Out of Hours (not triaged in A&E)"
    '05F' "Advised to attend GP/Primary Care"
    '05G' "A&E"
    '05H' "NHS24"
    '05Z' "Other NHS hospital"
    '06' "Private healthcare provider"
    '98' "Other"
    '99' "Other".

Value Labels ae_patflow
    '1' "Flow 1 - Minor Injury and Illness"
    '2' "Flow 2 - Acute Assessment"
    '3' "Flow 3 - Medical Admissions"
    '4' "Flow 4 - Surgical Admissions"
    '5' "Flow 5 - Out-of-Hospital Care".

Value Labels ae_placeinc
    '01' "Place of residence"
    '01A' "Home - The person's own home or the home of a third party."
    '01B' "Residential Institution - An institute with residential accommodation."
    '02' "Transport area"
    '02A' "Public highway, street or road Publicly owned and maintained highway, street, road, pavements or cycle path"
    '02B' "Other transport area Places where transport out-with a public highway, street or road takes place."
    '03' "Business area (excluding recreational & sports areas)"
    '03A' "Industrial or construction area A place primarily intended for industrial or construction purposes."
    '03B' "Farm or other place of primary production."
    '03C' "Commercial area - non recreational A commercial area not primarily intended for recreational purposes."
    '04' "School, educational area"
    '05' "Sports & Recreational area"
    '05A' "Sports and athletic area - Any place specifically intended for formal sporting purposes."
    '05B' "Recreational area, cultural area or public building."
    '05C' "Countryside / open nature area Refers to open nature area not classified elsewhere"
    '06' "Medical service area/Health care area"
    '98' "Other specified"
    '99' "Not Known - Includes unspecified place of occurrence".

Value Labels ae_reasonwait
    '00' "No Delay - Patient's whose stay in A&E is < 4 hours"
    '01' "Wait for a bed"
    '02' "Wait for transport - Commissioned by A&E"
    '03' "Wait for treatment - Refers to the initial A&E treatment"
    '03A' "Wait for treatment - To commence"
    '03B' "Wait for treatment - To be completed"
    '05' "Wait for diagnostic test(s)"
    '05A' "Wait for diagnostic test(s) - To be performed"
    '05B' "Awaiting results. Refers to results which will determine the next step in the patient journey"
    '06' "Wait for first assessment"
    '07' "Clinical reason(s)"
    '98' "Other reason".

Value Labels ae_alcohol
    '01' "Yes"
    '02' "No".

Value Labels ae_bodyloc
    '00' "None"
    '01' "Intracranial/brain"
    '01A' "Focal"
    '01B' "Diffuse"
    '01C' "Extradural"
    '01D' "Subdural"
    '01Z' "Other intracranial"
    '02' "Head"
    '02A' "Scalp"
    '02B' "Frontal"
    '02C' "Parietal"
    '02D' "Occipital"
    '02E' "Temporal"
    '02F' "Cranial nerves"
    '02Z' "Other head"
    '03' "Face"
    '03A' "Orbit"
    '03B' "Maxilla"
    '03C' "Zygoma"
    '03D' "Cheek"
    '03E' "Upper lip"
    '03F' "Lower lip"
    '03G' "Temporomandibular joint"
    '03H' "Mandible"
    '03Z' "Other face"
    '04' "Eye"
    '04A' "Upper eyelid"
    '04B' "Lower eyelid"
    '04C' "Periorbital area"
    '04D' "Cornea"
    '04E' "Sclera"
    '04F' "Conjunctiva"
    '04G' "Lens"
    '04H' "Intraorbital tissue"
    '04Z' "Other eye"
    '05' "Nose"
    '05A' "Skin"
    '05B' "Nasal bones"
    '05C' "Nasal septum"
    '05D' "Nasal cavity"
    '05Z' "Other nose"
    '06' "Ear"
    '06A' "Pinna"
    '06B' "Lobe"
    '06C' "Ear canal/external auditory canal"
    '06D' "Ear drum/tympanic membrane"
    '06E' "Middle ear"
    '06F' "Inner ear"
    '06Z' "Other ear"
    '07' "Oral cavity"
    '07A' "Oral mucosa"
    '07B' "Tongue"
    '07C' "Teeth"
    '07D' "Tonsil"
    '07E' "Epiglottis"
    '07F' "Uvula"
    '07G' "Gingiva"
    '07H' "Palate"
    '07J' "Vallecula"
    '07Z' "Other oral cavity"
    '08' "Neck"
    '08A' "Skin and superficial area"
    '08B' "Larynx and trachea"
    '08C' "Oesophagus (cervical)"
    '08D' "Blood vessels"
    '08E' "Vertebra/spine (cervical)"
    '08F' "Cervical cord"
    '08G' "Brachial plexus"
    '08Z' "Other neck"
    '09' "Thorax"
    '09A' "Skin and superficial fascia"
    '09B' "Front wall of chest"
    '09C' "Back wall of chest"
    '09D' "Breast"
    '09E' "Ribs"
    '09F' "Sternum"
    '09G' "Vertebrae/spine (thoracic)"
    '09H' "Spinal cord (thoracic)"
    '09J' "Major blood vessels"
    '09K' "Heart and pericardium"
    '09L' "Oesophagus (thoracic)"
    '09M' "Trachea (thoracic)"
    '09N' "Bronchus"
    '09P' "Lungs"
    '09Q' "Diaphragm"
    '09Z' "Other thorax"
    '10' "Abdomen"
    '10A' "Skin"
    '10B' "Abdominal wall"
    '10C' "Stomach"
    '10D' "Small bowel"
    '10E' "Large bowel"
    '11' "Back"
    '11A' "Skin"
    '11B' "Buttocks"
    '11C' "Lumbar spine"
    '11D' "Lumbar spinal cord"
    '11E' "Nerves of lumbar plexus"
    '11Z' "Other back"
    '12' "Genitalia / Reproductive organs"
    '12A' "Foreskin"
    '12B' "Penis"
    '12C' "Testes"
    '12D' "Scrotum"
    '12E' "Vulva"
    '12F' "Vagina"
    '12G' "Uterus & adnexa"
    '12Z' "Other genitalia"
    '13' "Anorectal"
    '13A' "Rectum"
    '13B' "Anus"
    '14' "Pelvis"
    '14A' "Sacrum"
    '14B' "Coccyx"
    '14C' "Sacro-iliac joint"
    '14D' "Pubic ramus"
    '14E' "Ilium"
    '14F' "Acetabulum"
    '14G' "Pubic symphysis"
    '14H' "Cauda equina"
    '14Z' "Other pelvis"
    '15' "Shoulder"
    '15A' "Skin"
    '15B' "Clavicle"
    '15C' "Scapula"
    '15D' "Head of humerus"
    '15E' "Neck of humerus"
    '15F' "Tuberosity of humerus"
    '15G' "Shoulder joint"
    '15H' "Acromioclavicular joint"
    '15J' "Sternoclavicular joint"
    '15K' "Sub-acromial bursa"
    '15L' "Rotator cuff"
    '15M' "Deltoid"
    '15N' "Other muscle"
    '15Z' "Other shoulder"
    '16' "Axilla"
    '16A' "Skin"
    '16B' "Axillary blood vessels"
    '16C' "Nerves"
    '16Z' "Other axilla"
    '17' "Upper arm"
    '17A' "Skin"
    '17B' "Shaft of humerus"
    '17C' "Distal end of humerus"
    '17D' "Radial nerve"
    '17E' "Blood vessels"
    '17F' "Biceps"
    '17G' "Triceps"
    '17H' "Other muscle"
    '17Z' "Other upper arm"
    '18' "Elbow"
    '18A' "Skin"
    '18B' "Supracondylar"
    '18C' "Lateral epicondyle"
    '18D' "Medial epicondyle"
    '18E' "Head of radius"
    '18F' "Neck of radius"
    '18G' "Olecranon"
    '18H' "Elbow joint"
    '18J' "Biceps tendon"
    '18K' "Nerves"
    '18L' "Blood vessels"
    '18Z' "Other elbow"
    '19' "Forearm"
    '19A' "Skin"
    '19B' "Radius"
    '19C' "Ulna"
    '19D' "Radius and ulna"
    '19E' "Nerves"
    '19F' "Blood vessels"
    '19G' "Muscles / tendons"
    '19Z' "Other forearm"
    '20' "Wrist"
    '20A' "Skin"
    '20B' "Radius"
    '20C' "Ulna"
    '20D' "Radius and ulna"
    '20E' "Tubercle of scaphoid"
    '20F' "Scaphoid"
    '20G' "Other carpal bones"
    '20H' "Carpal ligaments"
    '20J' "Wrist joint"
    '20K' "Nerves"
    '20L' "Artery"
    '20M' "Tendons"
    '20Z' "Other wrist"
    '21' "Hand"
    '21A' "Skin of dorsum"
    '21B' "Skin of palm"
    '21C' "Metacarpal"
    '21D' "Metacarpophalangeal joint"
    '21E' "Other carpal bones"
    '21F' "Carpometacarpal joint"
    '21G' "Nerves"
    '21H' "Artery"
    '21J' "Muscles"
    '21Z' "Other hand"
    '22' "Thumb"
    '22A' "Distal phalanx"
    '22B' "Interphalangeal joint"
    '22C' "Proximal phalanx"
    '22D' "Metacarpophalangeal joint"
    '22E' "Metacarpal"
    '22F' "Carpometacarpal joint"
    '22G' "Trapezium"
    '22H' "Muscles"
    '22J' "Artery"
    '22K' "Nerves"
    '23' "Finger"
    '23A' "Index finger"
    '23B' "Middle finger"
    '23C' "Ring finger"
    '23D' "Little finger"
    '23E' "Digital arteries"
    '23F' "Digital nerves"
    '24' "Hip"
    '24A' "Skin"
    '24B' "Neck of femur"
    '24C' "Trochanter"
    '24D' "Hip joint"
    '25' "Thigh"
    '25A' "Skin"
    '25B' "Shaft of femur"
    '25C' "Distal end of femur"
    '25D' "Muscles"
    '25E' "Blood vessels"
    '25F' "Nerves"
    '25Z' "Other thigh"
    '26' "Knee"
    '26A' "Skin"
    '26B' "Patella"
    '26C' "Femoral condyle"
    '26D' "Proximal end of tibia"
    '26E' "Knee joint"
    '26F' "Ligaments"
    '26G' "Cartilage"
    '26H' "Medial meniscus"
    '26J' "Lateral meniscus"
    '26K' "Nerves"
    '26L' "Blood vessels"
    '26M' "Quadriceps tendon"
    '26Z' "Other knee"
    '27' "Lower leg"
    '27A' "Skin"
    '27B' "Tibia"
    '27C' "Fibula"
    '27D' "Tibia and fibula"
    '27E' "Achilles tendon"
    '27F' "Muscles"
    '27G' "Blood vessels"
    '27H' "Nerves"
    '27Z' "Other lower leg"
    '28' "Ankle"
    '28A' "Skin"
    '28B' "Ligaments"
    '28C' "Lateral malleolus"
    '28D' "Medial malleolus"
    '28E' "Talus"
    '28F' "Ankle joint"
    '28Z' "Other bones"
    '29' "Foot"
    '29A' "Skin"
    '29B' "1st metatarsal"
    '29C' "2nd metatarsal"
    '29D' "3rd metatarsal"
    '29E' "4th metatarsal"
    '29F' "5th metatarsal shaft /neck / head"
    '29G' "5th metatarsal base"
    '29H' "Calcaneus"
    '29J' "Other bones"
    '29K' "Joints"
    '29L' "Blood vessels"
    '29M' "Tendons / muscles"
    '29N' "Nerves"
    '30' "Toes"
    '30A' "Big toe"
    '30B' "2nd toe"
    '30C' "3rd toe"
    '30D' "4th toe"
    '30E' "5th toe"
    '31' "Multiple body regions".

* Sort for linking on CUP marker.
sort cases by record_keydate1 keyTime1 CaseReferenceNumber.

save outfile = !Year_dir + 'a&e_data-20' + !FY + '.zsav'
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
    CaseReferenceNumber
    /zcompressed.

get file = !Year_dir + 'a&e_data-20' + !FY + '.zsav'.

* Zip up raw data.
Host Command = ["gzip " + !Year_Extracts_dir + "A&E-episode-level-extract-20" + !FY + ".csv"].
