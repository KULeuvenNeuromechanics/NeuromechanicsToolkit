function  []=Opensim_IK(model,input_file,output_settings,output_IK,event,generic_settings_IK,varargin)
% Opensim_IK Uses API to solve inverse dynamics
%
%   INPUT:
%   (1) model=                 full filename osim model or osim model
%   (2) input_file=            full filename file with marker cordinates (*.trc)
%   (3) output_settings=       path+name to save the output
%   (4) output_IK=             path+name of the IK output file
%   (5) event=                 start and endpoint time (in seconds) if
%                              empty start end end time are extracted from
%                              trc file.
%   (6) generic_settings_IK=   path+name generic IK settings file (.xml file)
%   (7) varargin (in arbitrary order):
%       (1) diary: generates a file with the command window output.
%       (2) printresults: generates .sto files with error and model marker
%       locations.
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
NameDiary = getarg('diary',[],varargin{:});
if ~isempty(NameDiary)
    BoolDiary = 1;
    [OutPath,~,~] = fileparts(NameDiary);
    if ~isfolder(OutPath)
        mkdir(OutPath);
    end
    diary(NameDiary)
else
    BoolDiary = 0;
end

DirResults = getarg('printresults',[],varargin{:});

% test if we have to create the output folders
[OutPath,~,~] = fileparts(output_settings);
if ~isfolder(OutPath)
    mkdir(OutPath);
end

[OutPath,~,~] = fileparts(output_IK);
if ~isfolder(OutPath)
    mkdir(OutPath);
end

% load the Opensim classes
import org.opensim.modeling.*

% set up the IK tool
ikTool = InverseKinematicsTool(generic_settings_IK);

% use the loaded model
if isa(model,'org.opensim.modeling.Model')
    ikTool.setModel(model);
else
    osimmodel=Model(model);
    osimmodel.initSystem();     % initialise the model
    ikTool.setModel(osimmodel);
end

% search for the name of the output file
[~, name, ~]=fileparts(output_IK);

if isempty(event)
    % extract first and final time from the trajectory file
    sto         = Storage(input_file);
    event(1)    = sto.getFirstTime();
    event(2)    = sto.getLastTime();
end
% set the events
ikTool.setStartTime(event(1));
ikTool.setEndTime(event(2));

% Setup the ikTool for this trial
ikTool.setName(name);

% set up the motion file
ikTool.setMarkerDataFileName(input_file);

%set up the output file
ikTool.setOutputMotionFileName(output_IK);

% if specified set results locotion
if ~isempty(DirResults)
    ikTool.setResultsDir(DirResults);
end

% Save the settings in a setup file
ikTool.print(output_settings);

% Run IK
ikTool.run();

if BoolDiary
    diary off
end

end

%% checking variable input list
% Function that searches variable arguments input for string pattern and
% returns value of subsequent index.
% function adapted from script Prof. Dr. Andreas Daffertshofer
function val=getarg(name,default,varargin)
    index=find(strcmpi(name,varargin));
    if isempty(index)
        val=default;
    else
        val=varargin{index+1};
    end
end
