function [MLabels,Markers,vTime,vFrms,missing_markers] = Process_Markers4OSim(MLabels,Markers,VideoFrameRate,RotationMatrix)
% --------------------------------------------------------------------------
%   Processing marker data conform the opensim pipeline. Dummy makers are
%   removed, rotated, and scaled.
% 
% INPUT:
%   MLabels
%       Labels of the markers
%  
%   Markers
%       Marker data
%
%   VideoFrameRate
%       Rate at which the marker data was sampled
%
%   RotationMatrix
%       Rotation matrix of the lab coordinate frame to the OpenSim
%       coordinate frame. This input takes the form of a struct with field
%       Marker and ForcePlate containing 3x3 rotation matrices.
%
% OUTPUT:
%   MLabels
%       Marker labels after processing
%
%   Markers
%       Marker data after processing
%
%   vTime
%       Time vector, used as input to writeMarkersToTRC.
%
%   vFrms
%       Frame number vector, used as input to writeMarkersToTRC.
% 
%   missing_markers
%       Indices of the missing marker coordinates.
% 
% Original author: ??
% Original date: ??
%
% Last edit by: 
% Wouter Muijres 28-05
%   - Clean script
%   - Erasing writeMarkersToTRC function out of the processing function to
%   allow for user specific marker data processing before the .trc file is
%   constructed.
% --------------------------------------------------------------------------

% Number of frames and markers
[nvF, ~] = size(Markers);

% throw away dummy markers (name starts with *)
indexMLabels    = find(~contains(MLabels,'*'));
non_dummy       = indexMLabels*3+[-2,-1,0]';
indexMarkers    = non_dummy(:)';
Markers = Markers(:, indexMarkers);
MLabels = MLabels(indexMLabels);

% number of markers
vFrms = (1:nvF)';
vTime = (1/VideoFrameRate*(vFrms-1));

%set missing frames to NaN;
Markers(Markers == 0) = NaN;

% flagging marker coordinates invisible during the whole trial
missing_markers = find((sum(isnan(Markers)) == size(Markers,1)));

% Rotate data. rotation lab_frame to opensim
Markers = rot3DVectors(RotationMatrix.Markers, Markers);

% change all mm units to meters in one shot
Markers = 0.001 * Markers;

end 