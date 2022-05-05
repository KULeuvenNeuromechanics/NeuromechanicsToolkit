function [dataV,DatMean,DatSTD,DatMedian] = NormCycle(time,EventVector,data,varargin)
%NormCycle Interpolates data to n frames between two consecutive
%events
%   Input arguments:
%       (1) time: time vector (in s)
%       (2) EventVector: vector with timing (in s) of events
%       (3) data: matrix with input data (size: nSamples x nsignals) 
%       (4) varargin:
%           (4.1) maximal duration between events (default if Inf)
%           (4.2) Bool print warnings (default is True)
%           (4.3) Select number of datapoints for interpolation (default is
%                 100 datapoints)
%   Output arguments:
%       (1) dataV: interpolated data
%       (2) DatMean: average between cycles of interpolated data
%       (3) DatSTD: standard deviation between cycles of interpolated data
%       (4) DatMedian: median between cycles of interpolated data


% size of the input data
[~,nc] = size(data);

% treshold on duration between consecutive events
treshold_dtStride = Inf;
if ~isempty(varargin)
    treshold_dtStride= varargin{1};
end

% print warnings
BoolPrint = true;
if length(varargin)> 1
    BoolPrint = varargin{2};
end

% nPointsInt
nPointsInt = 100;
if length(varargin)>2
    nPointsInt = varargin{3};
end

% select duration stance and swing phase for each step
nstep = length(EventVector)-1;
if nc == 1
    dataV = nan(100,nstep);
else
    dataV = nan(100,nc,nstep);
end

% convert table to array if needed
if istable(data)
    data = table2array(data);
end


for i = 1:nstep
    dtStride = EventVector(i+1)-EventVector(i);
    if dtStride<treshold_dtStride
        % select indices of the selected stride
        iSel = (time>=EventVector(i) & time<=EventVector(i+1));
        nfr = sum(iSel);
        if nfr>0
            % interpolate the data to 100 datapoints
            if nc == 1
                dataV(:,i) = interp1(1:nfr,data(iSel),linspace(1,nfr,nPointsInt));
            else
                dataV(:,:,i) = interp1((1:nfr)',data(iSel,:),linspace(1,nfr,nPointsInt)');
            end
        end
    else
        if BoolPrint
            disp(['Removed a cycle from the analysis because duration of cycle was ' num2str(dtStride) ' s' ]);
        end
    end
end

if nc == 1
    DatMean = nanmean(ParamV,2);
    DatSTD  = nanstd(ParamV,[],2);
    DatMedian = nanmedian(ParamV,2);
else
    DatMean = nanmean(ParamV,3);
    DatSTD  = nanstd(ParamV,[],3);
    DatMedian = nanmedian(ParamV,3);
end


end

