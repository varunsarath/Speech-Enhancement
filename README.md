# Speech-Enhancement

In this Git Repo, we include the matlab files for all the four methods, and the associated functions which are called to execute them. We also include the individual matlab files for each method which can be run separately-
The files to run the methods are-
1. Method 1(Energy Thresholding)- Method 1.1- Energy Thresholding.m
2. Method 1(Zero Crossing Thresholding)- Method 1.2-Zero Crossing Thresholding.m
3. Method 2- Method 2-WelchConstantNpsd.m
4. Method 3- Method 3-AdaptiveWiener.m

The rest of the files are supporting function files which the main methods call. They are explained here-
1. zero_crossings.m- counts the zero crossings in a given signal
2. findthreshold.m- computes the noise energy threshold
3. clean_speech.m- actual code which performs Method 1.1,called in Method 1.1- Energy Thresholding.m
4. v_snrseg,v_maxfilt,v_activlev- functions from the VOICEBOX toolbox which we use to compute segmental SNR. Cited in report.
5. stoi.m- function to compute STOI, cited in report.

Alternatively, we include a single Jupyter notebook lined with a MATLAB kernel where all the methods can be seen and run. This file is named 'All Methods Combined.ipynb'

Link to the recording of the presentation-
https://drive.google.com/file/d/164GVmfMkrh6gjlmRDjyWM_ONxoOlQ0gy/view?usp=share_link
