Define !EpisodeFileToHscdiip (FY = !Tokens(1)
                                    /TempLocation = !Default("/conf/sourcedev/") !Tokens(1))

 * Set location - should always be hscdiip.
!LET !SourceLocation = "/conf/hscdiip/01-Source-linkage-files/".

 * Make the old file writable so we can move and overwrite it.
Host Command = [!Quote(!Concat("chmod 640 ", !SourceLocation, "source-episode-file-20", !FY, ".sav"))].

 * Zip up the old file, just in case, we can delete it after.
Host Command = [!Quote(!Concat("zip -m -1 ", !SourceLocation, "Temp.zip", " ", !SourceLocation, "source-episode-file-20", !FY, ".sav"))].

get file = !Quote(!Concat(!TempLocation, "source-episode-file-20", !FY, ".zsav")).
save outfile !Quote(!Concat(!SourceLocation, "source-episode-file-20", !FY, ".sav"))
   /map.

 * Make the new file read-only so we no-one can overwrite it.
Host Command = [!Quote(!Concat("chmod 440 ", !SourceLocation, "source-episode-file-20", !FY, ".sav"))].
!EndDefine.

Define !IndividualFileToHscdiip (FY = !Tokens(1)
                                    /TempLocation = !Default("/conf/sourcedev/") !Tokens(1))

 * Set location - should always be hscdiip.
!LET !SourceLocation = "/conf/hscdiip/01-Source-linkage-files/".

 * Make the old file writable so we can move and overwrite it.
Host Command = [!Quote(!Concat("chmod 640 ", !SourceLocation, "source-individual-file-20", !FY, ".sav"))].

 * Zip up the old file, just in case, we can delete it after.
Host Command = [!Quote(!Concat("zip -m -1 ", !SourceLocation, "Temp.zip", " ", !SourceLocation, "source-individual-file-20", !FY, ".sav"))].

get file = !Quote(!Concat(!TempLocation, "source-individual-file-20", !FY, ".zsav")).
save outfile !Quote(!Concat(!SourceLocation, "source-individual-file-20", !FY, ".sav"))
   /map.

 * Make the new file read-only so we no-one can overwrite it.
Host Command = [!Quote(!Concat("chmod 440 ", !SourceLocation, "source-individual-file-20", !FY, ".sav"))].
!EndDefine.


 * Run each one seperately incase there are any space issues.
!EpisodeFileToHscdiip FY = 1516.
!IndividualFileToHscdiip FY = 1516.

!EpisodeFileToHscdiip FY = 1617.
!IndividualFileToHscdiip FY = 1617.
 * Check the files look good and if so delete the old ones in /conf/hscdiip/01-Source-linkage-files/Temp.zip.
 * Delete new files from sourcedev.



**************************
* Used after fixing costs vars.
!IndividualFileToHscdiip FY = 1516.
!IndividualFileToHscdiip FY = 1617.

Begin Program.
import spss, os
for year in (str(x) + str(x + 1) for x in (11, 12, 13, 14, 17)):
   syntax = "!IndividualFileToHscdiip FY = " + year + "."
   print(syntax)
   spss.Submit(syntax)
   os.remove("/conf/hscdiip/01-Source-linkage-files/Temp.zip")

End Program.

