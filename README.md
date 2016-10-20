microDetect
===========

Microsaccade detection plugin for EEGlab

This is an early build of a plugin for detecting microsaccades from EOG channels in EEG data.
It has been tested on version 11 of eeglab, and on Matlab versions 2009a and 2012b. It currently implements the method seen in Keren, Yuval-Greenberg, & Deouell (2010): Saccadic spike potentials in gamma-band EEG: Characterization, detection and suppression, Neuroimage (http://dx.doi.org/10.1016/j.neuroimage.2009.10.057). It requires the signal processing toolbox, and some functions also (optionally) use a saccadic spike potential filter (available at http://hcnl.huji.ac.il/Leon/Lab/tools/filtSRP.m)

Simply add the files to a folder in your EEGLAB plugins folder. The functions are available under the Tools menu in EEGLAB, and can also be used from the command line or scripting.

UPDATE: Published an article http://onlinelibrary.wiley.com/doi/10.1111/psyp.12593/abstract "Accounting for microsaccadic artifacts in the EEG using independent component analysis and beamforming" with some further information.

# I have found some issues running the plug-in on recent versions of EEGLAB which are due to changes made by the EEGLAB creators; I'm trying to come up with workarounds. (Oct 2016).

Matt Craddock, 2016
