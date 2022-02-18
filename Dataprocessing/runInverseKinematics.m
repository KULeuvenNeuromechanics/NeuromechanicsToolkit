function runInverseKinematics(osimModel,IKTemplateFile,TrajectoryFile,IKMotOutputFile,SettingsDir,varargin)
% --------------------------------------------------------------------------
% This function runs the Inverse Kinematics tool based on OpenSim API
% syntax.
% 
% INPUT:
%   osimModel 
%       the OpenSim model instance
%  
%   TemplateFile
%       load template file in which the weighting of the different markers
%       are specified.
%
%   TrajectoryFile
%       the marker trajectories that will be tracked. 
% 
%   IKMotOutputFile
%       full path length of the output .mot file.
%
% 
% Original author: Wouter Muijres
% Original date: 14/06/2021
%
% Last edit by: -
% Last edit date: -
% --------------------------------------------------------------------------

% import osim libs
import org.opensim.modeling.*

% Instantiate InverseKinematicsTool
ikTool = InverseKinematicsTool(IKTemplateFile);

% Set output
ikTool.setOutputMotionFileName(IKMotOutputFile);

% extract first and final time from the trajectory file
sto         = Storage(TrajectoryFile);
starttime   = sto.getFirstTime();
endtime     = sto.getLastTime();
% set first and final time for inverse kinematic file
ikTool.setStartTime(starttime)
ikTool.setEndTime(endtime)

if isa(model,'')
    
end

% Set model
ikTool.setModel(osimModel);

% Set marker data
ikTool.setMarkerDataFileName(TrajectoryFile);

% Run IKTool
ikTool.run;

% Print settingsfile
[~,file_name,file_ext] = fileparts(IKTemplateFile);
ikTool.print(fullfile(SettingsDir,[file_name,file_ext]));

end