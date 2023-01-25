# PLATERO: A Plate Reader Calibration Protocol to work with different instrument gains and asses measurement uncertainty 

Functions and scripts used for calibration models. It includes a demo data set with the scripts to load the data, build and exploit the calibration model. The executable script is platero_protocol.m. 

Ir recreates the results used for the paper, using the Fluorescein dataset as a demo. It relies on:
- prep_data.m: loads the data from the plate reader output file (.xlsx) and re-formats it. It can be modified accordingly to the output format of each user's plate reader. It splits the data set in the calibration and validation data sets, creating a .mat file for each one.
- explore_data.m: it returns a descriptive plot of the data and studies missingness.
- fit_platero_model.m: fits all the coefficients of the calibration model, runs a bias and linearity analysis and quantifies the uncertainty that will be used to obtain confidence intervals for further predictions. 
- use_platero_model.m: using the model coefficients on the validation data set. It runs as well the bias and linearity analysis, an R&R assessment on the variability of the results and also obtains some performance metrics which can be useful to compare the calibration model to other options.
