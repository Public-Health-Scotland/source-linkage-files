* Encoding: UTF-8.
********************************************************************************************************.
 * Run 01-Set up Macros first!.
********************************************************************************************************.
get file = !SLF_Extracts + "LTCs_patient_reference_file-20" + !FY + ".zsav".

* Highlight different CHI numbers.
add files file = *
    /first = first_chi
    /last = last_chi
    /by chi.

 * Highlight different CHI number / postcode combinations.
add files file = *
    /first = first_chi_postcode
    /last = last_chi_postcode
    /by chi postcode.

 * Create flags to identify duplicates.
Numeric duplicate_chi duplicate_chi_postcode (F1.0).

Do if first_chi = last_chi.
    Compute duplicate_chi = 0.
    Compute duplicate_chi_postcode = 0.
Else.
    Do if first_chi_postcode = last_chi_postcode.
        Compute duplicate_chi = 1.
        Compute duplicate_chi_postcode = 0.
    Else.
        Compute duplicate_chi = 1.
        Compute duplicate_chi_postcode = 1.
    End if.
End if.

If duplicate_chi = 1 or duplicate_chi_postcode = 1 Error = 1.

crosstabs Error by chi.

save outfile = !Year_dir + "LTC_tests_20" + !FY + ".sav".
