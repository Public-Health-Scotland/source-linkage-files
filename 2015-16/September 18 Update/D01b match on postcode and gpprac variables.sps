* Encoding: UTF-8.
get file = !File + "temp-source-individual-file-2-20" + !FY + ".zsav".

* Match on postcode stuff.
Sort Cases by postcode.

*Apply consistent geographies.
match files file = *
    /table = !Lookup + "Source Postcode Lookup-20" + !FY + ".zsav"
    /Rename (HB2014 = hbrescode)
    /In = PostcodeMatch
    /by postcode.

Frequencies hbrescode.
*****************************************************************************************.
********* Match in GP practice and cluster info. **********************************.
sort cases by gpprac.

match files file = *
    /table = !Lookup + "Source GPprac Lookup-20" + !FY + ".zsav"
    /In = GPPracMatch
    /Drop PC7 PC8
    /by gpprac.

 * Set some known dummy practice codes to consistent Board codes.
Do if any(gpprac, 99942, 99957, 99961, 99976, 99981, 99999).
    Compute hbpraccode = "S08200003". /*Outwith Scotland / unknown*/.
Else if gpprac = 99995.
    Compute hbpraccode = "S08200001".  /*RUK*/.
End if.

Frequencies hbpraccode.

 * If the practice code didn't match the lookups and still doesn't have a board code, remove it as it's probably a bad code.
if GPPracMatch = 0 and hbpraccode = "" gpprac = $sysmis.

 * Recode according to boundary changes 08/05/2018.
Recode hbrescode hbpraccode ("S08000018" = "S08000029") ("S08000027" = "S08000030").
Recode HSCP2016 ("S37000014" = "S37000032") ("S37000023" = "S37000033").
Recode CA2011 ("S12000015" = "S12000047") ("S12000024" = "S12000048").

sort cases by chi.

save outfile = !File + "temp-source-individual-file-3-20" + !FY + ".zsav"
   /zcompressed.

get file = !File + "temp-source-individual-file-3-20" + !FY + ".zsav".
