The data file **data_study1.mat** contains raw data of JOL (on a 0-100 continuous scale) and memory performance (0 or 1) for each trial.
The data file **data_study1_7bins.mat** contains raw data of JOL (on a 7-point discrete scale) and memory performance (0 or 1) for each trial.
- The **first column** is the subject ID.
- The **second column** is the experimental condition for each trial (1 = post-study JOL, 2 = pre-study JOL).
- The **third column** is the JOL value for each trial.
- The **fourth column** is the memory performance for each trial.

Run *group_fitBIM_fullModel_2conditions.m* to fit BIM to data with continuous confidence, and the results are saved in **BIMresults_study1.mat**.

Run *group_fitBIMBins_fullModel_2conditions.m* to fit BIM to data with discrete confidence, and the results are saved in **BIMresults_study1_7bins.mat**.

Run *group_fitSDRM_sigma0.m* to fit SDRM to data with discrete confidence, and the results are saved in **SDRMresults_study1_7bins.mat**.

Run *group_fitSDRM4c_sigma0.m* to fit SDRM Model 4c to data with discrete confidence, and the results are saved in **SDRM4cresults_study1_7bins.mat**.