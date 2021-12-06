function [Event,Step] = GetSpatioTemporalParam(time,Fl,Fr,treshold,dtOffPlate,varargin)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
% input arguments
%   time: time vector in s
%   Fl: vertical ground reaction force left leg
%   F2: vertical ground reaction force right leg
%   treshold: treshold in N for event detection (default 30 N?)
%   dtOffPlate: minimal duration swing phase for event detection
%   varargin:
%       (1): Time (in s) of data that is excluded at the start in the
%       analayis (this is the time relative to the first time frame in
%       vector "time").


% note we added the dtOffPlate because we don't want to detect events when
% the force fluctuates around the treshold

% check if we have to exlude some frames in the start of the trial
if ~isempty(varargin)
   t0 = varargin{1}; 
   tRel =  time - time(1);
   iSel = tRel>t0;
   time = time(iSel);
   Fl = Fl(iSel);
   Fr = Fr(iSel);    
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

% select the percentage in stance and swing (based on left leg) for the
% whole trial
nfr = length(Fl);
Step.PercStance = sum(Fl > treshold)./nfr * 100;
Step.PercSwing = sum(Fl < treshold)./nfr * 100; 
Step.PercDS = sum(Fl > treshold & Fr > treshold)./nfr * 100;

% select duration stance and swing phase for each step
nstep = length(Event.ths_l)-1;
dtStance = nan(nstep,1);
PercDS = nan(nstep,1);
dtStride = diff(Event.ths_l);
for i = 1:nstep    
    % get the duration of the stance phase
    ito = find(Event.tto_l>Event.ths_l(i),1,'first'); % get the first toe-off after heelstrike
    tto = Event.tto_l(ito);
    dtStance(i) = tto-Event.ths_l(i);    
    % get the duration of the double support fase
    iSel = hs_l(i):hs_l(i+1); % get indexes of this stride
    PercDS(i) = sum(Fl(iSel) > treshold & Fr(iSel) > treshold)./length(iSel) * 100;
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

