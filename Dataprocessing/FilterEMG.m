function [lowEMG] = FilterEMG(rawEMG,sf,varargin)
%FilterEMG Default filter for the EMG data
%   Input arguments:
%       (1) rawEMG: matrix with raw EMG
%       (2) sf: sampling frequency (scalar)
%       (3) varargin:
%           3.1: Filter: Structure with fields for filter settings
%                   Filter.Band.order = 2
%                   Filter.Band.cutoff = [20 400]
%                   Filter.Low.order = 2
%                   Filter.Low.cutoff = 15

% default settings filter
if isempty(varargin)
    Filter.Band.order = 2;
    Filter.Band.cutoff = [20 400];
    Filter.Low.order = 2;
    Filter.Low.cutoff = 15;
else
    Filter = varargin{1};
end

% Remove the 50Hz noise with Notch filter
fo = 50;  q = 35; bw = (fo/(sf/2))/q;
[b,a] = iircomb(round(sf/fo),bw,'notch');          % New type of notch filter (accounts for harmonics as well
rawEMG_notch = filter(b,a,rawEMG);

% Bandpass filter
order = Filter.Band.order;
cutoff = Filter.Band.cutoff;
[b, a] = butter(order/2, cutoff/(0.5*sf));
bandEMG = filtfilt(b, a, rawEMG_notch);

% absolute value
rectEMG = abs(bandEMG);

% Lowpass filter 
order = Filter.Low.order;
cutoff = Filter.Low.cutoff;
[b, a] = butter(order, cutoff/(0.5*sf));
lowEMG = filtfilt(b, a, rectEMG);


end