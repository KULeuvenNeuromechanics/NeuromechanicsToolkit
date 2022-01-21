function [fNew,hNew] = SelectSubplot(iAx,varargin)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
if ~isempty(varargin)
    h = varargin{1};
else
    h = gcf;
end

fNew = figure;
hNew = copyobj(h.Children(iAx), fNew);
set(hNew, 'pos', [0.1300 0.1100 0.7750 0.8150])
end

