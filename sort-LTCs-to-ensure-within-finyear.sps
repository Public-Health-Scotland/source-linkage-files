* 2015/16.
get file = '/conf/hscdiip/01-Source-linkage-files/source-episode-file-201516.sav'.

frequencies arth asthma atrialfib cancer cvd liver copd dementia diabetes epilepsy chd hefailure ms
parkinsons refailure congen bloodbfo endomet digestive.

frequencies arth_date asthma_date atrialfib_date cancer_date cvd_date liver_date copd_date
            dementia_date diabetes_date epilepsy_date chd_date hefailure_date ms_date
            parkinsons_date refailure_date congen_date bloodbfo_date endomet_date digestive_date.

* as there are dates that are beyond the end of the time period in this episode file, the values for the
* LTC markers must be made 0 and the dates removed.  

if (arth_date gt '20160331') arth eq 0.
if (asthma_date gt '20160331') asthma eq 0.
if (atrialfib_date gt '20160331') atrialfib eq 0.
if (cancer_date gt '20160331') cancer eq 0.
if (cvd_date gt '20160331') cvd eq 0.
if (liver_date gt '20160331') liver eq 0.
if (copd_date gt '20160331') copd eq 0.
if (dementia_date gt '20160331') dementia eq 0.
if (diabetes_date gt '20160331') diabetes eq 0.
if (epilepsy_date gt '20160331') epilepsy eq 0.
if (chd_date gt '20160331') chd eq 0.
if (hefailure_date gt '20160331') hefailure eq 0.
if (ms_date gt '20160331') ms eq 0.
if (parkinsons_date gt '20160331') parkinsons eq 0.
if (refailure_date gt '20160331') refailure eq 0.
if (congen_date gt '20160331') congen eq 0.
if (bloodbfo_date gt '20160331') bloodbfo eq 0.
if (endomet_date gt '20160331') endomet eq 0.
if (digestive_date gt '20160331') digestive eq 0.
execute.

if (arth_date gt '20160331') arth_date eq ''.
if (asthma_date gt '20160331') asthma_date eq ''.
if (atrialfib_date gt '20160331') atrialfib_date eq ''.
if (cancer_date gt '20160331') cancer_date eq ''.
if (cvd_date gt '20160331') cvd_date eq ''.
if (liver_date gt '20160331') liver_date eq ''.
if (copd_date gt '20160331') copd_date eq ''.
if (dementia_date gt '20160331') dementia_date eq ''.
if (diabetes_date gt '20160331') diabetes_date eq ''.
if (epilepsy_date gt '20160331') epilepsy_date eq ''.
if (chd_date gt '20160331') chd_date eq ''.
if (hefailure_date gt '20160331') hefailure_date eq ''.
if (ms_date gt '20160331') ms_date eq ''.
if (parkinsons_date gt '20160331') parkinsons_date eq ''.
if (refailure_date gt '20160331') refailure_date eq ''.
if (congen_date gt '20160331') congen_date eq ''.
if (bloodbfo_date gt '20160331') bloodbfo_date eq ''.
if (endomet_date gt '20160331') endomet_date eq ''.
if (digestive_date gt '20160331') digestive_date eq ''.
execute.

frequencies arth asthma atrialfib cancer cvd liver copd dementia diabetes epilepsy chd hefailure ms
parkinsons refailure congen bloodbfo endomet digestive.

frequencies arth_date asthma_date atrialfib_date cancer_date cvd_date liver_date copd_date
            dementia_date diabetes_date epilepsy_date chd_date hefailure_date ms_date
            parkinsons_date refailure_date congen_date bloodbfo_date endomet_date digestive_date.

save outfile = '/conf/irf/source-episode-file-201516.sav'.
get file = '/conf/irf/source-episode-file-201516.sav'.

* 2016/17.
get file = '/conf/hscdiip/01-Source-linkage-files/source-episode-file-201617.sav'.

frequencies arth asthma atrialfib cancer cvd liver copd dementia diabetes epilepsy chd hefailure ms
parkinsons refailure congen bloodbfo endomet digestive.

frequencies arth_date asthma_date atrialfib_date cancer_date cvd_date liver_date copd_date
            dementia_date diabetes_date epilepsy_date chd_date hefailure_date ms_date
            parkinsons_date refailure_date congen_date bloodbfo_date endomet_date digestive_date.

* as there are dates that are beyond the end of the time period in this episode file, the values for the
* LTC markers must be made 0 and the dates removed.  
if (arth_date gt '20170331') arth eq 0.
if (asthma_date gt '20170331') asthma eq 0.
if (atrialfib_date gt '20170331') atrialfib eq 0.
if (cancer_date gt '20170331') cancer eq 0.
if (cvd_date gt '20170331') cvd eq 0.
if (liver_date gt '20170331') liver eq 0.
if (copd_date gt '20170331') copd eq 0.
if (dementia_date gt '20170331') dementia eq 0.
if (diabetes_date gt '20170331') diabetes eq 0.
if (epilepsy_date gt '20170331') epilepsy eq 0.
if (chd_date gt '20170331') chd eq 0.
if (hefailure_date gt '20170331') hefailure eq 0.
if (ms_date gt '20170331') ms eq 0.
if (parkinsons_date gt '20170331') parkinsons eq 0.
if (refailure_date gt '20170331') refailure eq 0.
if (congen_date gt '20170331') congen eq 0.
if (bloodbfo_date gt '20170331') bloodbfo eq 0.
if (endomet_date gt '20170331') endomet eq 0.
if (digestive_date gt '20170331') digestive eq 0.
execute.

if (arth_date gt '20170331') arth_date eq ''.
if (asthma_date gt '20170331') asthma_date eq ''.
if (atrialfib_date gt '20170331') atrialfib_date eq ''.
if (cancer_date gt '20170331') cancer_date eq ''.
if (cvd_date gt '20170331') cvd_date eq ''.
if (liver_date gt '20170331') liver_date eq ''.
if (copd_date gt '20170331') copd_date eq ''.
if (dementia_date gt '20170331') dementia_date eq ''.
if (diabetes_date gt '20170331') diabetes_date eq ''.
if (epilepsy_date gt '20170331') epilepsy_date eq ''.
if (chd_date gt '20170331') chd_date eq ''.
if (hefailure_date gt '20170331') hefailure_date eq ''.
if (ms_date gt '20170331') ms_date eq ''.
if (parkinsons_date gt '20170331') parkinsons_date eq ''.
if (refailure_date gt '20170331') refailure_date eq ''.
if (congen_date gt '20170331') congen_date eq ''.
if (bloodbfo_date gt '20170331') bloodbfo_date eq ''.
if (endomet_date gt '20170331') endomet_date eq ''.
if (digestive_date gt '20170331') digestive_date eq ''.
execute.

frequencies arth asthma atrialfib cancer cvd liver copd dementia diabetes epilepsy chd hefailure ms
parkinsons refailure congen bloodbfo endomet digestive.

frequencies arth_date asthma_date atrialfib_date cancer_date cvd_date liver_date copd_date
            dementia_date diabetes_date epilepsy_date chd_date hefailure_date ms_date
            parkinsons_date refailure_date congen_date bloodbfo_date endomet_date digestive_date.

save outfile = '/conf/irf/source-episode-file-201617.sav'.
get file = '/conf/irf/source-episode-file-201617.sav'.


* 2016/17 - Individual file. 
get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-201617.sav'.

frequencies arth asthma atrialfib cancer cvd liver copd dementia diabetes epilepsy chd hefailure ms
parkinsons refailure congen bloodbfo endomet digestive.

frequencies arth_date asthma_date atrialfib_date cancer_date cvd_date liver_date copd_date
            dementia_date diabetes_date epilepsy_date chd_date hefailure_date ms_date
            parkinsons_date refailure_date congen_date bloodbfo_date endomet_date digestive_date.

* as there are dates that are beyond the end of the time period in this episode file, the values for the
* LTC markers must be made 0 and the dates removed.  
if (arth_date gt '20170331') arth eq 0.
if (asthma_date gt '20170331') asthma eq 0.
if (atrialfib_date gt '20170331') atrialfib eq 0.
if (cancer_date gt '20170331') cancer eq 0.
if (cvd_date gt '20170331') cvd eq 0.
if (liver_date gt '20170331') liver eq 0.
if (copd_date gt '20170331') copd eq 0.
if (dementia_date gt '20170331') dementia eq 0.
if (diabetes_date gt '20170331') diabetes eq 0.
if (epilepsy_date gt '20170331') epilepsy eq 0.
if (chd_date gt '20170331') chd eq 0.
if (hefailure_date gt '20170331') hefailure eq 0.
if (ms_date gt '20170331') ms eq 0.
if (parkinsons_date gt '20170331') parkinsons eq 0.
if (refailure_date gt '20170331') refailure eq 0.
if (congen_date gt '20170331') congen eq 0.
if (bloodbfo_date gt '20170331') bloodbfo eq 0.
if (endomet_date gt '20170331') endomet eq 0.
if (digestive_date gt '20170331') digestive eq 0.
execute.

if (arth_date gt '20170331') arth_date eq ''.
if (asthma_date gt '20170331') asthma_date eq ''.
if (atrialfib_date gt '20170331') atrialfib_date eq ''.
if (cancer_date gt '20170331') cancer_date eq ''.
if (cvd_date gt '20170331') cvd_date eq ''.
if (liver_date gt '20170331') liver_date eq ''.
if (copd_date gt '20170331') copd_date eq ''.
if (dementia_date gt '20170331') dementia_date eq ''.
if (diabetes_date gt '20170331') diabetes_date eq ''.
if (epilepsy_date gt '20170331') epilepsy_date eq ''.
if (chd_date gt '20170331') chd_date eq ''.
if (hefailure_date gt '20170331') hefailure_date eq ''.
if (ms_date gt '20170331') ms_date eq ''.
if (parkinsons_date gt '20170331') parkinsons_date eq ''.
if (refailure_date gt '20170331') refailure_date eq ''.
if (congen_date gt '20170331') congen_date eq ''.
if (bloodbfo_date gt '20170331') bloodbfo_date eq ''.
if (endomet_date gt '20170331') endomet_date eq ''.
if (digestive_date gt '20170331') digestive_date eq ''.
execute.

frequencies arth asthma atrialfib cancer cvd liver copd dementia diabetes epilepsy chd hefailure ms
parkinsons refailure congen bloodbfo endomet digestive.

frequencies arth_date asthma_date atrialfib_date cancer_date cvd_date liver_date copd_date
            dementia_date diabetes_date epilepsy_date chd_date hefailure_date ms_date
            parkinsons_date refailure_date congen_date bloodbfo_date endomet_date digestive_date.

save outfile = '/conf/irf/source-individual-file-201617.sav'.
get file = '/conf/irf/source-individual-file-201617.sav'.
