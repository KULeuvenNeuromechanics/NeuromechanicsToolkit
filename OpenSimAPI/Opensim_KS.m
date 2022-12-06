function  []=Opensim_KS(model,input_file,output_settings,output_KS,event,generic_settings_KS,varargin)
% Opensim_KS uses the OpenSim API to generate the KS setup file and runs KS 
% through the command line
%
%   INPUT:
%   (1) model=                 full filename osim model or osim model
%   (2) input_file=            full filename file with marker cordinates (*.trc)
%   (3) output_settings=       path+name to save the output
%   (4) output_KS=             path+name of the KS output file
%   (5) event=                 start and endpoint time (in seconds) if
%                              empty start end end time are extracted from
%                              trc file.
%   (6) generic_settings_KS=   path+name generic KS settings file (.xml file)
%   (7) varargin (in arbitrary order):
%       (1) diary: generates a file with the command window output.
%       (2) printresults: generates .sto files with error and model marker
%       locations.
%
%   OUTPUT:
%
%   DEPENDENCIES:
%   (1) you have to install the opensim API to run this function (tested with 4.3)
%   (2) you have to install the KS, see https://simtk.org/projects/kalmanforik
%
% This script is based on the function Opensim_IK.m, originally by Maarten
% Afschrift
%
% Original author: Bram Van Den Bosch 
% Original date: 06/12/2022
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

[OutPath,~,~] = fileparts(output_KS);
if ~isfolder(OutPath)
    mkdir(OutPath);
end

%% prepare setup file
% load the OpenSim classes
import org.opensim.modeling.*

% import the generic settings
settings = InverseKinematicsTool(generic_settings_KS);

% use the loaded model
if isa(model,'org.opensim.modeling.Model')
    settings.setModel(model);
else
    osimmodel=Model(model);
    osimmodel.initSystem();     % initialise the model
    settings.setModel(osimmodel);
end

% search for the name of the output file
[~, name, ~]=fileparts(output_KS);

if isempty(event)
    % extract first and final time from the trajectory file
    sto         = Storage(input_file);
    event(1)    = sto.getFirstTime();
    event(2)    = sto.getLastTime();
end
% set the events
settings.setStartTime(event(1));
settings.setEndTime(event(2));

% Setup the ikTool for this trial
settings.setName(name);

% set up the motion file
settings.setMarkerDataFileName(input_file);

%set up the output file
settings.setOutputMotionFileName(output_KS);

% if specified set results locotion
if ~isempty(DirResults)
    settings.setResultsDir(DirResults);
end

% Save the settings in a setup file
settings.print(output_settings);

% Run KS
[dir,name,ext] = fileparts(output_settings);

cmd = ['cd "', dir, '" && KS -S ', name,ext];
system(cmd);

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
