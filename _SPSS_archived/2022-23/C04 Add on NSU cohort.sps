﻿* Encoding: UTF-8.

**********************************************************************************************************************************.
* Dummy file for latest year without an NSU cohort.
**********************************************************************************************************************************.
* Get previous file saved at end of homelessness.
Host command = ["mv -Tv " + !Year_dir + "temp-source-episode-file-3-" + !FY + ".zsav " + !Year_dir + "temp-source-episode-file-4-" + !FY + ".zsav"].

 * Get file = !Year_dir + "temp-source-episode-file-3-" + !FY + ".zsav" .

* save file as next temp ep file.
 * Save outfile = !Year_dir + "temp-source-episode-file-4-" + !FY + ".zsav"
    /zcompressed.

* Delete previous file.
 * Erase file = !Year_dir + "temp-source-episode-file-3-" + !FY + ".zsav".



