function [tDelay] = GetDelay(t1,dat1,t2,dat2,varargin)
%GetDelay computes the time delay between two signals using
%autocorrelations. We expect that dat1 fits more or less inside dat2
%   input arguments:
%       (1) t1: time vector first signal
%       (2) dat1: values first signal
%       (3) t2: time vector second signal
%       (4) dat2: data second signal
%
%   output arguments:
%       (1) tDelay: t1 = t2 + tDelay


bool_plot= 0;
if ~isempty(varargin)
    bool_plot = varargin{1};
end
    
% interpolate dat 1 to time vector of t2
dat1_int= interp1(t1,dat1,t2)';

% run the cross correlation
[r,lags] = xcorr(dat1_int,dat2);

% find the delay
[~,IndMax]  = max(r);
nfr_lag     = lags(IndMax);
tDelay      = t2(nfr_lag);

if bool_plot
    disp(['Delay: ' num2str(tDelay) ' s']);
    figure();
    plot(t2+tDelay,dat2); hold on;
    plot(t2,dat1_int,'r');
end



end