function writeGRFsToMOT(forces1,forces2,cop1,cop2,Ty1,Ty2,FrameRate,outputfilename)
% Purpose:  Write ground reaction forces applied at COP to a 
%           motion file (fname) for input into the SimTrack
%           workflow.
%
% Input:   GRFTz is a structure containing the following data
%          tStart is the starting time of the data set
%          sF is the sampling frequency of the data
%          fname is the name of the file to be written.
%
% Output:   The file 'fname' is written to the current directory.
% ASeth, 09-07
% WMuijres, 05-21 clean up:
%   - erase commented code
%   - uncomplicate code at some points
%   - integrate with existing write .mot function of Tim Dorn

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
forceData   = [Forces1(:,1) Forces1(:,2) Forces1(:,3) cop1(:,1) cop1(:,2) cop1(:,3)  Forces2(:,1) Forces2(:,2) Forces2(:,3) cop2(:,1) cop2(:,2) cop2(:,3) zeros(nRowst,1) Ty1 zeros(nRowst,1)  zeros(nRowst,1) Ty2 zeros(nRowst,1) ];
dataMatrix  = [time forceData];

%%  Open file for writing.
generateMotFile(dataMatrix, colnames, outputfilename)
return

