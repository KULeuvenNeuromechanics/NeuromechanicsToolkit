function rotated = rot3DVectors(rot, vecTrajs)
% --------------------------------------------------------------------------
%rot3DVectors 
%   Rotate any N number of 3D points/vectors
% 
% INPUT:
%   rot
%       rot is 3x3 rotation matrix
%  
%   vecTrajs
%       Matrix of 3D trajectories (i.e. ntime x 3N cols)
% 
% OUTPUT:
%   rotated
%   	rotated 3D vector trajectories
%
% 
% Original author: Ajay Seth
% Original date: ??
% --------------------------------------------------------------------------

[nt, nc] = size(vecTrajs);

if rem(nc,3),
    error('Input trajectories must have 3 components each.');
end

for I = 1:nc/3,
    vecTrajs(:,3*I-2:3*I) = [rot*vecTrajs(:,3*I-2:3*I)']';
end

rotated = vecTrajs;