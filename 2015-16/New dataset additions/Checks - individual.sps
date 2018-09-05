* Encoding: UTF-8.
Define !Existing(FY = !Tokens(1))
get file = !Quote(!Concat("/conf/hscdiip/01-Source-linkage-files/source-individual-file-20", !FY, ".sav")).
Dataset Name !Concat(Existing, !FY)
!EndDefine.

Define !New(FY = !Tokens(1))
get file = !Quote(!Concat("/conf/sourcedev/source-individual-file-20", !FY, ".zsav")).
Dataset Name !Concat(New, !FY)
!EndDefine.

Define !Tests()
   If health_postcode = "" Missing_PC = 1.
   If gpprac = "" Missing_prac = 1. 

   Frequencies Missing_PC Missing_Prac.
   
   Descriptives dob.

   Descriptives health_net_cost health_net_costincDNAs.
   
   Frequencies lca hbres chp.
   
   Frequencies deceased_flag.

   Descriptives acute_episodes mat_episodes mentalh_episodes gls_episodes op_newcons_attendances op_newcons_dnas ae_attendances.
   
!EndDefine.

!Existing FY = 1819.
!Tests.

!New FY = 1819.
!Tests.


GET FILE='/conf/sourcedev/Source Linkage File Updates/1819/source-individual-file-201819.zsav'.
Dataset Name Individual1819.
Title "Individual File 201819".

If postcode = "" Missing_PC = 1.
If Missing(gpprac)  Missing_prac = 1.

Frequencies Missing_PC Missing_Prac.

Descriptives dob.

Descriptives health_net_cost health_net_costincDNAs.

Frequencies lca hbrescode chp.

Frequencies deceased.

Descriptives acute_episodes mat_episodes MH_episodes gls_episodes op_newcons_attendances op_newcons_dnas ae_attendances.

Frequencies NCU.

