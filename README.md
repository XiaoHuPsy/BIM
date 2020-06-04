# BIM
This repository contains data and code supporting the following paper:

Hu, X., Zheng, J., Su, N., Fan, T., Yang, C., Yin, Y., Fleming, S. M., & Luo, L. (in prep). A Bayesian inference model for metamemory.

Script and data files are included in the repository to enable replication of data simulation and analyses.

**PLEASE NOTE: BIM uses the Particle Swarm optimization algorithm to estimate free parameters, which requires MATLAB version R2014b or later.**

The folder **BIM** contains the core functions of BIM, which can be fitted to data from recall or recognition tasks with continuous or discrete confidence ratings.
- Run *fit_bim.m* for data from recall tasks with continuous confidence ratings (on a 0-100 continuous scale).
- Run *fit_bim_bins.m* for data from recall tasks with discrete confidence ratings (on a scale with no less than 3 points).
- Run *fit_bim_recog.m* for data from recognition tasks with continuous confidence ratings (on a 0-100 continuous scale).
- Run *fit_bim_bins_recog.m* for data from recognition tasks with discrete confidence ratings (on a scale with no less than 3 points).

The folder **simulation** contains the scripts for the data simulation and analyses described in the section "Data Simulation and Parameter Recovery" of our paper.

The folder **studies** contains the raw data and scripts for data analyses in Studies 1-4.

The folder **extended** contains the scripts for simulating data from the extended BIM.
