function [dataV,DatMean,DatSTD,DatMedian] = NormPhase(time,t0,tend,data,varargin)
%NormPhase Interpolates data to n frames between t0 and tend. Note
%that t0 and tend can be vectors. In this case the software always searches
%for the next instance of event tend for each t0 event.
%   Input arguments:
%       (1) time: time vector (in s)
%       (2) t0: vector with timing (in s) of start events
%       (3) tend: vector with timing (in s) of end events
%       (4) data: matrix with input data (size: nSamples x nsignals) 
%       (5) varargin:
%           (5.1) maximal duration between t0 and tend events (default if Inf)
%           (5.2) BoolNormx0: Boolean to normalise data to value at start
%                 each start event (0) (default is false)
%           (4.3) Select number of datapoints for interpolation (default is
%                 100 datapoints)
%   Output arguments:
%       (1) dataV: interpolated data
%       (2) DatMean: average between cycles of interpolated data
%       (3) DatSTD: standard deviation between cycles of interpolated data
%       (4) DatMedian: median between cycles of interpolated data

% size of the input data
[~,nc] = size(data);


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

% nPointsInt
nPointsInt = 100;
if length(varargin)>2
    nPointsInt = varargin{3};
end

% pre allocate output
nstep = length(t0);
if nc == 1
    dataV = nan(100,nstep);
else
    dataV = nan(100,nc,nstep);
end

% convert table to array if needed
if istable(data)
    data = table2array(data);
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
                    dsel = data(iSel);
                    if BoolNormx0
                        dsel = dsel - dsel(1);
                    end
                    dataV(:,i) = interp1(1:nfr,dsel,linspace(1,nfr,nPointsInt));
                else
                    dsel = data(iSel,:);
                    if BoolNormx0
                        dsel = dsel - dsel(1,:);
                    end
                    dataV(:,:,i) = interp1((1:nfr)',dsel,linspace(1,nfr,nPointsInt)');
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
    DatMean = nanmean(dataV,2);
    DatSTD  = nanstd(dataV,[],2);
    DatMedian = nanmedian(dataV,2);
else
    DatMean = nanmean(dataV,3);
    DatSTD  = nanstd(dataV,[],3);
    DatMedian = nanmedian(dataV,3);
end


end

