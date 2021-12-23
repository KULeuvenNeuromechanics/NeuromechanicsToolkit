function [] = PlotContour(x,meandat,stddat,varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

nStd = 2;
Col = [0.5 0.5 0.5];
if ~isempty(varargin)
    Col = varargin{1};
    if length(varargin)>1
        nStd = varargin{2};
    end
end

meanPlusSTD = meandat + nStd*stddat;
meanMinusSTD = meandat - nStd*stddat;
fill([x; flipud(x)],[meanPlusSTD; flipud(meanMinusSTD)],Col);
alpha(.25);


end