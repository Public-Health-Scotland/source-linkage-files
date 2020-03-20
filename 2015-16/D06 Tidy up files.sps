* Encoding: UTF-8.

******************************************************************************************************
                                                        Tidy up files 
******************************************************************************************************

*Source episode files.
* May get some errors if files have already been deleted to save space.
erase file = !File + "temp-source-episode-file-1-" + !FY + ".zsav".
erase file = !File + "temp-source-episode-file-2-" + !FY + ".zsav".
erase file = !File + "temp-source-episode-file-3-" + !FY + ".zsav".
erase file = !File + "temp-source-episode-file-4-" + !FY + ".zsav".
erase file = !File + "temp-source-episode-file-5-" + !FY + ".zsav".
erase file = !File + "temp-source-episode-file-6-" + !FY + ".zsav".

*Source individual files. 
erase file = !file + "temp-source-individual-file-1-20" + !FY + ".zsav".
erase file = !file + "temp-source-individual-file-2-20" + !FY + ".zsav".
erase file = !file + "temp-source-individual-file-3-20" + !FY + ".zsav".
erase file = !file + "temp-source-individual-file-4-20" + !FY + ".zsav".
erase file = !file + "temp-source-individual-file-5-20" + !FY + ".zsav".

******************************************************************************************************
