function [] = PlotBar(x,y,varargin)
%PlotBar Adds a bar to the current figure and show individual datapoints
%
%	INPUT:
%		(1) x: x-coordinate for bar (double)
%		(2) y: vector with y-values for bar
%		(3) varargin: variable input arguments:
%			(3.1) Cs: RGB code for color
%			(3.2) mk: size Markers
%			(3.3) h: figure handle


% default properties
Cs = [0.6 0.6 0.6]; % default color
mk = 3; % default marker size

% Input color
if ~isempty(varargin)
    Cs = varargin{1};
end
if length(varargin)>1
    mk = varargin{2};
end

if length(varargin)>2
    h = varargin{3};
    figure(h);
end

%% Plot bar with average of individual datapoints
b = bar(x,nanmean(y)); hold on;
b.FaceColor = Cs; b.EdgeColor = Cs;

% plot individual datapoints on top
n = length(y);
xrange = 0.2;
dx = (1:n)./n.*xrange - 0.5*xrange + x;
plot(dx,y,'o','MarkerFaceColor',Cs,'Color',[0.2 0.2 0.2],'MarkerSize',mk);





end

