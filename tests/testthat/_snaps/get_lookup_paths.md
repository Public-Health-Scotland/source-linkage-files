# gpprac reference file path returns as expected

    Code
      names(read_file(get_gpprac_ref_path()))
    Output
       [1] "HB cypher"               "Prac code"              
       [3] "Add 1"                   "Add 2"                  
       [5] "Add 3"                   "Add 4"                  
       [7] "Postcode"                "Tel No"                 
       [9] "GMS PMS Indicator"       "CHP code"               
      [11] "Start"                   "End"                    
      [13] "Date CHP status"         "Health Centre Indicator"

---

    Code
      names(read_file(get_gpprac_ref_path(ext = "sav")))
    Output
       [1] "cypher"    "praccode"  "add1"      "add2"      "add3"      "add4"     
       [7] "postcode"  "telephone" "gms"       "chp"       "start"     "end"      
      [13] "chpstart"  "hci"      

