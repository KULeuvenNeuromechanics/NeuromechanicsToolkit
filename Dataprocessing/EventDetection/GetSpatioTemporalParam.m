function [Event,Step] = GetSpatioTemporalParam(time,Fl,Fr,treshold,dtOffPlate,varargin)
%GetSpatioTemporalParam Computes spatio-temporal parameters from left and
%right ground reaction forces
% input arguments:
%   (1) time: time vector in s
%   (2) Fl: vertical ground reaction force left leg
%   (3) Fr: vertical ground reaction force right leg
%   (4) treshold: treshold in N for event detection (default 30 N?)
%   (5) dtOffPlate: minimal duration swing phase for event detection
%   varargin:
%       (5.1): Time (in s) of data that is excluded at the start in the
%       analayis (this is the time relative to the first time frame in
%       vector "time").
%       (5.2): Select side for computation Step information ('R' for right and
%       'L' for left side). Default is based on left ground reaction forces
%   Output arguments:
%   (1) Event: structure with gait cycle events
%           Event.ths_l : left heelstrike
%           Event.tto_l : left toe-off
%           Event.ths_l : right heelstrike
%           Event.tto_r : right toe-off
%   (2) Step: structure with temporal information 
%           Step.StrideTime = duration stride 
%           Step.StrideFreq = stride frequency


% note we added the dtOffPlate because we don't want to detect events when
% the force fluctuates around the treshold

% check if we have to exlude some frames in the start of the trial
if ~isempty(varargin) && ~isempty(varargin{1})
   t0 = varargin{1}; 
   tRel =  time - time(1);
   iSel = tRel>t0;
   time = time(iSel);
   Fl = Fl(iSel);
   Fr = Fr(iSel);    
end

Side = 'L';
if length(varargin)>1
    Side = varargin{2};
end

% get sampling frequency
AnalogRate = mean(1./diff(time));

% detect heelstrikes left leg
[Event.ths_l,Event.tto_l,hs_l,to_l] = DetectHeelstrikeToeOff(time,Fl,treshold,AnalogRate,dtOffPlate);
[Event.ths_r,Event.tto_r,hs_r,to_r] = DetectHeelstrikeToeOff(time,Fr,treshold,AnalogRate,dtOffPlate);

% detect stride time and frequency (based on left leg)
Step.StrideTime = diff(Event.ths_l);
Step.StrideTime_mean = nanmean(Step.StrideTime);
Step.StrideTime_std = nanstd(Step.StrideTime);
Step.StrideFreq = 1./Step.StrideTime;
Step.StrideFreq_mean = nanmean(Step.StrideFreq);
Step.StrideFreq_std = nanstd(Step.StrideFreq);

% select the percentage in stance and swing (based on left or right leg) for the
% whole trial
if strcmp(Side,'L')
    Fs = Fl;
    hs_sel = Event.ths_l;
    to_sel = Event.tto_l;
    hsi = hs_l;
elseif strcmp(Side,'R')
    Fs = Fr;
    hs_sel = Event.ths_r;
    to_sel = Event.tto_r;
    hsi = hs_r;
else
    disp(['Computation Step information based on left side because input ' Side ' is unknown']);
    Fs = Fl;
    hs_sel = Event.ths_l;
    to_sel = Event.tto_l;
    hsi = hs_l;
end

nfr = length(Fs);
Step.PercStance = sum(Fs > treshold)./nfr * 100;
Step.PercSwing = sum(Fs < treshold)./nfr * 100; 
Step.PercDS = sum(Fs > treshold & Fr > treshold)./nfr * 100;

% select duration stance and swing phase for each step
nstep = length(hs_sel)-1;
dtStance = nan(nstep,1);
PercDS = nan(nstep,1);
dtStride = diff(hs_sel);
for i = 1:nstep    
    % get the duration of the stance phase
    ito = find(to_sel>hs_sel(i),1,'first'); % get the first toe-off after heelstrike
    tto = to_sel(ito);
    dtStance(i) = tto-hs_sel(i);    
    % get the duration of the double support fase
    iSel = hsi(i):hsi(i+1); % get indexes of this stride
    PercDS(i) = sum(Fs(iSel) > treshold & Fr(iSel) > treshold)./length(iSel) * 100;
end
if any(size(dtStance) ~= size(dtStride))
    dtStride = dtStride';
end
PercStance = (dtStance./dtStride)*100;
PercSwing  = 100 - PercStance;
Step.PercStance_n = PercStance;
Step.PercSwing_n = PercSwing;
Step.PercDS_n = PercDS;
Step.dtStance_n = dtStance;
Step.dtStride_n = dtStride;







end

