* Encoding: UTF-8.

**********************************************************************************************************************************.
Dummy file for 2014/15 which doesn't have an NSU cohort.
**********************************************************************************************************************************.
*Get previous file saved at end of homelessness. 
Get file = !Year_dir + "temp-source-episode-file-3-" + !FY + ".zsav" .

*save file as next temp ep file. 
Save outfile = !Year_dir + "temp-source-episode-file-4-" + !FY + ".zsav" 
/zcompressed.  

*Delete previous file. 
Erase file = !Year_dir + "temp-source-episode-file-3-" + !FY + ".zsav".
