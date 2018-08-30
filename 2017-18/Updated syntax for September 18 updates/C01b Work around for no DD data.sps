* Encoding: UTF-8.
* Alternative to running DD syntax.
get file = !File + "temp-source-episode-file-1-" + !FY + ".zsav".

Numeric Delay_End_Reason (F1.0).
String Primary_Delay_Reason Secondary_Delay_Reason (A4).
String DD_Quality (A3).

save outfile = !File + "temp-source-episode-file-2-" + !FY + ".zsav"
    /zcompressed.

