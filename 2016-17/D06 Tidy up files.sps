* Encoding: UTF-8.

******************************************************************************************************
                                                               Tidy up files
******************************************************************************************************
* Adding a new place for deleting temp source episode files. 
*This is incase of any errors - if there is an error it means only the C files need run again to create 
the source episode file instead of running the A and B files aswell.  

* Delete Source Episode temp files. 
* May get some errors if files have already been deleted to save space.
erase file = !File + "temp-source-episode-file-1-" + !FY + ".zsav".
erase file = !File + "temp-source-episode-file-2-" + !FY + ".zsav".
erase file = !File + "temp-source-episode-file-3-" + !FY + ".zsav".
erase file = !File + "temp-source-episode-file-4-" + !FY + ".zsav".
erase file = !File + "temp-source-episode-file-5-" + !FY + ".zsav".
erase file = !File + "temp-source-episode-file-6-" + !FY + ".zsav".
erase file = !File + "temp-source-episode-file-7-" + !FY + ".zsav".
erase file = !File + "temp-source-episode-file-8-" + !FY + ".zsav".

*Delete Source Individual temp files. 
erase file = !file + "temp-source-individual-file-1-20" + !FY + ".zsav".
erase file = !file + "temp-source-individual-file-2-20" + !FY + ".zsav".
erase file = !file + "temp-source-individual-file-3-20" + !FY + ".zsav".
erase file = !file + "temp-source-individual-file-4-20" + !FY + ".zsav".
erase file = !file + "temp-source-individual-file-5-20" + !FY + ".zsav".

********************************************************************************************************
                                                     General Housekeeping
********************************************************************************************************



