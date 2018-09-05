* Encoding: UTF-8.
Define !Existing(FY = !Tokens(1))
get file = !Quote(!Concat("/conf/hscdiip/01-Source-linkage-files/source-episode-file-20", !FY, ".sav")).
Dataset Name !Concat(Existing, !FY)
!EndDefine.

Define !New(FY = !Tokens(1))
get file = !Quote(!Concat("/conf/sourcedev/source-episode-file-20", !FY, ".zsav")).
Dataset Name !Concat(New, !FY)
!EndDefine.

Define !Tests()

!EndDefine.

!Existing FY = 1617.
!Tests.

!New FY = 1617.
!Tests.

if recid = "DD" and keydate2_dateformat = date.dmy(1, 7, 2016) flag = 1.


GET FILE='/conf/sourcedev/Source Linkage File Updates/1819/source-episode-file-201819.zsav'.
Dataset Name Episode1819.
Title "Episode File 2018/19".

   sort cases by recid.
   split file by recid.
   
   Descriptives keydate1_dateformat keydate2_dateformat.
   
   Frequencies gender.
   
   Descriptives age dob.
   
   Descriptives stay yearstay.
   
   Frequencies lca hbrescode.
   
   Frequencies deceased.
   
   Descriptives cost_total_net Cost_Total_Net_incDNAs.


Do If age < 0.
    Compute NegativeAge = 1.
ELSE.   
 Compute NegativeAge = 0.
End if.

Do If stay < 0.
    Compute NegativeStay = 1.
ELSE.   
 Compute NegativeStay = 0.
End if.

Frequencies NegativeAge NegativeStay.

Do If chi NE "".
    Compute #CHI_gender = Number(char.SUBSTR(chi, 9, 1), F1.0).
    Do If Mod(#CHI_gender, 2) = 1.
        If gender = 2 WrongGender = 1.
    Else If Mod(#CHI_gender, 2) = 0.
        If gender = 1 WrongGender = 2.
    End if.
End if.

Frequencies WrongGender.


