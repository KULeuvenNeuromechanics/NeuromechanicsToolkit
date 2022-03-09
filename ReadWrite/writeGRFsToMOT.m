function writeGRFsToMOT(forces1,forces2,cop1,cop2,Ty1,Ty2,FrameRate,outputfilename)

% Input:   GRFTz is a structure containing the following data
%          tStart is the starting time of the data set
%          sF is the sampling frequency of the data
%          fname is the name of the file to be written.
%
% Output:   The file 'fname' is written to the current directory.
% ASeth, 01/09/07
% WMuijres, 28/05/21 clean up:
%   - erase commented code
%   - uncomplicate code at some points
%   - integrate with existing write .mot function of Tim Dorn

% --------------------------------------------------------------------------
%FUNCTIONNAME 
%   Write ground reaction forces applied at COP to a motion file (fname) 
%   for input into the SimTrack workflow.
% 
% INPUT:
%   forces1
%       nx3 ground reaction force data for the right leg
%
%   forces2
%       nx3 ground reaction force data for the left leg
%
%   cop1
%        nx3 center of pressure data for the right leg
%
%   cop2
%        nx3 center of pressure data for the left leg
%
%   Ty1
%       nx3 torque vector for the right leg
%
%   Ty2
%       nx3 torque vector for the left leg
% 
%   FrameRate
%       sampling frequency forces
%  
%   outputfilename
%       directory and name to which the .mot files is stored
%
% OUTPUT:
%   []
%       The file 'outputfilename' is written to the current directory.
%
% Original author: ASeth, 01/09/07
% WMuijres, 28/05/21 clean up:
%   - erase commented code
%   - uncomplicate code at some points
%   - integrate with existing write .mot function of Tim Dorn
% --------------------------------------------------------------------------

% In case of nan values set to 0
forces1(isnan(forces1)) = 0;
forces2(isnan(forces2)) = 0;
cop1(isnan(cop1))       = 0;
cop2(isnan(cop2))       = 0;
Ty1(isnan(Ty1))         = 0;
Ty2(isnan(Ty2))         = 0;

Forces1=forces1(:,1:3);
Forces2=forces2(:,1:3);

% Generate column labels for forces, COPs, and vertical torques.
% Order:  GRF(xyz), COP(xyz), T(xyz)
colnames{1} = 'time';
colnames{2} = 'R_ground_force_vx';
colnames{3} = 'R_ground_force_vy';
colnames{4} = 'R_ground_force_vz';
colnames{5} = 'R_ground_force_px';
colnames{6} = 'R_ground_force_py';
colnames{7} = 'R_ground_force_pz';
colnames{8} = 'L_ground_force_vx';
colnames{9} = 'L_ground_force_vy';
colnames{10} = 'L_ground_force_vz';
colnames{11} = 'L_ground_force_px';
colnames{12} = 'L_ground_force_py';
colnames{13} = 'L_ground_force_pz';
colnames{14} = 'R_ground_torque_x';
colnames{15} = 'R_ground_torque_y';
colnames{16} = 'R_ground_torque_z';
colnames{17} = 'L_ground_torque_x';
colnames{18} = 'L_ground_torque_y';
colnames{19} = 'L_ground_torque_z';

[nRowst,~]      = size(forces1); % number of samples in force vectors

% Write time array to data matrix.
time = (0:1/FrameRate:((nRowst-1)/FrameRate))';

% Check for the number of columns Ty1 and Ty2 have. If 1 another 2 columns
% another two columns are added.
if size(Ty1,2) == 3
    forceData   = [Forces1 cop1  Forces2 cop2 Ty1 Ty2];
elseif size(Ty1,2) == 1
    forceData   = [Forces1 cop1 Forces2 cop2 zeros(nRowst,1) Ty1 ...
        zeros(nRowst,1)  zeros(nRowst,1) Ty2 zeros(nRowst,1) ];
else
    error('Torque matrices dimension incompatible with input into writeGRFsToMOT.')
end
dataMatrix  = [time forceData];

%%  Open file for writing.
generateMotFile(dataMatrix, colnames, outputfilename)
return

