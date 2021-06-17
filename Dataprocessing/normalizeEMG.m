function [EMG_norm] = normalizeEMG(EMG_filt)
% --------------------------------------------------------------------------
%normalizeEMG 
%   This function normalizes EMG to the maximal value attained during all
%   trials
% 
% INPUT:
%   - EMG_filt -
%   * A cell array containing filterd and rectified EMG data. The time 
%   columns should not be included in these data.
% 
% OUTPUT:
%   - EMG_norm -
%   * A cell array containing normalized EMG data.
% 
% Original author: Bram Van Den Bosch
% Original date: 17/06/2021
%
% Last edit by: Bram Van Den Bosch
% Last edit date: 17/06/2021
% --------------------------------------------------------------------------

% determine the amount of trials
ntrials = length(EMG_filt);

for trial = 1:ntrials
    % get the max of each channel within one trial
    [EMG_max(trial,:),~] = max(EMG_filt{trial});
end

% get the max of each channel over all trials
[EMG_max_all,~] = max(EMG_max);

for trial = 1:ntrials
    % normalize the filtered data of each channel to the overall max value
    EMG_norm{trial} = EMG_filt{trial}./EMG_max_all;   
end

end

