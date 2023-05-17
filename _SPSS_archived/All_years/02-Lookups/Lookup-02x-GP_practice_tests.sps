* Encoding: UTF-8.

* Tests for new postcode lookup.
get file = !Lookup_dir_slf + "source_GPprac_lookup_" + !LatestUpdate + ".zsav".

* Create a flag for counting those with / without a cluster.
Do if Cluster = "".
    Compute Cluster_no = 1.
Else.
    Compute Cluster_yes = 1.
End if.

* Create a flag for counting HB2019.
If hbpraccode = 'S08000015'     NHS_Ayrshire_and_Arran = 1.
If hbpraccode = 'S08000016'  NHS_Borders = 1.
If hbpraccode = 'S08000017'  NHS_Dumfries_and_Galloway = 1.
If hbpraccode = 'S08000019'  NHS_Forth_Valley = 1.
If hbpraccode = 'S08000020'  NHS_Grampian = 1.
If hbpraccode = 'S08000021'  NHS_Greater_Glasgow_and_Clyde = 1.
If hbpraccode = 'S08000022'  NHS_Highland = 1.
If hbpraccode = 'S08000023'  NHS_Lanarkshire = 1.
If hbpraccode = 'S08000024' NHS_Lothian = 1.
If hbpraccode = 'S08000025'  NHS_Orkney = 1.
If hbpraccode = 'S08000026'  NHS_Shetland = 1.
If hbpraccode = 'S08000028'  NHS_Western_Isles = 1.
If hbpraccode = 'S08000029' NHS_Fife = 1.
If hbpraccode = 'S08000030'  NHS_Tayside = 1.
if hbpraccode = '' hbpraccode_missing = 1.


* Get values for whole file.
Dataset Declare gpprac_new.
aggregate outfile = gpprac_new
    /break
    /n_has_gpprac = n
    /cluster_no cluster_yes = sum(cluster_no cluster_yes)
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
    /All_hbpraccode_missing = sum(hbpraccode_missing).

* Restructure for easy analysis and viewing.
Dataset activate gpprac_new.
Varstocases
    /Make New_Value from n_has_gpprac to All_hbpraccode_missing
    /Index Measure (New_Value).
Sort cases by Measure.

*************************************************************************************************************.

*************************************************************************************************************.
*Tests for previous postcode lookup.
get file = !Lookup_dir_slf + "source_GPprac_lookup_" + !PreviousUpdate + ".zsav".

* Create a flag for counting those with / without a cluster.
Do if Cluster = "".
    Compute Cluster_no = 1.
Else.
    Compute Cluster_yes = 1.
End if.

* Create a flag for counting HB2019.
If hbpraccode = 'S08000015' NHS_Ayrshire_and_Arran = 1.
If hbpraccode = 'S08000016' NHS_Borders = 1.
If hbpraccode = 'S08000017' NHS_Dumfries_and_Galloway = 1.
If hbpraccode = 'S08000019' NHS_Forth_Valley = 1.
If hbpraccode = 'S08000020' NHS_Grampian = 1.
If hbpraccode = 'S08000021' NHS_Greater_Glasgow_and_Clyde = 1.
If hbpraccode = 'S08000022' NHS_Highland = 1.
If hbpraccode = 'S08000023' NHS_Lanarkshire = 1.
If hbpraccode = 'S08000024' NHS_Lothian = 1.
If hbpraccode = 'S08000025' NHS_Orkney = 1.
If hbpraccode = 'S08000026' NHS_Shetland = 1.
If hbpraccode = 'S08000028' NHS_Western_Isles = 1.
If hbpraccode = 'S08000029' NHS_Fife = 1.
If hbpraccode = 'S08000030' NHS_Tayside = 1.
if hbpraccode = '' hbpraccode_missing = 1.


* Get values for whole file.
Dataset Declare gpprac_previous.
aggregate outfile = gpprac_previous
    /break
    /n_has_gpprac = n
    /cluster_no cluster_yes = sum(cluster_no cluster_yes)
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
    /All_hbpraccode_missing = sum(hbpraccode_missing).


Dataset activate gpprac_previous.
Varstocases
    /Make Existing_Value from n_has_gpprac to All_hbpraccode_missing
    /Index Measure (Existing_Value).
Sort cases by Measure.

*************************************************************************************************************.

*************************************************************************************************************.
* Match together.
match files
    /file = gpprac_previous
    /file = gpprac_new
    /By Measure.
Dataset Name PostcodeLookupComparison.

* Close both datasets.
Dataset close gpprac_previous.
Dataset close gpprac_new.

* Produce comparisons.
Compute Difference = New_Value - Existing_Value.
Do if Existing_Value NE 0.
    Compute Pct_change = Difference / Existing_Value * 100.
End if.
Compute Issue = abs(Pct_change) > 5.
Alter Type Issue (F1.0) Pct_change (PCT4.2).

* Highlight issues.
Crosstabs Measure by Issue.

*Save test file.
Save Outfile = !Lookup_dir_slf + "source_GPprac_lookup_" + !LatestUpdate + "_tests.zsav"
    /Zcompressed.
