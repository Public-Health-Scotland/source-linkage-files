* Encoding: UTF-8.

*Tests for new postcode lookup.
get file = !Lookup_dir_slf + "source_postcode_lookup_" + !LatestUpdate + ".zsav".

*create a flag for counting unique postcode.
If lag(postcode) NE postcode No_postcode = 1. 

*create a flag for counting HB2019.
If HB2019 = 'S08000015' NHS_Ayrshire_and_Arran = 1.
If HB2019 = 'S08000016'	 NHS_Borders = 1.
If HB2019 = 'S08000017'	 NHS_Dumfries_and_Galloway = 1.
If HB2019 = 'S08000019'	 NHS_Forth_Valley = 1. 
If HB2019 = 'S08000020'	 NHS_Grampian = 1. 
If HB2019 = 'S08000022'	 NHS_Highland = 1. 
If HB2019 = 'S08000024' NHS_Lothian = 1. 
If HB2019 = 'S08000025'	 NHS_Orkney = 1. 
If HB2019 = 'S08000026'	 NHS_Shetland = 1. 
If HB2019 = 'S08000028'	 NHS_Western_Isles = 1.
If HB2019 = 'S08000029' NHS_Fife = 1. 
If HB2019 = 'S08000030'	 NHS_Tayside = 1.
If HB2019 = 'S08000031'	 NHS_Greater_Glasgow_and_Clyde = 1. 
If HB2019 = 'S08000032'	 NHS_Lanarkshire = 1. 

*Create a flag for counting HSCP2019.
If HSCP2019 = 'S37000001' Aberdeen_City = 1.
If HSCP2019 = 'S37000002' Aberdeenshire = 1. 
If HSCP2019 = 'S37000003' Angus = 1.
If HSCP2019 = 'S37000004' Argyll_and_Bute = 1. 
If HSCP2019 = 'S37000005' Clackmannanshire_and_Stirling = 1. 
If HSCP2019 = 'S37000006' Dumfries_and_Galloway = 1. 
If HSCP2019 = 'S37000007' Dundee_City = 1. 
If HSCP2019 = 'S37000008' East_Ayrshire = 1. 
If HSCP2019 = 'S37000009' East_Dunbartonshire = 1. 
If HSCP2019 = 'S37000010' East_Lothian = 1.
If HSCP2019 = 'S37000011' East_Renfrewshire = 1.
If HSCP2019 = 'S37000012' Edinburgh = 1. 
If HSCP2019 = 'S37000013' Falkirk = 1.
If HSCP2019 = 'S37000016' Highland = 1.
If HSCP2019 = 'S37000017' Inverclyde = 1. 
If HSCP2019 = 'S37000018' Midlothian = 1.
If HSCP2019 = 'S37000019' Moray = 1. 
If HSCP2019 = 'S37000020' North_Ayrshire = 1. 
If HSCP2019 = 'S37000022' Orkney_Islands = 1.
If HSCP2019 = 'S37000024' Renfrewshire = 1. 
If HSCP2019 = 'S37000025' Scottish_Borders = 1.
If HSCP2019 = 'S37000026' Shetland_Islands = 1. 
If HSCP2019 = 'S37000027' South_Ayrshire = 1. 
If HSCP2019 = 'S37000028' South_Lanarkshire = 1.
If HSCP2019 = 'S37000029' West_Dunbartonshire = 1. 
If HSCP2019 = 'S37000030' West_Lothian = 1. 
If HSCP2019 = 'S37000031' Western_Isles = 1.
If HSCP2019 = 'S37000032' Fife = 1.
If HSCP2019 = 'S37000033' Perth_and_Kinross = 1. 
If HSCP2019 = 'S37000034' Glasgow_City = 1.
If HSCP2019 = 'S37000035' North_Lanarkshire = 1.


* Get values for whole file.
Dataset Declare SLFnew.
aggregate outfile = SLFnew
    /break
    /n_postcode = Sum(No_postcode)
    /All_NHS_Ayrshire_and_Arran = Sum(NHS_Ayrshire_and_Arran)
    /All_NHS_Borders = Sum(NHS_Borders)
    /All_NHS_Dumfries_and_Galloway = Sum(NHS_Dumfries_and_Galloway)
    /All_NHS_Forth_Valley = Sum(NHS_Forth_Valley)
    /All_NHS_Grampian = Sum(NHS_Grampian)
    /All_NHS_Highland = Sum(NHS_Highland) 
    /All_NHS_Lothian = Sum(NHS_Lothian)
    /All_NHS_Orkney = Sum(NHS_Orkney)
    /All_NHS_Shetland = Sum(NHS_Shetland)
    /All_NHS_Western_Isles = Sum(NHS_Western_Isles)
    /All_NHS_Fife = Sum(NHS_Fife)
    /All_NHS_Tayside = Sum(NHS_Tayside)
    /All_NHS_Greater_Glasgow_and_Clyde = Sum(NHS_Greater_Glasgow_and_Clyde)
    /All_NHS_Lanarkshire = Sum(NHS_Lanarkshire)
    /All_Aberdeen_City = Sum(Aberdeen_City)
    /All_Aberdeenshire = Sum(Aberdeenshire)
    /All_Angus = Sum(Angus)
    /All_Argyll_and_Bute = Sum(Argyll_and_Bute)
    /All_Clackmannanshire_and_Stirling = Sum(Clackmannanshire_and_Stirling)
    /All_Dumfries_and_Galloway = Sum(Dumfries_and_Galloway)
    /All_Dundee_City = Sum(Dundee_City)
    /All_East_Ayrshire = Sum(East_Ayrshire)
    /All_East_Dunbartonshire = Sum(East_Dunbartonshire)
    /All_East_Lothian = Sum(East_Lothian)
    /All_East_Renfrewshire = Sum(East_Renfrewshire)
    /All_Edinburgh = Sum(Edinburgh)
    /All_Falkirk = Sum(Falkirk)
    /All_Highland = Sum(Highland)
    /All_Inverclyde = Sum(Inverclyde)
    /All_Midlothian = Sum(Midlothian)
    /All_Moray = Sum(Moray)
    /All_North_Ayrshire = Sum(North_Ayrshire)
    /All_Orkney_Islands = Sum(Orkney_Islands)
    /All_Renfrewshire = Sum(Renfrewshire)
    /All_Scottish_Borders = Sum(Scottish_Borders)
    /All_Shetland_Islands = Sum(Shetland_Islands)
    /All_South_Ayrshire = Sum(South_Ayrshire)
    /All_South_Lanarkshire = Sum(South_Lanarkshire)
    /All_West_Dunbartonshire = Sum(West_Dunbartonshire)
    /All_West_Lothian = Sum(West_Lothian)
    /All_Western_Isles = Sum(Western_Isles)
    /All_Fife = Sum(Fife)
    /All_Perth_and_Kinross = Sum(Perth_and_Kinross)
    /All_Glasgow_City = Sum(Glasgow_City)
    /All_North_Lanarkshire = Sum(North_Lanarkshire).


 * Restructure for easy analysis and viewing.
Dataset activate SLFnew.
Varstocases
    /Make New_Value from n_postcode to All_North_Lanarkshire
    /Index Measure (New_Value).
Sort cases by Measure.

*************************************************************************************************************.

*************************************************************************************************************.
*Tests for previous postcode lookup.
get file = !Lookup_dir_slf + "source_postcode_lookup_" + !PreviousUpdate + ".zsav".

*create a flag for counting unique postcode.
If lag(postcode) NE postcode No_postcode = 1. 

*create a flag for counting HB2019.
If HB2019 = 'S08000015' NHS_Ayrshire_and_Arran = 1.
If HB2019 = 'S08000016'	 NHS_Borders = 1.
If HB2019 = 'S08000017'	 NHS_Dumfries_and_Galloway = 1.
If HB2019 = 'S08000019'	 NHS_Forth_Valley = 1. 
If HB2019 = 'S08000020'	 NHS_Grampian = 1. 
If HB2019 = 'S08000022'	 NHS_Highland = 1. 
If HB2019 = 'S08000024' NHS_Lothian = 1. 
If HB2019 = 'S08000025'	 NHS_Orkney = 1. 
If HB2019 = 'S08000026'	 NHS_Shetland = 1. 
If HB2019 = 'S08000028'	 NHS_Western_Isles = 1.
If HB2019 = 'S08000029' NHS_Fife = 1. 
If HB2019 = 'S08000030'	 NHS_Tayside = 1.
If HB2019 = 'S08000031'	 NHS_Greater_Glasgow_and_Clyde = 1. 
If HB2019 = 'S08000032'	 NHS_Lanarkshire = 1. 

*Create a flag for counting HSCP2019.
If HSCP2019 = 'S37000001' Aberdeen_City = 1.
If HSCP2019 = 'S37000002' Aberdeenshire = 1. 
If HSCP2019 = 'S37000003' Angus = 1.
If HSCP2019 = 'S37000004' Argyll_and_Bute = 1. 
If HSCP2019 = 'S37000005' Clackmannanshire_and_Stirling = 1. 
If HSCP2019 = 'S37000006' Dumfries_and_Galloway = 1. 
If HSCP2019 = 'S37000007' Dundee_City = 1. 
If HSCP2019 = 'S37000008' East_Ayrshire = 1. 
If HSCP2019 = 'S37000009' East_Dunbartonshire = 1. 
If HSCP2019 = 'S37000010' East_Lothian = 1.
If HSCP2019 = 'S37000011' East_Renfrewshire = 1.
If HSCP2019 = 'S37000012' Edinburgh = 1. 
If HSCP2019 = 'S37000013' Falkirk = 1.
If HSCP2019 = 'S37000016' Highland = 1.
If HSCP2019 = 'S37000017' Inverclyde = 1. 
If HSCP2019 = 'S37000018' Midlothian = 1.
If HSCP2019 = 'S37000019' Moray = 1. 
If HSCP2019 = 'S37000020' North_Ayrshire = 1. 
If HSCP2019 = 'S37000022' Orkney_Islands = 1.
If HSCP2019 = 'S37000024' Renfrewshire = 1. 
If HSCP2019 = 'S37000025' Scottish_Borders = 1.
If HSCP2019 = 'S37000026' Shetland_Islands = 1. 
If HSCP2019 = 'S37000027' South_Ayrshire = 1. 
If HSCP2019 = 'S37000028' South_Lanarkshire = 1.
If HSCP2019 = 'S37000029' West_Dunbartonshire = 1. 
If HSCP2019 = 'S37000030' West_Lothian = 1. 
If HSCP2019 = 'S37000031' Western_Isles = 1.
If HSCP2019 = 'S37000032' Fife = 1.
If HSCP2019 = 'S37000033' Perth_and_Kinross = 1. 
If HSCP2019 = 'S37000034' Glasgow_City = 1.
If HSCP2019 = 'S37000035' North_Lanarkshire = 1.


* Get values for whole file.
Dataset Declare SLFexisting.
aggregate outfile = SLFexisting
    /break
    /n_postcode = Sum(No_postcode)
    /All_NHS_Ayrshire_and_Arran = Sum(NHS_Ayrshire_and_Arran)
    /All_NHS_Borders = Sum(NHS_Borders)
    /All_NHS_Dumfries_and_Galloway = Sum(NHS_Dumfries_and_Galloway)
    /All_NHS_Forth_Valley = Sum(NHS_Forth_Valley)
    /All_NHS_Grampian = Sum(NHS_Grampian)
    /All_NHS_Highland = Sum(NHS_Highland) 
    /All_NHS_Lothian = Sum(NHS_Lothian)
    /All_NHS_Orkney = Sum(NHS_Orkney)
    /All_NHS_Shetland = Sum(NHS_Shetland)
    /All_NHS_Western_Isles = Sum(NHS_Western_Isles)
    /All_NHS_Fife = Sum(NHS_Fife)
    /All_NHS_Tayside = Sum(NHS_Tayside)
    /All_NHS_Greater_Glasgow_and_Clyde = Sum(NHS_Greater_Glasgow_and_Clyde)
    /All_NHS_Lanarkshire = Sum(NHS_Lanarkshire)
    /All_Aberdeen_City = Sum(Aberdeen_City)
    /All_Aberdeenshire = Sum(Aberdeenshire)
    /All_Angus = Sum(Angus)
    /All_Argyll_and_Bute = Sum(Argyll_and_Bute)
    /All_Clackmannanshire_and_Stirling = Sum(Clackmannanshire_and_Stirling)
    /All_Dumfries_and_Galloway = Sum(Dumfries_and_Galloway)
    /All_Dundee_City = Sum(Dundee_City)
    /All_East_Ayrshire = Sum(East_Ayrshire)
    /All_East_Dunbartonshire = Sum(East_Dunbartonshire)
    /All_East_Lothian = Sum(East_Lothian)
    /All_East_Renfrewshire = Sum(East_Renfrewshire)
    /All_Edinburgh = Sum(Edinburgh)
    /All_Falkirk = Sum(Falkirk)
    /All_Highland = Sum(Highland)
    /All_Inverclyde = Sum(Inverclyde)
    /All_Midlothian = Sum(Midlothian)
    /All_Moray = Sum(Moray)
    /All_North_Ayrshire = Sum(North_Ayrshire)
    /All_Orkney_Islands = Sum(Orkney_Islands)
    /All_Renfrewshire = Sum(Renfrewshire)
    /All_Scottish_Borders = Sum(Scottish_Borders)
    /All_Shetland_Islands = Sum(Shetland_Islands)
    /All_South_Ayrshire = Sum(South_Ayrshire)
    /All_South_Lanarkshire = Sum(South_Lanarkshire)
    /All_West_Dunbartonshire = Sum(West_Dunbartonshire)
    /All_West_Lothian = Sum(West_Lothian)
    /All_Western_Isles = Sum(Western_Isles)
    /All_Fife = Sum(Fife)
    /All_Perth_and_Kinross = Sum(Perth_and_Kinross)
    /All_Glasgow_City = Sum(Glasgow_City)
    /All_North_Lanarkshire = Sum(North_Lanarkshire).

Dataset activate SLFexisting.
Varstocases
    /Make Existing_Value from n_postcode to All_North_Lanarkshire
    /Index Measure (Existing_Value).
Sort cases by Measure.

*************************************************************************************************************.

*************************************************************************************************************.
 * Match together.
match files
    /file = SLFexisting
    /file = SLFnew
    /By Measure.
Dataset Name PostcodeLookupComparison.

 * Close both datasets.
Dataset close SLFnew.
Dataset close SLFexisting.

 * Produce comparisons.
Compute Difference = New_Value - Existing_Value.
Do if Existing_Value NE 0.
    Compute PctChange = Difference / Existing_Value * 100.
End if.
Compute Issue = abs(PctChange) > 5.
Alter Type Issue (F1.0) PctChange (PCT4.2).

 * Highlight issues.
Crosstabs Measure by Issue.

*Save test file.
Save Outfile = !Lookup_dir_slf + "source_postcode_lookup_" + !LatestUpdate + "_tests.zsav"
/Zcompressed.
