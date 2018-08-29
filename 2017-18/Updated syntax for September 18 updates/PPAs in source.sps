* Encoding: UTF-8.
get file = '/conf/hscdiip/01-Source-linkage-files/source-episode-file-201617.sav'.

string cond1 to cond5 (A47).

compute I = 1.

sort cases by chi cis_marker keydate1_dateformat.
Do if any (recid, "01B", "02B", "04B", "GLS").
    Do if (chi NE lag(chi) or (chi = lag(chi) and cis_marker NE lag(cis_marker)) and newpattype_cis = "Non-Elective").
        Do Repeat cond = cond1 to cond5.
            compute cond = "-".
        End Repeat.
        *Set op exlusions for selection below.
        *Hyper / CHF main ops.
        Compute opexc = 0.
        if range (char.Substr(op1a, 1 , 3), "K01", "K50") or
            any (char.Substr(op1a, 1 , 3), "K56", "K60", "K61") opexc = 1.

        *Attach conditions to episodes. With syntax below, patient can have up to five different conditions per episode.

        *ENT.
        do if any (char.Substr(diag1, 1, 3), "H66", "J06") or
            any (char.Substr(diag1, 1, 4), "J028", "J029", "J038", "J039", "J321").
            compute cond1 = "Ear, nose and throat infections".
        end if.

        *Dental.
        do if range (char.Substr(diag1, 1, 3), "K02", "K06") or
            char.Substr(diag1, 1, 3) = "K08".
            do repeat x = cond1 to cond5.
                if x NE "-" I = (I + 1).
            end repeat.
            if I = 1 cond1 = "Dental conditions".
            if I = 2 cond2 = "Dental conditions".
            if I = 3 cond3 = "Dental conditions".
            if I = 4 cond4 = "Dental conditions".
            if I = 5 cond5 = "Dental conditions".
        end if.

        compute I = 1.

        *Conv.
        do if any (char.Substr(diag1, 1, 3), "G40", "G41", "R56", "O15").
            do repeat x = cond1 to cond5.
                if x NE "-" I = (I + 1).
            end repeat.
            if I = 1 cond1 = "Convulsions and epilepsy".
            if I = 2 cond2 = "Convulsions and epilepsy".
            if I = 3 cond3 = "Convulsions and epilepsy".
            if I = 4 cond4 = "Convulsions and epilepsy".
            if I = 5 cond5 = "Convulsions and epilepsy".
        end if.

        compute I = 1.

        *Gang.
        do if (char.Substr(diag1, 1, 3) = "R02" or
            char.Substr(diag2, 1, 3) = "R02" or
            char.Substr(diag3, 1, 3) = "R02" or
            char.Substr(diag4, 1, 3) = "R02" or
            char.Substr(diag5, 1, 3) = "R02" or
            char.Substr(diag6, 1, 3) = "R02").
            do repeat x = cond1 to cond5.
                if x NE "-" I = (I + 1).
            end repeat.
            if I = 1 cond1 = "Gangrene".
            if I = 2 cond2 = "Gangrene".
            if I = 3 cond3 = "Gangrene".
            if I = 4 cond4 = "Gangrene".
            if I = 5 cond5 = "Gangrene".
        end if.

        compute I = 1.

        *Nutridef.
        do if any (char.Substr(diag1, 1, 3), "E40", "E41", "E43") or
            any (char.Substr(diag1, 1, 4), "E550", "E643", "M833").
            do repeat x = cond1 to cond5.
                if x NE "-" I = (I + 1).
            end repeat.
            if I = 1 cond1 = "Nutritional deficiencies".
            if I = 2 cond2 = "Nutritional deficiencies".
            if I = 3 cond3 = "Nutritional deficiencies".
            if I = 4 cond4 = "Nutritional deficiencies".
            if I = 5 cond5 = "Nutritional deficiencies".
        end if.

        compute I = 1.

        *Dehyd.
        do if char.Substr(diag1, 1, 3) = "E86" or
            any (char.Substr(diag1, 1, 4), "K522", "K528", "K529").
            do repeat x = cond1 to cond5.
                if x NE "-" I = (I + 1).
            end repeat.
            if I = 1 cond1 = "Dehydration and gastroenteritis".
            if I = 2 cond2 = "Dehydration and gastroenteritis".
            if I = 3 cond3 = "Dehydration and gastroenteritis".
            if I = 4 cond4 = "Dehydration and gastroenteritis".
            if I = 5 cond5 = "Dehydration and gastroenteritis".
        end if.

        compute I = 1.

        *Pyelon.
        do if range (char.Substr(diag1, 1, 3), "N10", "N12").
            do repeat x = cond1 to cond5.
                if x NE "-" I = (I + 1).
            end repeat.
            if I = 1 cond1 = "Pyelonephritis".
            if I = 2 cond2 = "Pyelonephritis".
            if I = 3 cond3 = "Pyelonephritis".
            if I = 4 cond4 = "Pyelonephritis".
            if I = 5 cond5 = "Pyelonephritis".
        end if.

        compute I = 1.

        *Perf.
        do if any (char.Substr(diag1, 1, 4), "K250", "K251", "K252", "K254", "K255", "K256", "K260", "K261",
            "K262", "K264", "K265", "K266", "K270", "K271", "K272", "K274",
            "K275", "K276", "K280", "K281", "K282", "K284", "K285", "K286").
            do repeat x = cond1 to cond5.
                if x NE "-" I = (I + 1).
            end repeat.
            if I = 1 cond1 = "Perforated bleeding ulcer".
            if I = 2 cond2 = "Perforated bleeding ulcer".
            if I = 3 cond3 = "Perforated bleeding ulcer".
            if I = 4 cond4 = "Perforated bleeding ulcer".
            if I = 5 cond5 = "Perforated bleeding ulcer".
        end if.

        compute I = 1.

        *Cell.
        do if (any (char.Substr(diag1, 1, 3), "L03", "L04") or
            any (char.Substr(diag1, 1, 4), "L080", "L088", "L089", "L980"))
            and not any (char.Substr(op1a, 1 , 3), "S06", "S57", "S68", "S70", "W90", "X11").
            do repeat x = cond1 to cond5.
                if x NE "-" I = (I + 1).
            end repeat.
            if I = 1 cond1 = "Cellulitis".
            if I = 2 cond2 = "Cellulitis".
            if I = 3 cond3 = "Cellulitis".
            if I = 4 cond4 = "Cellulitis".
            if I = 5 cond5 = "Cellulitis".
        end if.

        compute I = 1.

        *Pelvic.
        do if any (char.Substr(diag1, 1, 3), "N70", "N73").
            do repeat x = cond1 to cond5.
                if x NE "-" I = (I + 1).
            end repeat.
            if I = 1 cond1 = "Pelvic inflamatory disease".
            if I = 2 cond2 = "Pelvic inflamatory disease".
            if I = 3 cond3 = "Pelvic inflamatory disease".
            if I = 4 cond4 = "Pelvic inflamatory disease".
            if I = 5 cond5 = "Pelvic inflamatory disease".
        end if.

        compute I = 1.

        *Flu.
        do if any (char.Substr(diag1, 1, 3), "J10", "J11", "J13") or
            any (char.Substr(diag2, 1, 3), "J10", "J11", "J13") or
            any (char.Substr(diag3, 1, 3), "J10", "J11", "J13") or
            any (char.Substr(diag4, 1, 3), "J10", "J11", "J13") or
            any (char.Substr(diag5, 1, 3), "J10", "J11", "J13") or
            any (char.Substr(diag6, 1, 3), "J10", "J11", "J13") or
            (char.Substr(diag1, 1, 4) = "J181" or char.Substr(diag2, 1, 4) = "J181" or char.Substr(diag3, 1, 4) = "J181" or char.Substr(diag4, 1, 4) = "J181" or char.Substr(diag5, 1, 4) = "J181" or char.Substr(diag6, 1, 4) = "J181").
            do repeat x = cond1 to cond5.
                if x NE "-" I = (I + 1).
            end repeat.
            if I = 1 cond1 = "Influenza and pneumonia".
            if I = 2 cond2 = "Influenza and pneumonia".
            if I = 3 cond3 = "Influenza and pneumonia".
            if I = 4 cond4 = "Influenza and pneumonia".
            if I = 5 cond5 = "Influenza and pneumonia".
        end if.

        compute I = 1.

        *Othvacc.
        do if
            any (char.Substr(diag1, 1, 3), "A35", "A36", "A80", "B05", "B06", "B26") or
            any (char.Substr(diag2, 1, 3), "A35", "A36", "A80", "B05", "B06", "B26") or
            any (char.Substr(diag3, 1, 3), "A35", "A36", "A80", "B05", "B06", "B26") or
            any (char.Substr(diag4, 1, 3), "A35", "A36", "A80", "B05", "B06", "B26") or
            any (char.Substr(diag5, 1, 3), "A35", "A36", "A80", "B05", "B06", "B26") or
            any (char.Substr(diag6, 1, 3), "A35", "A36", "A80", "B05", "B06", "B26") or
            any (char.Substr(diag1, 1, 4), "A370", "A379", "B161", "B169") or
            any (char.Substr(diag2, 1, 4), "A370", "A379", "B161", "B169") or
            any(char.Substr(diag3, 1, 4), "A370", "A379", "B161", "B169") or
            any (char.Substr(diag4, 1, 4), "A370", "A379", "B161", "B169") or
            any (char.Substr(diag5, 1, 4), "A370", "A379", "B161", "B169") or
            any (char.Substr(diag6, 1, 4), "A370", "A379", "B161", "B169").
            do repeat x = cond1 to cond5.
                if x NE "-" I = (I + 1).
            end repeat.
            if I = 1 cond1 = "Other vaccine preventable".
            if I = 2 cond2 = "Other vaccine preventable".
            if I = 3 cond3 = "Other vaccine preventable".
            if I = 4 cond4 = "Other vaccine preventable".
            if I = 5 cond5 = "Other vaccine preventable".
        end if.

        compute I = 1.

        *Iron.
        do if any (char.Substr(diag1, 1, 4), "D501", "D508", "D509").
            do repeat x = cond1 to cond5.
                if x NE "-" I = (I + 1).
            end repeat.
            if I = 1 cond1 = "Iron deficiency anaemia".
            if I = 2 cond2 = "Iron deficiency anaemia".
            if I = 3 cond3 = "Iron deficiency anaemia".
            if I = 4 cond4 = "Iron deficiency anaemia".
            if I = 5 cond5 = "Iron deficiency anaemia".
        end if.

        compute I = 1.

        *Asthma.
        do if any (char.Substr(diag1, 1, 3), "J45", "J46").
            do repeat x = cond1 to cond5.
                if x NE "-" I = (I + 1).
            end repeat.
            if I = 1 cond1 = "Asthma".
            if I = 2 cond2 = "Asthma".
            if I = 3 cond3 = "Asthma".
            if I = 4 cond4 = "Asthma".
            if I = 5 cond5 = "Asthma".
        end if.

        compute I = 1.

        *Diabetes.
        do if any (char.Substr(diag1, 1, 4), "E100", "E101", "E102", "E103", "E104", "E105", "E106", "E107", "E108", "E110",
            "E111", "E112", "E113", "E114", "E115", "E116", "E117", "E118", "E120", "E121",
            "E122", "E123", "E124", "E125", "E126", "E127", "E128", "E130", "E131", "E132",
            "E133", "E134", "E135", "E136", "E137", "E138", "E140", "E141", "E142", "E143",
            "E144", "E145", "E146", "E147", "E148")
            or
            any (char.Substr(diag2, 1, 4), "E100", "E101", "E102", "E103", "E104", "E105", "E106", "E107", "E108", "E110",
            "E111", "E112", "E113", "E114", "E115", "E116", "E117", "E118", "E120", "E121",
            "E122", "E123", "E124", "E125", "E126", "E127", "E128", "E130", "E131", "E132",
            "E133", "E134", "E135", "E136", "E137", "E138", "E140", "E141", "E142", "E143",
            "E144", "E145", "E146", "E147", "E148")
            or
            any (char.Substr(diag3, 1, 4), "E100", "E101", "E102", "E103", "E104", "E105", "E106", "E107", "E108", "E110",
            "E111", "E112", "E113", "E114", "E115", "E116", "E117", "E118", "E120", "E121",
            "E122", "E123", "E124", "E125", "E126", "E127", "E128", "E130", "E131", "E132",
            "E133", "E134", "E135", "E136", "E137", "E138", "E140", "E141", "E142", "E143",
            "E144", "E145", "E146", "E147", "E148")
            or
            any (char.Substr(diag4, 1, 4), "E100", "E101", "E102", "E103", "E104", "E105", "E106", "E107", "E108", "E110",
            "E111", "E112", "E113", "E114", "E115", "E116", "E117", "E118", "E120", "E121",
            "E122", "E123", "E124", "E125", "E126", "E127", "E128", "E130", "E131", "E132",
            "E133", "E134", "E135", "E136", "E137", "E138", "E140", "E141", "E142", "E143",
            "E144", "E145", "E146", "E147", "E148")
            or
            any (char.Substr(diag5, 1, 4), "E100", "E101", "E102", "E103", "E104", "E105", "E106", "E107", "E108", "E110",
            "E111", "E112", "E113", "E114", "E115", "E116", "E117", "E118", "E120", "E121",
            "E122", "E123", "E124", "E125", "E126", "E127", "E128", "E130", "E131", "E132",
            "E133", "E134", "E135", "E136", "E137", "E138", "E140", "E141", "E142", "E143",
            "E144", "E145", "E146", "E147", "E148")
            or
            any (char.Substr(diag6, 1, 4), "E100", "E101", "E102", "E103", "E104", "E105", "E106", "E107", "E108", "E110",
            "E111", "E112", "E113", "E114", "E115", "E116", "E117", "E118", "E120", "E121",
            "E122", "E123", "E124", "E125", "E126", "E127", "E128", "E130", "E131", "E132",
            "E133", "E134", "E135", "E136", "E137", "E138", "E140", "E141", "E142", "E143",
            "E144", "E145", "E146", "E147", "E148").
            do repeat x = cond1 to cond5.
                if x NE "-" I = (I + 1).
            end repeat.
            if I = 1 cond1 = "Diabetes complications".
            if I = 2 cond2 = "Diabetes complications".
            if I = 3 cond3 = "Diabetes complications".
            if I = 4 cond4 = "Diabetes complications".
            if I = 5 cond5 = "Diabetes complications".
        end if.

        compute I = 1.

        *Hypert.
        do if (char.Substr(diag1, 1, 3) = "I10" or
            char.Substr(diag1, 1, 4) = "I119") and opexc  =  0.
            do repeat x = cond1 to cond5.
                if x NE "-" I = (I + 1).
            end repeat.
            if I = 1 cond1 = "Hypertension".
            if I = 2 cond2 = "Hypertension".
            if I = 3 cond3 = "Hypertension".
            if I = 4 cond4 = "Hypertension".
            if I = 5 cond5 = "Hypertension".
        end if.

        compute I = 1.

        *Angina.
        do if (char.Substr(diag1, 1, 3) = "I20")
            and not any (char.Substr(op1a, 1 , 3), "K40", "K45", "K49", "K60", "K65", "K66").
            do repeat x = cond1 to cond5.
                if x NE "-" I = (I + 1).
            end repeat.
            if I = 1 cond1 = "Angina".
            if I = 2 cond2 = "Angina".
            if I = 3 cond3 = "Angina".
            if I = 4 cond4 = "Angina".
            if I = 5 cond5 = "Angina".
        end if.

        compute I = 1.

        *Copd.
        do if (range (char.Substr(diag1, 1, 3), "J41", "J44") or char.Substr(diag1, 1, 3) = "J47") or
            (char.Substr(diag1, 1, 3) = "J20" and (range (char.Substr(diag2, 1, 3), "J41", "J44") or char.Substr(diag2, 1, 3) = "J47")).
            do repeat x = cond1 to cond5.
                if x NE "-" I = (I + 1).
            end repeat.
            if I = 1 cond1 = "COPD".
            if I = 2 cond2 = "COPD".
            if I = 3 cond3 = "COPD".
            if I = 4 cond4 = "COPD".
            if I = 5 cond5 = "COPD".
        end if.

        compute I = 1.

        *Chf.
        do if (char.Substr(diag1, 1, 3) = "I50" or
            char.Substr(diag1, 1, 3) = "J81" or
            char.Substr(diag1, 1, 4) = "I110") and
            opexc  =  0.
            do repeat x = cond1 to cond5.
                if x NE "-" I = (I + 1).
            end repeat.
            if I = 1 cond1 = "Congestive Heart Failure".
            if I = 2 cond2 = "Congestive Heart Failure".
            if I = 3 cond3 = "Congestive Heart Failure".
            if I = 4 cond4 = "Congestive Heart Failure".
            if I = 5 cond5 = "Congestive Heart Failure".
        end if.

        compute I = 1.
        Do if cond1 NE "-".
            Compute PPA = 1.
        Else.
            Compute PPA = 0.
        End If.
    End if.
End if.

* Define Variable Properties.
MISSING VALUES cond1 to cond5('        ').
VALUE LABELS cond1 to cond5
  '' '(Missing)'
  '-' 'None'.

aggregate
    /Break chi cis_marker
    /CIS_PPA = Max(PPA).

Frequencies cond1 to cond5 PPA CIS_PPA.


