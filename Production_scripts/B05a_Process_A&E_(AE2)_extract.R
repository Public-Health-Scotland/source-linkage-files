#####################################################
# A&E Extract
# Author: Catherine Holland
# Date: February 2022
# Written on RStudio Server
# Version of R - 3.6.1
# Input -
# Description - Process A & E extract
#####################################################


library(dplyr)
library(tidyr)


## get data ##

# latest year
latest_year <- 1920

# function here till PR pushed
get_year_dir <- function(year, extracts_dir = FALSE) {
  year_dir <- fs::path("/conf/sourcedev/Source_Linkage_File_Updates", year)

  year_extracts_dir <- fs::path(year_dir, "Extracts")

  return(dplyr::if_else(extracts_dir, year_extracts_dir, year_dir))
}


ae_episode_extract <- readr::read_csv(
  paste0(
    get_year_dir(year = latest_year),
    "/Extracts/A&E-episode-level-extract-20",
    latest_year,
    ".csv.gz"
  )
) %>%
  # rename
  rename(
    record_keydate1 = "Arrival Date",
    record_keydate2 = "DAT Date",
    dob = "Pat Date Of Birth [C]",
    postcode_epi = "Postcode (epi) [C]",
    postcode_chi = "Postcode (CHI) [C]",
    age = "Age at Midpoint of Financial Year",
    ae_alcohol = "Alcohol Involved Code",
    alcohol_adm = "Alcohol Related Admission",
    ae_arrivalmode = "Arrival Mode Code",
    keyTime1 = "Arrival Time",
    ae_attendcat = "Attendance Category Code",
    ae_bodyloc = "Bodily Location Of Injury Code",
    lca = "Council Area Code",
    ae_disdest = "Discharge Destination Code",
    keyTime2 = "DAT Time",
    diag1 = "Disease 1 Code",
    diag2 = "Disease 2 Code",
    diag3 = "Disease 3 Code",
    falls_adm = "Falls Related Admission",
    gpprac = "GP Practice Code",
    hscp = "HSCP of Residence Code - current",
    hbrescode = "NHS Board of Residence Code - current",
    hbtreatcode = "Treatment NHS Board Code - current",
    chi = "Pat UPI [C]",
    gender = "Pat Gender Code",
    ae_patflow = "Patient Flow Code",
    ae_placeinc = "Place of Incident Code",
    ae_reasonwait = "Reason for Wait Code",
    refsource = "Referral Source Code",
    selfharm_adm = "Self Harm Related Admission",
    submis_adm = "Substance Misuse Related Admission",
    sigfac = "Significant Facility Code",
    cost_total_net = "Total Net Costs",
    location = "Treatment Location Code",
    case_ref_number = "Case Reference Number"
  ) %>%
  # date types
  mutate(
    dob = as.Date(dob),
    record_keydate1 = as.Date(record_keydate1),
    record_keydate2 = as.Date(record_keydate2)
  )


# year variable
ae_episode_extract <-
  ae_episode_extract %>%
  mutate(
    year = latest_year,
    recid = "AE2"
  )


## Recode GP Practice into a 5 digit number ##
# assume that if it starts with a letter it's an English practice and so recode to 99995
ae_episode_extract <-
  ae_episode_extract %>%
  mutate(gpprac = replace(gpprac, substr(gpprac, 1, 1) %in% c("A", "Z"), "99995"))


## Postcode ##
# use the CHI postcode and if that is blank, then use the epi postcode.
ae_episode_extract <-
  ae_episode_extract %>%
  mutate(postcode = if_else(!is.na(postcode_chi), postcode_chi, postcode_epi))


## recode cypher HB codes ##
ae_episode_extract <-
  ae_episode_extract %>%
  mutate(
    across(
      c(hbtreatcode, hbrescode),
      ~ case_when(
        .x == "A" ~ "S08000015",
        .x == "B" ~ "S08000016",
        .x == "F" ~ "S08000029",
        .x == "G" ~ "S08000021",
        .x == "H" ~ "S08000022",
        .x == "L" ~ "S08000023",
        .x == "N" ~ "S08000020",
        .x == "R" ~ "S08000025",
        .x == "S" ~ "S08000024",
        .x == "T" ~ "S08000030",
        .x == "V" ~ "S08000019",
        .x == "W" ~ "S08000028",
        .x == "Y" ~ "S08000017",
        .x == "Z" ~ "S08000026"
      )
    )
  )


## Allocate the costs to the correct month ##

# month variable
ae_episode_extract <-
  ae_episode_extract %>%
  mutate(month = strftime(record_keydate1, "%m"))

# cost in correct month
ae_episode_extract <-
  ae_episode_extract %>%
  mutate(
    apr_cost = if_else(month == "04", cost_total_net, 0),
    may_cost = if_else(month == "05", cost_total_net, 0),
    jun_cost = if_else(month == "06", cost_total_net, 0),
    jul_cost = if_else(month == "07", cost_total_net, 0),
    aug_cost = if_else(month == "08", cost_total_net, 0),
    sep_cost = if_else(month == "09", cost_total_net, 0),
    oct_cost = if_else(month == "10", cost_total_net, 0),
    nov_cost = if_else(month == "11", cost_total_net, 0),
    dec_cost = if_else(month == "12", cost_total_net, 0),
    jan_cost = if_else(month == "01", cost_total_net, 0),
    feb_cost = if_else(month == "02", cost_total_net, 0),
    mar_cost = if_else(month == "03", cost_total_net, 0)
  )


## A&E value labels ##
ae_episode_extract <-
  ae_episode_extract %>%
  mutate(
    ae_arrivalmode = factor(ae_arrivalmode,
      levels = c("01", "02", "03", "04", "05", "06", "07", "08", "98", "99"),
      labels = c(
        "Ambulance (road) Excludes involvement of an A&E retrieval team.",
        "Ambulance (air) Travel for all or any part of journey by an aircraft operating as an ambulance.",
        "Ambulance and A&E retrieval team. Includes both road and air ambulance modes of transport.",
        "Out of Hours transport OOH has arranged transport (includes PTS transport but not emergency ambulance).",
        "Private transport Includes car, taxi, motorbike, bicycle, etc",
        "Public transport Includes bus, train, etc.",
        "Walking On foot.",
        "Police/prison transport Patient is brought to A&E in a police or prison vehicle.",
        "Other The true value to be recorded is not covered by any of the specific given categories. Includes mortuary van.",
        "Not known"
      )
    ),
    ae_attendcat = factor(ae_attendcat,
      levels = c("01", "02", "03", "04"),
      labels = c(
        "New",
        "Return - Planned",
        "Return - Unplanned",
        "Recall"
      )
    ),
    ae_disdest = factor(ae_disdest,
      levels = c(
        "00",
        "01", "01A", "01B",
        "02", "02A", "02B",
        "03", "03A", "03B", "03C", "03D", "03Z",
        "04", "04A", "04B", "04C", "04D", "04Z",
        "05", "05A", "05B", "05C", "05D", "05E", "05F", "05G", "05H", "05Z",
        "06",
        "98",
        "99"
      ),
      labels = c(
        "Death",
        "Private Residence",
        "Usual place of residence",
        "Not usual place of residence e.g. staying with relatives or friends",
        "Residential institution",
        "Usual place of residence",
        "Not usual place of residence",
        "Temporary residence",
        "Holiday accommodation",
        "Student accommodation",
        "Legal establishment /prison",
        "No fixed abode",
        "Other temporary residence",
        "Admission to same NHS healthcare provider / hospital",
        "A&E Ward Includes A&E observation ward, A&E short stay ward, etc",
        "Assessment unit",
        "Medical Ward Includes medical admissions unit, coronary care unit",
        "Surgical Ward Includes surgical admissions unit, orthopaedic ward",
        "Other Ward",
        "Transfer to same/other hospital",
        "Psychiatric hospital",
        "Other specialist centre e.g. eye hospital, paediatric hospital",
        "Community hospital",
        "Transferred to Out of Hours (triaged in A&E)",
        "Transferred to Out of Hours (not triaged in A&E)",
        "Advised to attend GP/Primary Care",
        "A&E",
        "NHS24",
        "Other NHS hospital",
        "Private healthcare provider",
        "Other",
        "Other"
      )
    ),
    ae_patflow = factor(ae_patflow,
      levels = c(1:5),
      labels = c(
        "Flow 1 - Minor Injury and Illness",
        "Flow 2 - Acute Assessment",
        "Flow 3 - Medical Admissions",
        "Flow 4 - Surgical Admissions",
        "Flow 5 - Out-of-Hospital Care"
      )
    ),
    ae_placeinc = factor(ae_placeinc,
      levels = c(
        "01", "01A", "01B",
        "02", "02A", "02B",
        "03", "03A", "03B", "03C",
        "04",
        "05", "05A", "05B", "05C",
        "06",
        "98",
        "99"
      ),
      labels = c(
        "Place of residence",
        "Home - The person's own home or the home of a third party.",
        "Residential Institution - An institute with residential accommodation.",
        "Transport area",
        "Public highway, street or road Publicly owned and maintained highway, street, road, pavements or cycle path",
        "Other transport area Places where transport out-with a public highway, street or road takes place.",
        "Business area (excluding recreational & sports areas)",
        "Industrial or construction area A place primarily intended for industrial or construction purposes.",
        "Farm or other place of primary production.",
        "Commercial area - non recreational A commercial area not primarily intended for recreational purposes.",
        "School, educational area",
        "Sports & Recreational area",
        "Sports and athletic area - Any place specifically intended for formal sporting purposes.",
        "Recreational area, cultural area or public building.",
        "Countryside / open nature area Refers to open nature area not classified elsewhere",
        "Medical service area/Health care area",
        "Other specified",
        "Not Known - Includes unspecified place of occurrence"
      )
    ),
    # ae_reasonwait = factor(ae_reasonwait,
    #                       levels = c("00",
    #                                  "01",
    #                                  "02",
    #                                  "03", "03A", "03B",
    #                                  "05", "05A", "05B",
    #                                  "06",
    #                                  "07",
    #                                  "98"),
    #                       levels = c(
    #                         "No Delay - Patient's whose stay in A&E is < 4 hours",
    #                         "Wait for a bed",
    #                         "Wait for transport - Commissioned by A&E",
    #                         "Wait for treatment - Refers to the initial A&E treatment",
    #                         "Wait for treatment - To commence",
    #                         "Wait for treatment - To be completed",
    #                         "Wait for diagnostic test(s)",
    #                         "Wait for diagnostic test(s) - To be performed",
    #                         "Awaiting results. Refers to results which will determine the next step in the patient journey",
    #                         "Wait for first assessment",
    #                         "Clinical reason(s)",
    #                         "Other reason"
    #                       )),
    ae_alcohol = factor(ae_alcohol,
      levels = c(1:2),
      labels = c(
        "Yes",
        "No"
      )
    ),
    ae_bodyloc = factor(ae_bodyloc,
      levels = c(
        "00",
        "01",
        "01A",
        "01B",
        "01C",
        "01D",
        "01Z",
        "02",
        "02A",
        "02B",
        "02C",
        "02D",
        "02E",
        "02F",
        "02Z",
        "03",
        "03A",
        "03B",
        "03C",
        "03D",
        "03E",
        "03F",
        "03G",
        "03H",
        "03Z",
        "04",
        "04A",
        "04B",
        "04C",
        "04D",
        "04E",
        "04F",
        "04G",
        "04H",
        "04Z",
        "05",
        "05A",
        "05B",
        "05C",
        "05D",
        "05F",
        "05Z",
        "06",
        "06A",
        "06B",
        "06C",
        "06D",
        "06E",
        "06F",
        "06Z",
        "07",
        "07A",
        "07B",
        "07C",
        "07D",
        "07E",
        "07F",
        "07G",
        "07H",
        "07J",
        "07Z",
        "08",
        "08A",
        "08B",
        "08C",
        "08D",
        "08E",
        "08F",
        "08G",
        "08Z",
        "09",
        "09A",
        "09B",
        "09C",
        "09D",
        "09E",
        "09F",
        "09G",
        "09H",
        "09J",
        "09K",
        "09L",
        "09M",
        "09N",
        "09P",
        "09Q",
        "09Z",
        "10",
        "10A",
        "10B",
        "10C",
        "10D",
        "10E",
        "11",
        "11A",
        "11B",
        "11C",
        "11D",
        "11E",
        "11Z",
        "12",
        "12A",
        "12B",
        "12C",
        "12D",
        "12E",
        "12F",
        "12G",
        "12Z",
        "13",
        "13A",
        "13B",
        "14",
        "14A",
        "14B",
        "14C",
        "14D",
        "14E",
        "14F",
        "14G",
        "14H",
        "14Z",
        "15",
        "15A",
        "15B",
        "15C",
        "15D",
        "15E",
        "15F",
        "15G",
        "15H",
        "15J",
        "15K",
        "15L",
        "15M",
        "15N",
        "15Z",
        "16",
        "16A",
        "16B",
        "16C",
        "16Z",
        "17",
        "17A",
        "17B",
        "17C",
        "17D",
        "17E",
        "17F",
        "17G",
        "17H",
        "17Z",
        "18",
        "18A",
        "18B",
        "18C",
        "18D",
        "18E",
        "18F",
        "18G",
        "18H",
        "18J",
        "18K",
        "18L",
        "18Z",
        "19",
        "19A",
        "19B",
        "19C",
        "19D",
        "19E",
        "19F",
        "19G",
        "19Z",
        "20",
        "20A",
        "20B",
        "20C",
        "20D",
        "20E",
        "20F",
        "20G",
        "20H",
        "20J",
        "20K",
        "20L",
        "20M",
        "20Z",
        "21",
        "21A",
        "21B",
        "21C",
        "21D",
        "21E",
        "21F",
        "21G",
        "21H",
        "21J",
        "21Z",
        "22",
        "22A",
        "22B",
        "22C",
        "22D",
        "22E",
        "22F",
        "22G",
        "22H",
        "22J",
        "22K",
        "23",
        "23A",
        "23B",
        "23C",
        "23D",
        "23E",
        "23F",
        "24",
        "24A",
        "24B",
        "24C",
        "24D",
        "25",
        "25A",
        "25B",
        "25C",
        "25D",
        "25E",
        "25F",
        "25Z",
        "26",
        "26A",
        "26B",
        "26C",
        "26D",
        "26E",
        "26F",
        "26G",
        "26H",
        "26J",
        "26K",
        "26L",
        "26M",
        "26Z",
        "27",
        "27A",
        "27B",
        "27C",
        "27D",
        "27E",
        "27F",
        "27G",
        "27H",
        "27Z",
        "28",
        "28A",
        "28B",
        "28C",
        "28D",
        "28E",
        "28F",
        "28Z",
        "29",
        "29A",
        "29B",
        "29C",
        "29D",
        "29E",
        "29F",
        "29G",
        "29H",
        "29J",
        "29K",
        "29L",
        "29M",
        "29N",
        "30",
        "30A",
        "30B",
        "30C",
        "30D",
        "30E",
        "31"
      ),
      labels = c(
        "None",
        "Intracranial/brain",
        "Focal",
        "Diffuse",
        "Extradural",
        "Subdural",
        "Other intracranial",
        "Head",
        "Scalp",
        "Frontal",
        "Parietal",
        "Occipital",
        "Temporal",
        "Cranial nerves",
        "Other head",
        "Face",
        "Orbit",
        "Maxilla",
        "Zygoma",
        "Cheek",
        "Upper lip",
        "Lower lip",
        "Temporomandibular joint",
        "Mandible",
        "Other face",
        "Eye",
        "Upper eyelid",
        "Lower eyelid",
        "Periorbital area",
        "Cornea",
        "Sclera",
        "Conjunctiva",
        "Lens",
        "Intraorbital tissue",
        "Other eye",
        "Nose",
        "Skin",
        "Nasal bones",
        "Nasal septum",
        "Nasal cavity",
        "Other nose",
        "Other nose",
        "Ear",
        "Pinna",
        "Lobe",
        "Ear canal/external auditory canal",
        "Ear drum/tympanic membrane",
        "Middle ear",
        "Inner ear",
        "Other ear",
        "Oral cavity",
        "Oral mucosa",
        "Tongue",
        "Teeth",
        "Tonsil",
        "Epiglottis",
        "Uvula",
        "Gingiva",
        "Palate",
        "Vallecula",
        "Other oral cavity",
        "Neck",
        "Skin and superficial area",
        "Larynx and trachea",
        "Oesophagus (cervical)",
        "Blood vessels",
        "Vertebra/spine (cervical)",
        "Cervical cord",
        "Brachial plexus",
        "Other neck",
        "Thorax",
        "Skin and superficial fascia",
        "Front wall of chest",
        "Back wall of chest",
        "Breast",
        "Ribs",
        "Sternum",
        "Vertebrae/spine (thoracic)",
        "Spinal cord (thoracic)",
        "Major blood vessels",
        "Heart and pericardium",
        "Oesophagus (thoracic)",
        "Trachea (thoracic)",
        "Bronchus",
        "Lungs",
        "Diaphragm",
        "Other thorax",
        "Abdomen",
        "Skin",
        "Abdominal wall",
        "Stomach",
        "Small bowel",
        "Large bowel",
        "Back",
        "Skin",
        "Buttocks",
        "Lumbar spine",
        "Lumbar spinal cord",
        "Nerves of lumbar plexus",
        "Other back",
        "Genitalia / Reproductive organs",
        "Foreskin",
        "Penis",
        "Testes",
        "Scrotum",
        "Vulva",
        "Vagina",
        "Uterus & adnexa",
        "Other genitalia",
        "Anorectal",
        "Rectum",
        "Anus",
        "Pelvis",
        "Sacrum",
        "Coccyx",
        "Sacro-iliac joint",
        "Pubic ramus",
        "Ilium",
        "Acetabulum",
        "Pubic symphysis",
        "Cauda equina",
        "Other pelvis",
        "Shoulder",
        "Skin",
        "Clavicle",
        "Scapula",
        "Head of humerus",
        "Neck of humerus",
        "Tuberosity of humerus",
        "Shoulder joint",
        "Acromioclavicular joint",
        "Sternoclavicular joint",
        "Sub-acromial bursa",
        "Rotator cuff",
        "Deltoid",
        "Other muscle",
        "Other shoulder",
        "Axilla",
        "Skin",
        "Axillary blood vessels",
        "Nerves",
        "Other axilla",
        "Upper arm",
        "Skin",
        "Shaft of humerus",
        "Distal end of humerus",
        "Radial nerve",
        "Blood vessels",
        "Biceps",
        "Triceps",
        "Other muscle",
        "Other upper arm",
        "Elbow",
        "Skin",
        "Supracondylar",
        "Lateral epicondyle",
        "Medial epicondyle",
        "Head of radius",
        "Neck of radius",
        "Olecranon",
        "Elbow joint",
        "Biceps tendon",
        "Nerves",
        "Blood vessels",
        "Other elbow",
        "Forearm",
        "Skin",
        "Radius",
        "Ulna",
        "Radius and ulna",
        "Nerves",
        "Blood vessels",
        "Muscles / tendons",
        "Other forearm",
        "Wrist",
        "Skin",
        "Radius",
        "Ulna",
        "Radius and ulna",
        "Tubercle of scaphoid",
        "Scaphoid",
        "Other carpal bones",
        "Carpal ligaments",
        "Wrist joint",
        "Nerves",
        "Artery",
        "Tendons",
        "Other wrist",
        "Hand",
        "Skin of dorsum",
        "Skin of palm",
        "Metacarpal",
        "Metacarpophalangeal joint",
        "Other carpal bones",
        "Carpometacarpal joint",
        "Nerves",
        "Artery",
        "Muscles",
        "Other hand",
        "Thumb",
        "Distal phalanx",
        "Interphalangeal joint",
        "Proximal phalanx",
        "Metacarpophalangeal joint",
        "Metacarpal",
        "Carpometacarpal joint",
        "Trapezium",
        "Muscles",
        "Artery",
        "Nerves",
        "Finger",
        "Index finger",
        "Middle finger",
        "Ring finger",
        "Little finger",
        "Digital arteries",
        "Digital nerves",
        "Hip",
        "Skin",
        "Neck of femur",
        "Trochanter",
        "Hip joint",
        "Thigh",
        "Skin",
        "Shaft of femur",
        "Distal end of femur",
        "Muscles",
        "Blood vessels",
        "Nerves",
        "Other thigh",
        "Knee",
        "Skin",
        "Patella",
        "Femoral condyle",
        "Proximal end of tibia",
        "Knee joint",
        "Ligaments",
        "Cartilage",
        "Medial meniscus",
        "Lateral meniscus",
        "Nerves",
        "Blood vessels",
        "Quadriceps tendon",
        "Other knee",
        "Lower leg",
        "Skin",
        "Tibia",
        "Fibula",
        "Tibia and fibula",
        "Achilles tendon",
        "Muscles",
        "Blood vessels",
        "Nerves",
        "Other lower leg",
        "Ankle",
        "Skin",
        "Ligaments",
        "Lateral malleolus",
        "Medial malleolus",
        "Talus",
        "Ankle joint",
        "Other bones",
        "Foot",
        "Skin",
        "1st metatarsal",
        "2nd metatarsal",
        "3rd metatarsal",
        "4th metatarsal",
        "5th metatarsal shaft /neck / head",
        "5th metatarsal base",
        "Calcaneus",
        "Other bones",
        "Joints",
        "Blood vessels",
        "Tendons / muscles",
        "Nerves",
        "Toes",
        "Big toe",
        "2nd toe",
        "3rd toe",
        "4th toe",
        "5th toe",
        "Multiple body regions"
      )
    )
  )


# sort for linking on CUP marker
ae_episode_extract <-
  ae_episode_extract %>%
  arrange(record_keydate1, keyTime1, case_ref_number)


## save outfile ##
outfile <-
  ae_episode_extract %>%
  select(
    year,
    recid,
    record_keydate1,
    record_keydate2,
    keyTime1,
    keyTime2,
    chi,
    gender,
    dob,
    gpprac,
    postcode,
    lca,
    hscp,
    location,
    hbrescode,
    hbtreatcode,
    diag1,
    diag2,
    diag3,
    ae_arrivalmode,
    refsource,
    sigfac,
    ae_attendcat,
    ae_disdest,
    ae_patflow,
    ae_placeinc,
    ae_reasonwait,
    ae_bodyloc,
    ae_alcohol,
    alcohol_adm,
    submis_adm,
    falls_adm,
    selfharm_adm,
    cost_total_net,
    age,
    apr_cost,
    may_cost,
    jun_cost,
    jul_cost,
    aug_cost,
    sep_cost,
    oct_cost,
    nov_cost,
    dec_cost,
    jan_cost,
    feb_cost,
    mar_cost,
    case_ref_number
  )


# .zsav
haven::write_sav(outfile,
  paste0(
    get_year_dir(year = latest_year),
    "/a&e_data-20",
    latest_year, ".zsav"
  ),
  compress = TRUE
)

# .rds file
readr::write_rds(outfile,
  paste0(
    get_year_dir(year = latest_year),
    "/a&e_data-20",
    latest_year, ".zsav"
  ),
  compress = "gz"
)


# -------------------------------------------------------------------------------------------


## Link to CUP Marker ##


## get data ##
ae_cup_extract <- readr::read_csv(
  file =
    paste0(
      get_year_dir(year = latest_year),
      "/Extracts/A&E-UCD-CUP-extract-20",
      latest_year,
      ".csv.gz"
    )
) %>%
  # rename
  rename(
    record_keydate1 = "ED Arrival Date",
    keyTime1 = "ED Arrival Time",
    case_ref_number = "ED Case Reference Number [C]",
    cup_marker = "CUP Marker",
    cup_pathway = "CUP Pathway Name"
  ) %>%
  # date type
  mutate(
    record_keydate1 = as.Date(record_keydate1)
  )


## sort for linking onto data extract ##
# remove any duplicates
ae_cup_extract <-
  ae_cup_extract %>%
  arrange(record_keydate1, keyTime1, case_ref_number) %>%
  group_by(record_keydate1, keyTime1, case_ref_number) %>%
  mutate(
    cup_marker = first(cup_marker),
    cup_pathway = first(cup_pathway)
  ) %>%
  ungroup()


## match files ##
matched_data <-
  outfile %>%
  full_join(ae_cup_extract, by = c("record_keydate1", "keyTime1", "case_ref_number")) %>%
  arrange(chi, record_keydate1, keyTime1, record_keydate2, keyTime2)


## save outfile ##
outfile <-
  matched_data %>%
  select(
    year,
    recid,
    record_keydate1,
    record_keydate2,
    keyTime1,
    keyTime2,
    chi,
    gender,
    dob,
    gpprac,
    postcode,
    lca,
    hscp,
    location,
    hbrescode,
    hbtreatcode,
    diag1,
    diag2,
    diag3,
    ae_arrivalmode,
    refsource,
    sigfac,
    ae_attendcat,
    ae_disdest,
    ae_patflow,
    ae_placeinc,
    ae_reasonwait,
    ae_bodyloc,
    ae_alcohol,
    alcohol_adm,
    submis_adm,
    falls_adm,
    selfharm_adm,
    cost_total_net,
    age,
    apr_cost,
    may_cost,
    jun_cost,
    jul_cost,
    aug_cost,
    sep_cost,
    oct_cost,
    nov_cost,
    dec_cost,
    jan_cost,
    feb_cost,
    mar_cost,
    cup_marker,
    cup_pathway
  )


# .zsav
haven::write_sav(outfile,
  paste0(
    get_year_dir(year = latest_year),
    "/a&e_for_source-20",
    latest_year, ".zsav"
  ),
  compress = TRUE
)

# .rds file
readr::write_rds(outfile,
  paste0(
    get_year_dir(year = latest_year),
    "/a&e_for_source-20",
    latest_year, ".zsav"
  ),
  compress = "gz"
)


# -------------------------------------------------------------------------------------------

## tests ##

## data file ##

## Flags ##
outfile <-
  outfile %>%
  mutate(
    # count CHI
    has_chi = if_else(is.na(chi), 0, 1),
    # count M/F
    male = if_else(gender == 1, 1, 0),
    female = if_else(gender == 2, 1, 0),
    # count missing values
    no_dob = if_else(is.na(dob), 1, 0),
    # count how many episodes in each HB by treatment code
    nhs_ayrshire_and_arran = if_else(hbtreatcode == "S08000015", 1, 0),
    nhs_borders = if_else(hbtreatcode == "S08000016", 1, 0),
    nhs_dumfries_and_galloway = if_else(hbtreatcode == "S08000017", 1, 0),
    nhs_forth_valley = if_else(hbtreatcode == "S08000019", 1, 0),
    nhs_grampian = if_else(hbtreatcode == "S08000020", 1, 0),
    nhs_greater_glasgow_and_clyde = if_else(hbtreatcode %in% c("S08000021", "S08000031"), 1, 0),
    nhs_highland = if_else(hbtreatcode == "S08000022", 1, 0),
    nhs_lanarkshire = if_else(hbtreatcode %in% c("S08000023", "S08000032"), 1, 0),
    nhs_lothian = if_else(hbtreatcode == "S08000024", 1, 0),
    nhs_orkney = if_else(hbtreatcode == "S08000025", 1, 0),
    nhs_shetland = if_else(hbtreatcode == "S08000026", 1, 0),
    nhs_western_isles = if_else(hbtreatcode == "S08000028", 1, 0),
    nhs_fife = if_else(hbtreatcode %in% c("S08000018", "S08000029"), 1, 0),
    nhs_tayside = if_else(hbtreatcode %in% c("S08000027", "S08000030"), 1, 0),
    # change missing HB values
    across(starts_with("nhs_"), ~ replace_na(.x, 0)),
    # count HB costs
    nhs_ayrshire_and_arran_cost = if_else(nhs_ayrshire_and_arran == 1, cost_total_net, 0),
    nhs_borders_cost = if_else(nhs_borders == 1, cost_total_net, 0),
    nhs_dumfries_and_galloway_cost = if_else(nhs_dumfries_and_galloway == 1, cost_total_net, 0),
    nhs_forth_valley_cost = if_else(nhs_forth_valley == 1, cost_total_net, 0),
    nhs_grampian_cost = if_else(nhs_grampian == 1, cost_total_net, 0),
    nhs_greater_glasgow_and_clyde_cost = if_else(nhs_greater_glasgow_and_clyde == 1, cost_total_net, 0),
    nhs_highland_cost = if_else(nhs_highland == 1, cost_total_net, 0),
    nhs_lanarkshire_cost = if_else(nhs_lanarkshire == 1, cost_total_net, 0),
    nhs_lothian_cost = if_else(nhs_lothian == 1, cost_total_net, 0),
    nhs_orkney_cost = if_else(nhs_orkney == 1, cost_total_net, 0),
    nhs_shetland_cost = if_else(nhs_shetland == 1, cost_total_net, 0),
    nhs_western_isles_cost = if_else(nhs_western_isles == 1, cost_total_net, 0),
    nhs_fife_cost = if_else(nhs_fife == 1, cost_total_net, 0),
    nhs_tayside_cost = if_else(nhs_tayside == 1, cost_total_net, 0),
    # change missing HB cost values
    across(starts_with("nhs_") & ends_with("_cost"), ~ replace_na(.x, 0))
  )

## values for whole file ##
slf_new <-
  outfile %>%
  summarise(
    n_chi = sum(has_chi, na.rm = TRUE),
    n_male = sum(male, na.rm = TRUE),
    n_female = sum(female, na.rm = TRUE),
    mean_age = mean(age, na.rm = TRUE),
    # n_episodes = n,
    total_cost = sum(cost_total_net, na.rm = TRUE),
    mean_cost = mean(cost_total_net, na.rm = TRUE),
    max_cost = max(cost_total_net, na.rm = TRUE),
    min_cost = min(cost_total_net, na.rm = TRUE),
    earliest_start1 = min(record_keydate1),
    earliest_start2 = min(record_keydate2),
    latest_start1 = max(record_keydate1),
    latest_start2 = max(record_keydate2),
    total_cost_apr = sum(apr_cost, na.rm = TRUE),
    total_cost_may = sum(may_cost, na.rm = TRUE),
    total_cost_jun = sum(jun_cost, na.rm = TRUE),
    total_cost_jul = sum(jul_cost, na.rm = TRUE),
    total_cost_aug = sum(aug_cost, na.rm = TRUE),
    total_cost_sep = sum(sep_cost, na.rm = TRUE),
    total_cost_oct = sum(oct_cost, na.rm = TRUE),
    total_cost_nov = sum(nov_cost, na.rm = TRUE),
    total_cost_dec = sum(dec_cost, na.rm = TRUE),
    total_cost_jan = sum(jan_cost, na.rm = TRUE),
    total_cost_feb = sum(feb_cost, na.rm = TRUE),
    total_cost_mar = sum(mar_cost, na.rm = TRUE),
    mean_cost_apr = mean(apr_cost, na.rm = TRUE),
    mean_cost_may = mean(may_cost, na.rm = TRUE),
    mean_cost_jun = mean(jun_cost, na.rm = TRUE),
    mean_cost_jul = mean(jul_cost, na.rm = TRUE),
    mean_cost_aug = mean(aug_cost, na.rm = TRUE),
    mean_cost_sep = mean(sep_cost, na.rm = TRUE),
    mean_cost_oct = mean(oct_cost, na.rm = TRUE),
    mean_cost_nov = mean(nov_cost, na.rm = TRUE),
    mean_cost_dec = mean(dec_cost, na.rm = TRUE),
    mean_cost_jan = mean(jan_cost, na.rm = TRUE),
    mean_cost_feb = mean(feb_cost, na.rm = TRUE),
    mean_cost_mar = mean(mar_cost, na.rm = TRUE),
    nhs_ayrshire_and_arran = sum(nhs_ayrshire_and_arran),
    nhs_borders = sum(nhs_borders),
    nhs_dumfries_and_galloway = sum(nhs_dumfries_and_galloway),
    nhs_forth_valley = sum(nhs_forth_valley),
    nhs_grampian = sum(nhs_grampian),
    nhs_greater_glasgow_and_clyde = sum(nhs_greater_glasgow_and_clyde),
    nhs_highland = sum(nhs_highland),
    nhs_lanarkshire = sum(nhs_lanarkshire),
    nhs_lothian = sum(nhs_lothian),
    nhs_orkney = sum(nhs_orkney),
    nhs_shetland = sum(nhs_shetland),
    nhs_western_isles = sum(nhs_western_isles),
    nhs_fife = sum(nhs_fife),
    nhs_tayside = sum(nhs_tayside),
    nhs_ayrshire_and_arran_cost = sum(nhs_ayrshire_and_arran_cost),
    nhs_borders_cost = sum(nhs_borders_cost),
    nhs_dumfries_and_galloway_cost = sum(nhs_dumfries_and_galloway_cost),
    nhs_forth_valley_cost = sum(nhs_forth_valley_cost),
    nhs_grampian_cost = sum(nhs_grampian_cost),
    nhs_greater_glasgow_and_clyde_cost = sum(nhs_greater_glasgow_and_clyde_cost),
    nhs_highland_cost = sum(nhs_highland_cost),
    nhs_lanarkshire_cost = sum(nhs_lanarkshire_cost),
    nhs_lothian_cost = sum(nhs_lothian_cost),
    nhs_orkney_cost = sum(nhs_orkney_cost),
    nhs_shetland_cost = sum(nhs_shetland_cost),
    nhs_western_isles_cost = sum(nhs_western_isles_cost),
    nhs_fife_cost = sum(nhs_fife_cost),
    nhs_tayside_cost = sum(nhs_tayside_cost)
  )



# wide to long
slf_new <- as.data.frame(t(slf_new))
slf_new <-
  slf_new %>%
  tibble::rownames_to_column("measure") %>%
  rename(value = "V1")


# -------------------------------------------------------------------------------------------


## episode file ##

episode_file <- haven::read_sav(
  paste0("/conf/hscdiip/01-Source-linkage-files/source-episode-file-20", latest_year, ".zsav"),
  col_select = c(
    recid,
    Anon_CHI,
    record_keydate1,
    record_keydate2,
    gender,
    dob,
    age,
    hbtreatcode,
    Cost_Total_Net_incDNAs,
    apr_cost,
    may_cost,
    jun_cost,
    jul_cost,
    aug_cost,
    sep_cost,
    oct_cost,
    nov_cost,
    dec_cost,
    jan_cost,
    feb_cost,
    mar_cost,
    attendance_status
  )
)


episode_file <-
  episode_file %>%
  # filter for recid = "AE2"
  filter(recid == "AE2") %>%
  # rename
  rename(
    chi = "Anon_CHI",
    cost_total_net = "Cost_Total_Net_incDNAs"
  )

## Flags ##
episode_file <-
  episode_file %>%
  mutate(
    # count CHI
    has_chi = if_else(is.na(chi), 0, 1),
    # count M/F
    male = if_else(gender == 1, 1, 0),
    female = if_else(gender == 2, 1, 0),
    # count missing values
    no_dob = if_else(is.na(dob), 1, 0),
    # count how many episodes in each HB by treatment code
    nhs_ayrshire_and_arran = if_else(hbtreatcode == "S08000015", 1, 0),
    nhs_borders = if_else(hbtreatcode == "S08000016", 1, 0),
    nhs_dumfries_and_galloway = if_else(hbtreatcode == "S08000017", 1, 0),
    nhs_forth_valley = if_else(hbtreatcode == "S08000019", 1, 0),
    nhs_grampian = if_else(hbtreatcode == "S08000020", 1, 0),
    nhs_greater_glasgow_and_clyde = if_else(hbtreatcode %in% c("S08000021", "S08000031"), 1, 0),
    nhs_highland = if_else(hbtreatcode == "S08000022", 1, 0),
    nhs_lanarkshire = if_else(hbtreatcode %in% c("S08000023", "S08000032"), 1, 0),
    nhs_lothian = if_else(hbtreatcode == "S08000024", 1, 0),
    nhs_orkney = if_else(hbtreatcode == "S08000025", 1, 0),
    nhs_shetland = if_else(hbtreatcode == "S08000026", 1, 0),
    nhs_western_isles = if_else(hbtreatcode == "S08000028", 1, 0),
    nhs_fife = if_else(hbtreatcode %in% c("S08000018", "S08000029"), 1, 0),
    nhs_tayside = if_else(hbtreatcode %in% c("S08000027", "S08000030"), 1, 0),
    # change missing HB values
    across(starts_with("nhs_"), ~ replace_na(.x, 0)),
    # count HB costs
    nhs_ayrshire_and_arran_cost = if_else(nhs_ayrshire_and_arran == 1, cost_total_net, 0),
    nhs_borders_cost = if_else(nhs_borders == 1, cost_total_net, 0),
    nhs_dumfries_and_galloway_cost = if_else(nhs_dumfries_and_galloway == 1, cost_total_net, 0),
    nhs_forth_valley_cost = if_else(nhs_forth_valley == 1, cost_total_net, 0),
    nhs_grampian_cost = if_else(nhs_grampian == 1, cost_total_net, 0),
    nhs_greater_glasgow_and_clyde_cost = if_else(nhs_greater_glasgow_and_clyde == 1, cost_total_net, 0),
    nhs_highland_cost = if_else(nhs_highland == 1, cost_total_net, 0),
    nhs_lanarkshire_cost = if_else(nhs_lanarkshire == 1, cost_total_net, 0),
    nhs_lothian_cost = if_else(nhs_lothian == 1, cost_total_net, 0),
    nhs_orkney_cost = if_else(nhs_orkney == 1, cost_total_net, 0),
    nhs_shetland_cost = if_else(nhs_shetland == 1, cost_total_net, 0),
    nhs_western_isles_cost = if_else(nhs_western_isles == 1, cost_total_net, 0),
    nhs_fife_cost = if_else(nhs_fife == 1, cost_total_net, 0),
    nhs_tayside_cost = if_else(nhs_tayside == 1, cost_total_net, 0),
    # change missing HB cost values
    across(starts_with("nhs_") & ends_with("_cost"), ~ replace_na(.x, 0))
  )



## values for whole file ##
slf_existing <-
  episode_file %>%
  summarise(
    n_chi = sum(has_chi, na.rm = TRUE),
    n_male = sum(male, na.rm = TRUE),
    n_female = sum(female, na.rm = TRUE),
    mean_age = mean(age, na.rm = TRUE),
    # n_episodes = n,
    total_cost = sum(cost_total_net, na.rm = TRUE),
    mean_cost = mean(cost_total_net, na.rm = TRUE),
    max_cost = max(cost_total_net, na.rm = TRUE),
    min_cost = min(cost_total_net, na.rm = TRUE),
    earliest_start1 = min(record_keydate1),
    earliest_start2 = min(record_keydate2),
    latest_start1 = max(record_keydate1),
    latest_start2 = max(record_keydate2),
    total_cost_apr = sum(apr_cost, na.rm = TRUE),
    total_cost_may = sum(may_cost, na.rm = TRUE),
    total_cost_jun = sum(jun_cost, na.rm = TRUE),
    total_cost_jul = sum(jul_cost, na.rm = TRUE),
    total_cost_aug = sum(aug_cost, na.rm = TRUE),
    total_cost_sep = sum(sep_cost, na.rm = TRUE),
    total_cost_oct = sum(oct_cost, na.rm = TRUE),
    total_cost_nov = sum(nov_cost, na.rm = TRUE),
    total_cost_dec = sum(dec_cost, na.rm = TRUE),
    total_cost_jan = sum(jan_cost, na.rm = TRUE),
    total_cost_feb = sum(feb_cost, na.rm = TRUE),
    total_cost_mar = sum(mar_cost, na.rm = TRUE),
    mean_cost_apr = mean(apr_cost, na.rm = TRUE),
    mean_cost_may = mean(may_cost, na.rm = TRUE),
    mean_cost_jun = mean(jun_cost, na.rm = TRUE),
    mean_cost_jul = mean(jul_cost, na.rm = TRUE),
    mean_cost_aug = mean(aug_cost, na.rm = TRUE),
    mean_cost_sep = mean(sep_cost, na.rm = TRUE),
    mean_cost_oct = mean(oct_cost, na.rm = TRUE),
    mean_cost_nov = mean(nov_cost, na.rm = TRUE),
    mean_cost_dec = mean(dec_cost, na.rm = TRUE),
    mean_cost_jan = mean(jan_cost, na.rm = TRUE),
    mean_cost_feb = mean(feb_cost, na.rm = TRUE),
    mean_cost_mar = mean(mar_cost, na.rm = TRUE),
    nhs_ayrshire_and_arran = sum(nhs_ayrshire_and_arran),
    nhs_borders = sum(nhs_borders),
    nhs_dumfries_and_galloway = sum(nhs_dumfries_and_galloway),
    nhs_forth_valley = sum(nhs_forth_valley),
    nhs_grampian = sum(nhs_grampian),
    nhs_greater_glasgow_and_clyde = sum(nhs_greater_glasgow_and_clyde),
    nhs_highland = sum(nhs_highland),
    nhs_lanarkshire = sum(nhs_lanarkshire),
    nhs_lothian = sum(nhs_lothian),
    nhs_orkney = sum(nhs_orkney),
    nhs_shetland = sum(nhs_shetland),
    nhs_western_isles = sum(nhs_western_isles),
    nhs_fife = sum(nhs_fife),
    nhs_tayside = sum(nhs_tayside),
    nhs_ayrshire_and_arran_cost = sum(nhs_ayrshire_and_arran_cost),
    nhs_borders_cost = sum(nhs_borders_cost),
    nhs_dumfries_and_galloway_cost = sum(nhs_dumfries_and_galloway_cost),
    nhs_forth_valley_cost = sum(nhs_forth_valley_cost),
    nhs_grampian_cost = sum(nhs_grampian_cost),
    nhs_greater_glasgow_and_clyde_cost = sum(nhs_greater_glasgow_and_clyde_cost),
    nhs_highland_cost = sum(nhs_highland_cost),
    nhs_lanarkshire_cost = sum(nhs_lanarkshire_cost),
    nhs_lothian_cost = sum(nhs_lothian_cost),
    nhs_orkney_cost = sum(nhs_orkney_cost),
    nhs_shetland_cost = sum(nhs_shetland_cost),
    nhs_western_isles_cost = sum(nhs_western_isles_cost),
    nhs_fife_cost = sum(nhs_fife_cost),
    nhs_tayside_cost = sum(nhs_tayside_cost)
  )


# wide to long
slf_existing <- as.data.frame(t(slf_existing))
slf_existing <-
  slf_existing %>%
  tibble::rownames_to_column("measure") %>%
  rename(value = "V1")



# -------------------------------------------------------------------------------------------


## run comparison function ##

comparison <- extract_comparison_test(slf_new = slf_new, slf_existing = slf_existing)

ae_comparison <- comparison[["comparison_data"]]



## save outfile ##

# .zsav
haven::write_sav(ae_comparison,
  paste0(
    get_year_dir(year = latest_year),
    "/A&E_tests_20",
    latest_year, ".zsav"
  ),
  compress = TRUE
)

# .rds file
readr::write_rds(ae_comparison,
  paste0(
    get_year_dir(year = latest_year),
    "/A&E_tests_20",
    latest_year, ".zsav"
  ),
  compress = "gz"
)
