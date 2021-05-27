* Encoding: UTF-8.

******************************************************************************************************
                                                               Tidy up files
******************************************************************************************************
* Adding a new place for deleting temp source episode files. 
*This is incase of any errors - if there is an error it means only the C files need run again to create 
the source episode file instead of running the A and B files aswell.  

*Delete Source Individual temp files. 
erase file = !Year_dir + "temp-source-individual-file-1-20" + !FY + ".zsav".
erase file = !Year_dir + "temp-source-individual-file-2-20" + !FY + ".zsav".
erase file = !Year_dir + "temp-source-individual-file-3-20" + !FY + ".zsav".
erase file = !Year_dir + "temp-source-individual-file-4-20" + !FY + ".zsav".
erase file = !Year_dir + "temp-source-individual-file-5-20" + !FY + ".zsav".

********************************************************************************************************




