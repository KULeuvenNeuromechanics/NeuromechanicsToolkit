function [ParamV,DatMean,DatSTD,DatMedian] = GetPhaseAverage(time,t0,tend,param,varargin)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% size of the input data
[~,nc] = size(param);


% treshold on duration stride
treshold_dtStride = Inf;
if ~isempty(varargin)
    treshold_dtStride= varargin{1};
end

% Deviation from initial value
BoolNormx0 = false;
if length(varargin)>1
    BoolNormx0 = varargin{2};
end

% pre allocate output
nstep = length(t0);
if nc == 1
    ParamV = nan(100,nstep);
else
    ParamV = nan(100,nc,nstep);
end

% convert table to array if needed
if istable(param)
    param = table2array(param);
end

% loop over all steps
for i = 1:nstep
    % find timing end phase
    tendSel= tend(tend>t0(i));
    if ~isempty(tendSel)
        tendSel = tendSel(1);
        dtStride = tendSel-t0(i);
        if dtStride<treshold_dtStride
            % select indices of the selected stride
            iSel = (time>=t0(i) & time<=tendSel);
            nfr = sum(iSel);
            if nfr>0
                % interpolate the data to 100 datapoints
                if nc == 1
                    dsel = param(iSel);
                    if BoolNormx0
                        dsel = dsel - dsel(1);
                    end
                    ParamV(:,i) = interp1(1:nfr,dsel,linspace(1,nfr,100));
                else
                    dsel = param(iSel,:);
                    if BoolNormx0
                        dsel = dsel - dsel(1,:);
                    end
                    ParamV(:,:,i) = interp1((1:nfr)',dsel,linspace(1,nfr,100)');
                end
            end
        else
            if BoolPrint
                disp(['Removed a gait cycle from the analysis because duration of stride was ' num2str(dtStride) ' s' ]);
            end
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

