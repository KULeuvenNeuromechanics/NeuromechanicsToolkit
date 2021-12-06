function [ths,tto,hs,to] = DetectHeelstrikeToeOff(time,F,treshold,AnalogRate,dtOffPlate,varargin)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

% get the index of the events
IndexOffPlate=find(F<treshold);        % indexes with foot off the FP
IndexEndSwing = find(diff(IndexOffPlate)>dtOffPlate*AnalogRate);    % minimal duration swing phase
hs=IndexOffPlate(IndexEndSwing); % minimal duration swing phase
to=IndexOffPlate(IndexEndSwing+1); % start swing is when foot leaves the FP for the next time

% get the timing of the events
ths = time(hs);
tto = time(to);
end

