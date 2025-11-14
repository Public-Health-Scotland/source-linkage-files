# 01 Project Structure

## Package set up

The repo contains the code to develop the package `createslf`which is
used for the production and maintenance of the Source Linkage Files
(SLFs).

## Folders

- **man** - Documentation folder for all functions. When the package
  goes through checks, this will be populated automatically and should
  not be edited by hand. To make changes to function documentation, you
  should do this in the roxygen documentation found above every
  function.  
- **Pre_processing_scripts** - This folder contains scripts which should
  be ran prior to processing.
- **R** - The main folder of functions which make up the `createslf`
  package.
- **RMarkdown** - RMarkdown files mainly used for processing costs.
- **Run_SLF_Files_manually** - This folder contains the top level
  scripts for running the whole process.
- **Run_SLF_Files_targets** - This folder contains the top level scripts
  for running the targets pipeline.
- **tests** - This folder contains tests for each function which ensures
  the package is working efficiently.
- **vignettes** - This folder contains vignettes used to populate
  Articles on the `createslf` website.

## Functions

**Boxi Extracts** - Extracts downloaded from BOXI include Acute(SMR01),
Accident & Emergency(AE2), Maternity(SMR02), Mental Health(SMR04),
Outpatients(SMR00), NRS Deaths, Homelessness(HL1) and GP Out of
Hours(OOH). The following functions are used to process these extracts
prior to linkage.

- **read_extract_XXX** - Function for reading in each extract prior to
  processing.

- **process_extract_XXX** - Function for processing each extract into a
  format for linkage.

- **process_tests_XXX** - Function for processing tests for each
  extract. This produces high level counts for comparison to the files
  produced last quarter. We check this to ensure we are happy with our
  outputs.

**Social Care Extracts** - Extracts taken from the Social Care Platform
include: Alarms Telecare(AT), Care Homes(CH), Home Care(HC) and
Self-directed Support(SDS). We also extract Client information and
Demographic information from the platform. We extract all years from the
platform during the processing stage and then filter this to financial
year for inclusion.

- **read_sc_all_XXX** - Function for reading social care **ALL** data
  from the social care platform.

- **process_sc_all_XXX** - Function for processing **ALL** social care
  data.

- **process_extract_XXX** - Function for taking the processed **ALL**
  social care data and processing each extract into financial year.

- **process_tests_XXX** - Function for processing tests for each
  extract. This produces high level counts for comparison to the files
  produced last quarter. We check this to ensure we are happy with our
  outputs.

**Episode File**

- **create_episode_file** - This is the top level script that will
  create the episode file, linking to many functions within the project.

- **process_tests_episode_file** - Function for processing tests for
  each extract. This produces high level counts for comparison to the
  files produced last quarter. We check this to ensure we are happy with
  our outputs.

**Individual File**

- **create_individual_file** - This is the top level script that will
  create the individual file, linking to many functions within the
  project.

- **process_tests_individual_file** - Function for processing tests for
  each extract. This produces high level counts for comparison to the
  files produced last quarter. We check this to ensure we are happy with
  our outputs.
