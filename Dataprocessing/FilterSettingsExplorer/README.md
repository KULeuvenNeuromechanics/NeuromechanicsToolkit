# FilterSettingsExplorer

## Summary
GUI to get familiar with the influence of changing filter settings.

## Description
The FilterSettingsExplorer (FSE) GUI enables you to visualise sampled data, e.g. EMG data, and instantly see the effect of choosing certain filer settins. Th implemented filter types are butterworth filters: a bandpass  and lowpass filer. 

## How to use
As input in expects a `.mat` file which contains a struct with a data and colheader field. The colheaders are displayed as items in the top left corner which enables you to select the data you want to inspect. The first column is not included in this list since often times this is a 'time' column. The data field contains your raw data, with n rows your sample points and m columns being your data items. An example dataset is provided

To start, just click on 'Load data' in the top right corner, select the .`mat` file and enjoy exploring filter settings!