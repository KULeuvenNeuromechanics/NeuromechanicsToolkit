function rot = SelectRotationMatrix(labname)
% --------------------------------------------------------------------------
%SelectRotationMatrix 
%    outputs a struct based on the lab that is given as an input.
% 
% INPUT:
%   - labname -
%	* name of the lab the data is recorded. This can be 
%		*	"overground_MALL" for the overground walkway in the MALL
%		*	"treadmill_MALL" for the treadmill in the MALL
%		*	"CMAL_1" for gait lab 1 in Pellenberg
%  
% OUTPUT:
%   - rot -
%	* rot is a struct containing the field Markers and ForcePlate which 
%	are the rotation matrices for the respective data.
%
% Original author: Wouter Muijres
% Original date: 01/06/2021
%
% Last edit by: Bram Van Den Bosch
% Last edit date: 08/07/2021
% --------------------------------------------------------------------------

rot = struct();
if strcmp(labname,'overground_MALL')
    rot.Markers     = [0, -1, 0;0, 0, 1;-1, 0, 0];
    rot.ForcePlate  = [0, 1, 0;1, 0, 0;0, 0, -1];
elseif strcmp(labname,'treadmill_MALL')
    rot.Markers     = [0, -1, 0;0, 0, 1;-1, 0, 0];
    rot.ForcePlate  = [-1, 0, 0;0, 1, 0;0, 0, -1];
elseif strcmp(labname,'CMAL_1')
    rot.Markers     = [-1, 0, 0;0, 0, 1;0, 1, 0];
    rot.ForcePlate  = [-1, 0, 0;0, 1, 0;0, 0, -1];
end

end