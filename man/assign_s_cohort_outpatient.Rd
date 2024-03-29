% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/create_service_use_lookup.R
\name{assign_s_cohort_outpatient}
\alias{assign_s_cohort_outpatient}
\title{Assign outpatient cohort flag}
\usage{
assign_s_cohort_outpatient(outpatient_cost)
}
\arguments{
\item{outpatient_cost}{A vector of outpatient costs}
}
\value{
A boolean vector of outpatient cohort flags
}
\description{
If the record has a outpatient cost greater than zero,
assign \code{TRUE}.
}
\seealso{
Other Demographic and Service Use Cohort functions: 
\code{\link{add_operation_flag}()},
\code{\link{assign_cohort_names}()},
\code{\link{assign_d_cohort_mh}()},
\code{\link{assign_death_flag}()},
\code{\link{assign_elective_daycase_instances}()},
\code{\link{assign_elective_inpatient_flag}()},
\code{\link{assign_elective_inpatient_instances}()},
\code{\link{assign_elective_instances}()},
\code{\link{assign_emergency_instances}()},
\code{\link{assign_s_cohort_ae2}()},
\code{\link{assign_s_cohort_community_care}()},
\code{\link{assign_s_cohort_elective_inpatient}()},
\code{\link{assign_s_cohort_geriatric}()},
\code{\link{assign_s_cohort_limited_daycases}()},
\code{\link{assign_s_cohort_maternity}()},
\code{\link{assign_s_cohort_multiple_emergency}()},
\code{\link{assign_s_cohort_prescribing}()},
\code{\link{assign_s_cohort_psychiatry}()},
\code{\link{assign_s_cohort_residential_care}()},
\code{\link{assign_s_cohort_routine_daycase}()},
\code{\link{assign_s_cohort_single_emergency}()},
\code{\link{calculate_acute_elective_cost}()},
\code{\link{calculate_acute_emergency_cost}()},
\code{\link{calculate_ae2_cost}()},
\code{\link{calculate_care_home_cost}()},
\code{\link{calculate_community_care_cost}()},
\code{\link{calculate_community_health_cost}()},
\code{\link{calculate_elective_inpatient_cost}()},
\code{\link{calculate_geriatric_cost}()},
\code{\link{calculate_home_care_cost}()},
\code{\link{calculate_hospital_elective_cost}()},
\code{\link{calculate_hospital_emergency_cost}()},
\code{\link{calculate_limited_daycases_cost}()},
\code{\link{calculate_maternity_cost}()},
\code{\link{calculate_multiple_emergency_cost}()},
\code{\link{calculate_outpatient_costs}()},
\code{\link{calculate_prescribing_cost}()},
\code{\link{calculate_psychiatry_cost}()},
\code{\link{calculate_residential_care_cost}()},
\code{\link{calculate_routine_daycase_cost}()},
\code{\link{calculate_single_emergency_cost}()},
\code{\link{create_demographic_cohorts}()},
\code{\link{create_service_use_cohorts}()},
\code{\link{recalculate_elective_inpatient_cost}()}
}
\concept{Demographic and Service Use Cohort functions}
