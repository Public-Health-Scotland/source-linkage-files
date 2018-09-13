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

 * DN Lables.
Add VALUE LABELS diag1 to diag6
   1	'Assessment'
   10	'Long Term Condition Management'
   11	'Medication'
   12	'Mobility'
   13	'Nutrition/Fluids'
   14	'Personal Care'
   16	'Procedures'
   17	'Risk Management'
   18	'Skin/Wound Care'
   19	'Social Circumstances'
   2	'Bladder/Bowel Care'
   20	'Symptom Management'
   21	'Teaching'
   22	'Palliative Care'
   3	'Care Management'
   4	'Carers'
   5	'Emotional / Psychological Issues'
   6	'Equipment'
   8	'Health Promotion'.

Add value labels location
   1 'DN-Hospital'
   2 'DN-HealthCentre'
   3 'DN-GP Surgery'
   5 'DN-Nursing Home or Care Home or Residential Home'
   6 'DN-Patient or client residence'
   7 'DN-Day Centre'
   8 'DN-Other'.

Define !AddHBDictionaryInfo (HB = !CMDEND)
   Value Labels !HB
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
      'S08000028' "Western Isles".
!EndDefine.

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

Value Labels ipdc
   'I' "Inpatient"
   'D' "Daycase".

Value Labels recid
   '00B' "Outpatient (SMR00) appointments"
   '01B' "Acute (SMR01) discharges"
   '02B' "Maternity (SMR02) discharges"
   '04B' "Mental Health (SMR04) admissions/discharges"
   'AE2' "Accident & Emergency attendances"
   'CH' "Care Home records"
   'GLS' "Geriatric Long Stay (SMR01) discharges"
   'NRS' "National Records Service death registrations"
   'PIS' "Prescribing data ".

Value Labels spec
   'A1' "General Medicine"
   'C2' "Accident & Emergency"
   'A11' "Acute Medicine"
   'C3' "Anaesthetics"
   'A2' "Cardiology"
   'C31' "Pain Management"
   'A3' "Clinical Genetics"
   'C4' "Cardiothoracic Surgery"
   'A4' "Tropical Medicine"
   'C41' "Cardiac Surgery"
   'A6' "Infectious Diseases"
   'C42' "Thoracic Surgery"
   'A7' "Dermatology"
   'C5' "Ear, Nose & Throat"
   'A8' "Endocrinology & Diabetes"
   'C51' "Audiological Medicine"
   'A81' "Endocrine"
   'C6' "Neurosurgery"
   'A82' "Diabetes"
   'C7' "Ophthalmology"
   'A9' "Gastroenterology"
   'C8' "Trauma & Orthopaedic Surgery"
   'AA' "Genito-Urinary Medicine"
   'AB' "Geriatric Medicine"
   'C9' "Plastic Surgery"
   'C91' "Cleft Lip & Palate Surgery"
   'AC' "Homoeopathy"
   'CA' "Paediatric Surgery"
   'AD' "Medical Oncology"
   'CB' "Urology"
   'AF' "Paediatrics"
   'D1' "Community Dental Practice"
   'AG' "Renal Medicine"
   'D3' "Oral Surgery(excl C13)"
   'AH' "Neurology"
   'D4' "Oral Medicine"
   'AJ' "Integrative Care"
   'D5' "Orthodontics"
   'AM' "Palliative Medicine"
   'D6' "Restorative Dentistry"
   'AP' "Rehabilitation Medicine"
   'D8' "Paediatric Dentistry"
   'AQ' "Respiratory Medicine"
   'E12' "GP Other than Obstetrics"
   'AR' "Rheumatology"
   'F2' "Gynaecology"
   'AV' "Clinical Neurophysiology"
   'F4' "Community Sexual & Reproductive Health"
   'AW' "Allergy"
   'C1' "General Surgery"
   'H1' "Clinical  Radiology (Diagnostic Radiology)"
   'C11' "General Surgery (excl. Vascular)"
   'H2' "Clinical Oncology"
   'C12' "Vascular Surgery"
   'J3' "Chemical Pathology"
   'J4' "Haematology"
   'C13' "Oral & Maxillofacial Surgery"
   'J5' "Immunology"
   'R11' "Surgical Podiatry".

Value Labels sigfac
   '11' "Other (inc. Clinical Facilities of Standard Speciality Ward 1K, Day Bed Unit 1J)"
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
   '1' "Patient attended and was seen"
   '5' "Patient attended and was not see (CNW - Could Not Wait)"
   '8' "Patient did not attend (DNA)".

Value Labels deceased
   '1' "Deceased"
   '0' "Alive".

