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
   
   Descriptives dob

   Descriptives health_net_cost health_net_costincDNAs.
   
   Frequencies lca hbres chp.
   
   Frequencies deceased_flag.

   Descriptives acute_episodes mat_episodes mentalh_episodes gls_episodes op_newcons_attendances op_newcons_dnas ae_attendances.
   
!EndDefine.

!Existing FY = 1617.
!Tests.

!New FY = 1617.
!Tests.

