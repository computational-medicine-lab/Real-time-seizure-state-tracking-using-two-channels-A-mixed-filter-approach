Steps for seizure prediction
The seizure dataset is publicly available here: https://physionet.org/content/chbmit/1.0.0/
To use this code, you need EEGLAB which can be downloaded here: https://github.com/sccn/eeglab
Install the biosig extension using EEGLAB before the following steps.

The code will automatically create all the necessary folders; however, you need to create the folder for the original data for the rest of the code to work.
1.) Unzip and copy the dataset to a folder called DownloadedData, then set the working directory to the folder where DownloadedData is stored (do not set the working directory to the DownloadedData itself, just set it to the directory that folder is in). It does not matter where you create the folder, the code will adjust for the location.
2.) Extractor/main.m – This file will convert the .edf files into .mat files and organize the data into individual seizures (if multiple seizures are in a single recording). 
3.) Feature Finder/ main.m - This is used to locate features for mixed filter

Next the data are separated into a training, validation, and test set. 
Per subject, we utilized one seizure for training, one for validation, and the remaining sessions with seizure activity for testing. The code will do this automatically.

4.) Training/main.m        - This code trains the mixed filter
5.) Validation/main.m      - This code validates the mixed filter
6.) Testing/main.m         - This code tests the mix filter 

The result from the testing code is the predicted seizure state and you can find the accuracy, sensitivity, and specificity using:

7.) Testing/Performance_Evaluater.m - This code will return the performance of the mixed filter for the given testing data.
