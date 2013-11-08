microDetect
===========

Microsaccade detection plugin for EEGlab

This is an early build of a plugin for detecting microsaccades from EOG channels in EEG data.
It has been tested on version 11 of eeglab, and on Matlab versions 2009a and 2012b. It currently implements the method seen in Keren, Yuval-Greenberg, & Deouell (2010): Saccadic spike potentials in gamma-band EEG: Characterization, detection and suppression, Neuroimage (http://dx.doi.org/10.1016/j.neuroimage.2009.10.057). It requires either the signal processing toolbox or a saccadic spike potential filter (http://hcnl.huji.ac.il/Leon/Lab/tools/filtSRP.m)

Simply add the files to a folder in your EEGLAB plugins folder. The functions are available under the Tools menu in EEGLAB, and can also be used from the command line and using scripting.

Matt Craddock, 2013
