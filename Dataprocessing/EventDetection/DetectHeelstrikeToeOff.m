function [ths,tto,hs,to] = DetectHeelstrikeToeOff(time,F,treshold,AnalogRate,dtOffPlate,varargin)
%DetectHeelstrikeToeOff This functions detects a series of heelstrikes and
%toe-off events based on an a treshold on the vertical ground reaction
%force. 
%   Input arguments:
%       (1) time: time vector
%       (2) F: vertical ground reaction force (positive axis is minus
%       gravity)
%       (3) treshold: Force treshold in N for event detection
%       (4) AnalogRate: sampling frequency
%       (5) dtOffPlate: mininmal duration swing phase

if ~exist('dtOffPlate','var')
    dtOffPlate = 0.001;
end

% get the index of the events
IndexOffPlate=find(F<treshold);        % indexes with foot off the FP
IndexEndSwing = find(diff(IndexOffPlate)>dtOffPlate*AnalogRate);    % minimal duration swing phase
hs=IndexOffPlate(IndexEndSwing); % minimal duration swing phase
to=IndexOffPlate(IndexEndSwing+1); % start swing is when foot leaves the FP for the next time

% get the timing of the events
ths = time(hs);
tto = time(to);
end

