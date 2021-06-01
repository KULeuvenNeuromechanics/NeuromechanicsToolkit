function rot = SelectRotationMatrix(labname)
% --------------------------------------------------------------------------
%SelectRotationMatrix 
%    outputs a struct based on the lab that is given as an input.
% 
% INPUT:
%   labname
%       name of the lab the data is recorded. This can be "overground_Mall"
%       for the overground walkway in the MALL, "treadmill_MALL" for the 
%       treadmill in the MALL
%  
% OUTPUT:
%   rot
%       rot is a struct containing the field Markers and ForcePlate which 
%       are the rotation matrices for the respective data.
%
% Original author: Wouter Muijres
% Original date: 01/06/2021
%
% Last edit by: -
% Last edit date: DD/MM/YYYY
% --------------------------------------------------------------------------

rot = struct();
if strcmp(labname,'overground_MALL')
    rot.Markers     = [0, -1, 0;0, 0, 1;-1, 0, 0];
    rot.ForcePlate  = [0, 1, 0;1, 0, 0;0, 0, -1];
elseif strcmp(labname,'treadmill_MALL')
    rot.Markers     = [0, -1, 0;0, 0, 1;-1, 0, 0];
    rot.ForcePlate  = [-1, 0, 0;0, 1, 0;0, 0, -1];
end

end