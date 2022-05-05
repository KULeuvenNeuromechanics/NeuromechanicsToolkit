function [] = PlotContour(x,meandat,stddat,varargin)
%PlotContour SPlot data with transparant fill based on STD
% Input arguments:
%   (1) x: values x axis
%   (2) meandat: vector data bold line
%   (3) std: vector with data for size of shaded area
%   (4) varargin:
%       (4.1): Color Code
%       (4.2): nStd: n times std input (3) for shaded area (default is 2)
%

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