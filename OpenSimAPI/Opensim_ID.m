function [] = Opensim_ID(model_dir,event,File_ExternaLoads,input_motion,output_path,output_name,...
    output_settings,generic_settings, varargin)
%Opensim_ID Calculates Inverse Dynamics
%
%   INPUT:
%       (1) model_dir               path+name of the model
%       (2) event                   rowvector with start and end time
%       (3) File_ExternaLoads       path+name of the external loads file
%       (4) input_motion            path+name of the input motion (ik)
%       (5) output_path             path of the output file
%       (6) output_name             name of the output file
%       (7) output_settings         path+name of the settings file
%       (8) varargin:
%           (8.1) Name of diary:
%
%   OUTPUT:
%
%   DEPENDENCIES:
%   (1) you have to install the opensim API to run this function (tested with 4.2)
%
%   AUTHOR:
%   Maarten Afschrift

% variable input arguments
BoolDiary = 0;
if ~isempty(varargin)
    BoolDiary = 1;
    NameDiary = varargin{1};
end

% test if we have to create the output folders
[OutPath,~,~] = fileparts(output_settings);
if ~isfolder(OutPath)
    mkdir(OutPath);
end

[OutPath,~,~] = fileparts(output_path);
if ~isfolder(OutPath)
    mkdir(OutPath);
end

if BoolDiary
    [OutPath,~,~] = fileparts(NameDiary);
    if ~isfolder(OutPath)
        mkdir(OutPath);
    end
    diary(NameDiary)
end

% import opensim API
import org.opensim.modeling.*

% use the loaded model
model=Model(model_dir);
model.initSystem();     % initialise the model

% initialise the ID tool
idTool = InverseDynamicsTool(generic_settings);
% idTool.setLoadModelAndInput(true)
idTool.setModel(model);
% input external loads
idTool.setExternalLoadsFileName(File_ExternaLoads);
% get the name
[~, name,~]=fileparts(input_motion);

% Setup the idTool for this trial
idTool.setName(name);
idTool.setCoordinatesFileName(input_motion);
idTool.setLowpassCutoffFrequency(6)

% set up the events
idTool.setStartTime(event(1,1));
idTool.setEndTime(event(1,2));

% set output of the id tool
idTool.setResultsDir(output_path)
idTool.setOutputGenForceFileName(output_name);

% Save the settings in a setup file
idTool.print(output_settings);

% run the idTool
idTool.run();

end

