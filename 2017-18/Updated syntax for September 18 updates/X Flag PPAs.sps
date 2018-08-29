* Encoding: UTF-8.
get file = !File + "temp-source-episode-file-4-" + !FY + ".zsav".

sort cases by chi cis_marker keydate1_dateformat.
 
* Acute records.
Do if any (recid, "01B", "02B", "04B", "GLS").
    * First record in CIS.
    Do if (chi NE lag(chi) or (chi = lag(chi) and cis_marker NE lag(cis_marker))).
        * Non-elective original admission.
        Do if newpattype_cis = "Non-Elective".
            Compute PPA = 0.
            * Initialise PPA flag for relevant records.
            

            *Set op exclusions for selection below.
            *Hyper / CHF main ops.
            Do if range (char.Substr(op1a, 1 , 3), "K01", "K50") or
                any (char.Substr(op1a, 1 , 3), "K56", "K60", "K61").
                Compute #ExcludingOperation = 1.
            Else.
                Compute #ExcludingOperation = 0.
            End If.

            *Attach conditions to episodes. With syntax below, patient can have up to five different conditions per episode.
            *ENT.
            Do if any (char.Substr(diag1, 1, 3), "H66", "J06") or
                any (char.Substr(diag1, 1, 4), "J028", "J029", "J038", "J039", "J321").
                compute PPA = 1.
                *Dental.
            Else if range (char.Substr(diag1, 1, 3), "K02", "K06") or
                char.Substr(diag1, 1, 3) = "K08".
                compute PPA = 1.
                *Conv.
            Else if any (char.Substr(diag1, 1, 3), "G40", "G41", "R56", "O15").
                compute PPA = 1.
                *Gang.
            Else if (char.Substr(diag1, 1, 3) = "R02" or
                char.Substr(diag2, 1, 3) = "R02" or
                char.Substr(diag3, 1, 3) = "R02" or
                char.Substr(diag4, 1, 3) = "R02" or
                char.Substr(diag5, 1, 3) = "R02" or
                char.Substr(diag6, 1, 3) = "R02").
                compute PPA = 1.
                *Nutridef.
            Else if any (char.Substr(diag1, 1, 3), "E40", "E41", "E43") or
                any (char.Substr(diag1, 1, 4), "E550", "E643", "M833").
                compute PPA = 1.
                *Dehyd.
            Else if char.Substr(diag1, 1, 3) = "E86" or
                any (char.Substr(diag1, 1, 4), "K522", "K528", "K529").
                compute PPA = 1.
                *Pyelon.
            Else if range (char.Substr(diag1, 1, 3), "N10", "N12").
                compute PPA = 1.
                *Perf.
            Else if any (char.Substr(diag1, 1, 4), "K250", "K251", "K252", "K254", "K255", "K256", "K260", "K261",
                "K262", "K264", "K265", "K266", "K270", "K271", "K272", "K274",
                "K275", "K276", "K280", "K281", "K282", "K284", "K285", "K286").
                compute PPA = 1.
                *Cell.
            Else if (any (char.Substr(diag1, 1, 3), "L03", "L04") or
                any (char.Substr(diag1, 1, 4), "L080", "L088", "L089", "L980"))
                and not any (char.Substr(op1a, 1 , 3), "S06", "S57", "S68", "S70", "W90", "X11").
                compute PPA = 1.
                *Pelvic.
            Else if any (char.Substr(diag1, 1, 3), "N70", "N73").
                compute PPA = 1.
                *Flu.
            Else if any (char.Substr(diag1, 1, 3), "J10", "J11", "J13") or
                any (char.Substr(diag2, 1, 3), "J10", "J11", "J13") or
                any (char.Substr(diag3, 1, 3), "J10", "J11", "J13") or
                any (char.Substr(diag4, 1, 3), "J10", "J11", "J13") or
                any (char.Substr(diag5, 1, 3), "J10", "J11", "J13") or
                any (char.Substr(diag6, 1, 3), "J10", "J11", "J13") or
                (char.Substr(diag1, 1, 4) = "J181" or char.Substr(diag2, 1, 4) = "J181" or char.Substr(diag3, 1, 4) = "J181" or char.Substr(diag4, 1, 4) = "J181" or char.Substr(diag5, 1, 4) = "J181" or char.Substr(diag6, 1, 4) = "J181").
                compute PPA = 1.
                *Othvacc.
            Else if
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
                compute PPA = 1.
                *Iron.
            Else if any (char.Substr(diag1, 1, 4), "D501", "D508", "D509").
                compute PPA = 1.
                *Asthma.
            Else if any (char.Substr(diag1, 1, 3), "J45", "J46").
                compute PPA = 1.
                *Diabetes.
            Else if any (char.Substr(diag1, 1, 4), "E100", "E101", "E102", "E103", "E104", "E105", "E106", "E107", "E108", "E110",
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
                compute PPA = 1.
                *Hypert.
            Else if (char.Substr(diag1, 1, 3) = "I10" or
                char.Substr(diag1, 1, 4) = "I119") and #ExcludingOperation  =  0.
                compute PPA = 1.
                *Angina.
            Else if (char.Substr(diag1, 1, 3) = "I20")
                and not any (char.Substr(op1a, 1 , 3), "K40", "K45", "K49", "K60", "K65", "K66").
                compute PPA = 1.
                *Copd.
            Else if (range (char.Substr(diag1, 1, 3), "J41", "J44") or char.Substr(diag1, 1, 3) = "J47") or
                (char.Substr(diag1, 1, 3) = "J20" and (range (char.Substr(diag2, 1, 3), "J41", "J44") or char.Substr(diag2, 1, 3) = "J47")).
                compute PPA = 1.
                *Chf.
            Else if (char.Substr(diag1, 1, 3) = "I50" or
                char.Substr(diag1, 1, 3) = "J81" or
                char.Substr(diag1, 1, 4) = "I110") and
                #ExcludingOperation  =  0.
                compute PPA = 1.
            End if.
        End if.
    End if.
End if.

aggregate
    /Break chi cis_marker
    /CIS_PPA = Max(PPA).

Frequencies PPA CIS_PPA.

save outfile = !File + "temp-source-episode-file-5-" + !FY + ".zsav"    
    /Drop PPA
    /zcompressed.


