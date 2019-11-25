# BIM
This repository contains data and code supporting the following paper:

Hu, X., Zheng, J., Su, N., Fan, T., Yang, C., Yin, Y., Fleming, S. M., & Luo, L. (in prep). A Bayesian inference model for metamemory.

Script and data files are included in the repository to enable replication of data simulation and analyses.

**BIM uses the Particle Swarm optimization algorithm to estimate free parameters, which requires MATLAB version R2014b or later.**

The folder **BIM** contains the core functions of BIM, which can be fitted to data from any memory task (recall test or 2AFC recognition test) with prospective or retrospective confidence ratings. Run *fit_bim.m* for confidence ratings in continous scale (0-1) and *fit_bim_bins.m* for confidence in discrete rating scale.
