function  []=Opensim_IK(model,input_file,output_settings,output_IK,event,generic_settings_IK,varargin)
% Opensim_IK Uses API to solve inverse dynamics
%
%   INPUT:
%   (1) model=                 full filename osim model or osim model
%   (2) input_file=            full filename file with marker cordinates (*.trc)
%   (3) output_settings=       path+name to save the output
%   (4) output_IK=             path+name of the IK output file
%   (5) event=                 start and endpoin time (in seconds)
%   (6) generic_settings_IK=   path+name generic IK settings file (.xml file)
%   (7) varargin:
%       (1) Name of diary:
%
%   OUTPUT:
%
%   DEPENDENCIES:
%   (1) you have to install the opensim API to run this function (tested with 4.2)
%
%   AUTHOR:
%   Maarten Afschrift
%
%   Last edit by: Wouter Muijres
%   Last edit date: 18/02/2022
% --------------------------------------------------------------------------
% variable input arguments: diary
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

[OutPath,~,~] = fileparts(output_IK);
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

% load the Opensim classes
import org.opensim.modeling.*

% set up the IK tool
ikTool = InverseKinematicsTool(generic_settings_IK);

% use the loaded model
if isa(model,'org.opensim.modeling.Model')
    ikTool.setModel(osimmodel);
else
    osimmodel=Model(model);
    osimmodel.initSystem();     % initialise the model
    ikTool.setModel(osimmodel);
end

% search for the name of the output file
[~, name, ~]=fileparts(output_IK);

% set the events
ikTool.setStartTime(event(1));
ikTool.setEndTime(event(2));

% Setup the ikTool for this trial
ikTool.setName(name);

% set up the motion file
ikTool.setMarkerDataFileName(input_file);

%set up the output file
ikTool.setOutputMotionFileName(output_IK);

% Save the settings in a setup file
ikTool.print(output_settings);

% Run IK
ikTool.run();

if BoolDiary
    diary off
end

end

