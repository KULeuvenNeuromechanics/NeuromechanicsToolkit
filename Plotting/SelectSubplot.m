function [fNew,hNew] = SelectSubplot(iAx,varargin)
%SelectSubplot Selects current subplot in figure with mutiple panes
%   Input arguments:
%       (1) iAx: handle for current axis
%       (2) varargin:
%           (2.1) handle current figure
if ~isempty(varargin)
    h = varargin{1};
else
    h = gcf;
end

fNew = figure;
hNew = copyobj(h.Children(iAx), fNew);
set(hNew, 'pos', [0.1300 0.1100 0.7750 0.8150])
end

