CD "/conf/hscdiip/01-Source-linkage-files".
show directory.


* None of this has been ran yet... JM 25/06/2018

 *****************************************************.
 * Code for changing 'old style' individual files
 * Years 17/18, 14/15, 13/14, 12/13 and 11/12.
Begin Program.
import spss

def getCode(year):
   code = []
   code.append("get file = 'source-individual-file-20" + year + ".sav'.")
   code.append("Compute op_cost_dnas = op_cost_dnas - op_cost_attend.")
   code.append("save outfile = '/conf/sourcedev/source-individual-file-20" + year + ".zsav' /zcompressed.")
   
   return code

for year in (str(x) + str(x + 1) for x in (11, 12, 13, 14, 17)):
   code = getCode(year)
   print(code)
   spss.Submit(code)
End Program.

 *****************************************************.

 *****************************************************.
 * Code for changing 'new style' individual files
 * Done for Years 15/16 and 16/17.
Define !NewYear()
   "1617"
!EndDefine.

get file = "source-individual-file-20" + !NewYear + ".sav".

Compute health_net_costincDNAs = health_net_costincDNAs + op_cost_attend.

save outfile = "/conf/sourcedev/source-individual-file-20" + !NewYear + ".zsav"
   /zcompressed.

 *****************************************************.
