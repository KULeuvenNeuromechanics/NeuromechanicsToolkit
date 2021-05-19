function rot = SelectRotationMatrix(labname)
% SelectRotationMatrix outputs a struct based on the lab that is given as
% an input.
% 
% Inputs: 
% labname = name of the lab the data is recorded. This can be 
% "overground_Mall" for the overground walkway in the MALL, 
% "treadmill_MALL" for the treadmill in the MALL
% 
% Outputs:
% rot is a struct containing the field Markers and ForcePlate which are the
% rotation matrices for the respective data.
% 
% If transformation for your lab are missing. Please ad an elseif branch
% with the correct rotatations.

rot = struct();
if strcmp(labname,'overground_MALL')
    rot.Markers     = [0, -1, 0;0, 0, 1;-1, 0, 0];
    rot.ForcePlate  = [0, 1, 0;1, 0, 0;0, 0, -1];
elseif strcmp(labname,'treadmill_MALL')
    rot.Markers     = [0, -1, 0;0, 0, 1;-1, 0, 0];
    rot.ForcePlate  = [-1, 0, 0;0, 1, 0;0, 0, -1];
end

end