The data file **data_study3_7bins.mat** contains raw data of JOL (on a 7-point discrete scale) and memory performance (0 or 1) for each trial.

The file **BIMresults_study3_7bins.mat** contains the information about padding correction required in the cross-validation analysis for BIM.

Run *group_cvBIMBins_fullModel.m* to perform cross-validation analysis for BIM. The results are stored in **cvResults_BIM_study3_7bins.mat**.

Run *group_cvSDRM_sigma0.m* to perform cross-validation analysis for SDRM. The results are stored in **cvResults_SDRM_sigma0_study3_7bins.mat**.

Run *group_cvSDRM4c_sigma0.m* to perform cross-validation analysis for SDRM Model 4c. The results are stored in **cvResults_SDRM4c_sigma0_study3_7bins.mat**.