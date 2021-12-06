function [ParamV,DatMean,DatSTD,DatMedian] = GetGaitCycleAverage(time,hs,param,varargin)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% size of the input data
[~,nc] = size(param);


% treshold on duration stride
treshold_dtStride = Inf;
if ~isempty(varargin)
    treshold_dtStride= varargin{1};
end

% print warnings
BoolPrint = true;
if length(varargin)> 1
    BoolPrint = varargin{2};
end

% select duration stance and swing phase for each step
nstep = length(hs)-1;
if nc == 1
    ParamV = nan(100,nstep);
else
    ParamV = nan(100,nc,nstep);
end


for i = 1:nstep
    dtStride = hs(i+1)-hs(i);
    if dtStride<treshold_dtStride
        % select indices of the selected stride
        iSel = (time>=hs(i) & time<=hs(i+1));
        nfr = sum(iSel);
        % interpolate the data to 100 datapoints
        if nc == 1
            ParamV(:,i) = interp1(1:nfr,param(iSel),linspace(1,nfr,100));
        else
            ParamV(:,:,i) = interp1(1:nfr,param(iSel,:),linspace(1,nfr,100));
        end
    else
        if BoolPrint
            disp(['Removed a gait cycle from the analysis because duration of stride was ' num2str(dtStride) ' s' ]);
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

