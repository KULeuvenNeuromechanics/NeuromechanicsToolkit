function MarkersFilled = FillGapsMarkers(MarkersRaw,VideoFrameRate,gaplim)
% --------------------------------------------------------------------------
%   Filling marker data while taking into account a maximum gap size after
%   which marker location cannot be reliably interpolated.
% 
% INPUT:
%   MarkersRaw
%       Marker data
%
%   VideoFrameRate
%       Rate at which the marker data was sampled
%
%   gaplim
%       Maximum gap size that will still be interpolated. Gaps larger than
%       this limit will be assigned with NaN values.
%
% OUTPUT:
%   MarkersFilled
%       Interpollated marker data
%
% Original author: Wouter Muijres 
% Original date: 28-05
%   - Gapfill limit inspired on the VU toolbox
% --------------------------------------------------------------------------
% flagging markers invisible during the whole trial
InvisibleMarkers_flag = sum(isnan(MarkersRaw)) == size(MarkersRaw,1);
% Find columns in which data is missing
RowsMissingData = sum(isnan(MarkersRaw));
% If data is missing, interpolate missing data points
MarkersFilled = MarkersRaw;
if sum(RowsMissingData) ~= 0
    % Indeces columns in which data is missing
    index_column = find(RowsMissingData ~= 0);
    % Time vector
    [nrow,~] = size(MarkersRaw);
    time = (0:nrow-1)/VideoFrameRate;
    for i = 1:length(index_column)
        
        % find gaps in data
        gap_log     = isnan(MarkersRaw(:,index_column(i))); % missing markers
        d_gap       = diff(gap_log); % point at which markers are missing
        i_disappear = find(d_gap == 1)+1; % point at which markers disappear
        i_appear    = find(d_gap == -1); % point at which markers appear
        
        % braching structure to only loop over the markes that where visible in the time interval
        nvisible_markers    = sum(~gap_log);
        if ~InvisibleMarkers_flag(index_column(i)) && (nvisible_markers > 1)
            % Indeces of data points that are complete
            i_data_complete = ~gap_log;
            % Complete data points
            data_complete = MarkersRaw(i_data_complete,index_column(i));
            % Time at data points not missing
            time_complete = time(i_data_complete);
            % Interpolate
            data_interp = interp1(time_complete,data_complete,time);
            % Replace original data with interpolated data
            MarkersFilled(:,index_column(i)) = data_interp;
        else
            continue
        end
        
        % Correction for empty vectors
        if isempty(i_disappear) && ~isempty(i_appear)
            i_disappear(1:length(i_disappear)+1,1)    = [1;i_disappear];
        elseif isempty(i_appear) && ~isempty(i_disappear)
            i_appear(1:length(i_appear)+1,1)          = [i_appear;nrow];
        end
        
        % correct for data that is missing at the start or end of the trial
        if i_appear(1)<i_disappear(1) 
            i_disappear(1:length(i_disappear)+1,1)    = [1;i_disappear];
        end
        if i_appear(end)<i_disappear(end) 
            i_appear(1:length(i_appear)+1,1)          = [i_appear;nrow];
        end    

        gapsize     = (i_appear - i_disappear)+1; % gap sizes
        gap_replace = find(gapsize > gaplim); % replace gaps larger than the gaplimit threshold
        % Loop over gaps larger than the threshold
        for ii = 1:length(gap_replace)
            i_gap = gap_replace(ii);
            MarkersFilled(i_disappear(i_gap):i_appear(i_gap),index_column(i)) = nan;
        end
    end
end
end







