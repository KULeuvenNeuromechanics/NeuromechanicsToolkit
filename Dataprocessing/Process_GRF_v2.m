function [ForcesPlateData] = Process_GRF_v2(AnalogSignals,threshold,grf_filter,AnalogFrameRate,ParameterGroup,RotationMatrix)

% --------------------------------------------------------------------------
% Process_GRF
%   Calculates/expresses Forces, Moments and COP data in the 
%   lab coordinate system from the outputs of the readC3D function. 
% 
% INPUT:
%   AnalogSignals
%       Matrix with the analog signals obtained from the readC3D function.
%   threshold
%   	threshold at which the relevant Analog channels are filtered with
%   	4th order butterworth filter.
%   grf_filter
%       Cutt-off frequency for the butterworth filter.
%   AnalogFrameRate
%       Sampling frequency at which GRF data is acquired.
%   ParameterGroup
%       Information on characteristics of the measurement set-up. E.g. the
%       dimensions of the force places and characteristics of the Vicon
%       cameras. (is this correct?)
%   RotationMatrix
%       Struct which contains the rotation matrices of the markers and
%       forceplate with fields Markers and ForcePlate. The rotation
%       matrices decribe the tranformation that rotates the data from the
%       original coordinate system to the lab's coordinate system.
%
% OUTPUT:
%   ForcesPlateData
%       structure that contains Forces, COP, and Moment for different force
%       plates. The force plates are referred to by the indices.
% 
% Original author: Unknown(?)
% Original date: ??
%
% Last editted by: 
% Wouter Muijres 26/05/2021 streamlined the loop and structured outputs in
% a loop.
%  
% --------------------------------------------------------------------------

% Obtain rotation matrices from struct
R       =  RotationMatrix.Markers;
R_FP    =  RotationMatrix.ForcePlate;

% Reorganize platform information
f = getForcePlatformFromC3DParameters(ParameterGroup);  % get FP information
nFP = length(f);                                        % get number of FP

% Compute COP location & create output matrix
nFR=length(AnalogSignals(:,1));

% Initialize output variables
ForcesPlateData = struct();

% loop over number of force plates
for i=1:nFP
    
    % convert corners and origin from mm to m
    f(i).corners	= 0.001*f(i).corners;
    f(i).origin     = 0.001*f(i).origin;
    
    % get the forces
    Ind = f(i).channel;
    F = AnalogSignals(:,Ind);
    
    % low pass filter
    [a,b]=butter(4,grf_filter/(AnalogFrameRate*0.5),'low');% low pass filter.
    F=filtfilt(a,b,F);
    
    Fx= F(:,1);  Fy=F(:,2);  Fz=F(:,3);
    Mx= F(:,4).*0.001;  My=F(:,5).*0.001;  Mz=F(:,6).*0.001;
    
    % get vertical distance between surface and origin FP
    dz = -1 * f(i).origin(3);
    
    % get the COP and free moment around vertical axis
    COPx = (-1*My + dz*Fx)./Fz;
    COPy = (Mx + dz*Fy)./Fz;
    Tz = Mz + COPy.*Fx - COPx.*Fy;
    
    % rotate FP info to correct coordinate system
    Fsel =[Fx Fy Fz];                   % forces
    Tsel =[zeros(length(Tz),2) Tz];     % free moment
    Flab = rot3DVectors(R_FP,Fsel);    % rotate forces to lab frame
    Tlab = rot3DVectors(R_FP,Tsel);    % rotate moments to lab frame
    Frot = rot3DVectors(R,Flab);        % rotate forces from lab to Osim
    Trot = rot3DVectors(R,Tlab);        % rotate moments from lab to Osim
    
    % get location COP in world frame
    pFP_lab         = sum(f(i).corners)./4;         % get position vector from lab to origin FP
    pFP_origin      = f(i).origin;                  % FP surface to FP origin
    pFP_origin_rot  = (R_FP * pFP_origin');        % rotate this vector to world frame
    COP             = [COPx COPy ones(nFR,1).*-pFP_origin(3)];   % Matrix with COP info
    COP_or_lab      = R_FP * COP';                  % rotate COP to lab
    
    COP_lab = ones(nFR,1)*pFP_lab + ones(nFR,1)*pFP_origin_rot' + COP_or_lab';   % add location FP in lab to COP position
    COProt  = rot3DVectors(R,COP_lab);
    
    % trim COP information with Ftrehsold of 20 N (COP nor reliable if
    % forces are low)
    ind=find(Frot(:,2)<threshold);
    for j=1:3
        COProt(ind,j)   = nan;
        Frot(ind,j)     = 0;
        Trot(ind,j)     = 0;
    end

    ForcesPlateData(i).Forces   = Frot;
    ForcesPlateData(i).COP      = COProt;
    ForcesPlateData(i).Moments  = Trot;
end

end