function [errors] = getMarkerError(file_trc,file_ik_markers,file_errors)
% getMarkerError calculates the error between measured marker trajectories
% and calculated marker trajectories. It calculates the error between each
% marker component as well as the euclidean distance between the markers.
%
%   INPUT:
%   (1) file_trc
%           filepath to the trc file containing the measured marker
%           trajectories
%   (2) file_ik_markers
%           filepath to the .sto file containing the calculated marker
%           trajectories through inverse kinamatics
%   (3) file_errors
%           filepath to the .mat file to which the marker errors will be
%           written
%
%   OUTPUT:
%   (1) errors
%           structure containing the errors per component as well as the
%           euclidean distance between the markers
%   (2) .mat file file containing the error between the measured and
%           calculated marker trajectories
%
%
% Original author: Bram Van Den Bosch 
% Original date: 27/01/2023
% --------------------------------------------------------------------------

% import data
trc_markers = importTRCdata(file_trc);
ik_markers = ReadMotFile(file_ik_markers);

% initiate structure
errors = struct;

%% per marker component (tx,ty,tz)
% set names of per-component errors
errors.per_component.names = ik_markers.names';

% calculate error per marker component
errors.per_component.data = trc_markers(:,2:end) - ik_markers.data(:,:);

% calculate max and RMS of per-component errors
errors.per_component.max = max(errors.per_component.data);
errors.per_component.rms = rms(errors.per_component.data);

% overwrite time column with correct times or nan for max and rms
errors.per_component.data(:,1) = trc_markers(:,2);
errors.per_component.max(1) = nan;
errors.per_component.rms(1) = nan;

%% per marker, using the euclidean distance
% set names of per-marker errors
errors.per_marker.names{1,1} = 'Time';

% ittereate over different makernames starting from the second cell (first one is Time)
for i = 1:(length(ik_markers.names)-1)/3
    temp = strsplit(ik_markers.names{i*3-1},'_');
    errors.per_marker.names{1,i+1} = temp{1};

    % calculate euclidean distance
    errors.per_marker.data(:,i) = vecnorm(errors.per_component.data(:,i*3-1:i*3+1), 2, 2);
end

% add time column
errors.per_marker.data = [trc_markers(:,2) errors.per_marker.data];

% calculate max and RMS
errors.per_marker.max = max(errors.per_marker.data);
errors.per_marker.rms = rms(errors.per_marker.data);

%% save errors
save(file_errors,"errors");

end