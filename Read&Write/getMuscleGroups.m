function [muscle_groups] = getMuscleGroups(modelPath,muscleNames)
% --------------------------------------------------------------------------
%getMuscleGroups 
%   Make an array with nMuscles colums and nMuscleGroups rows. A muscle
%   group is group of muscles that actuate a specific movement, e.g. dorsi
%   flexion.
% 
% INPUT:
%   - modelPath -
%   * path to the OpenSim model
%   
%   - muscleNames
%   * cell array with all muscles you want to analyze

% OUTPUT:
%   - muscle_groups -
%   * nMuscleGroups x nMuscles matrix with '1' if muscle is part of the muscle
%   group and '0' if not
% 
% Original author: Dhruv Gupta, Bram Van Den Bosch
% Original date: 17/06/2021
%
% Last edit by: Bram Van Den Bosch
% Last edit date: 21/06/2021
% --------------------------------------------------------------------------

%% Input
% import OpenSim MATLAB API
import org.opensim.modeling.*

% load the model and initialize
model = Model(modelPath);
model.initSystem();

% get the muscles from the model
muscles  = model.getMuscles(); 
nMuscles = length(muscleNames);

%% Extract 
FS         = model.getForceSet; % ForceSet is the name of muscle group in OpenSim
num_groups = FS.getNumGroups;   % determine how many ForceSets (groups) there are in the model

for i = 1:num_groups
    group          = FS.getGroup(i-1);    % set 'group' as the ObjectGroup
    group_names{i} = char(group.getName); % get the name of of the ForceSet
    
    % convert the muscle names in the group to characters
    all_muscles_in_group{i} = char(group.getPropertyByIndex(0).toString());
    all_muscles_in_group{i} = all_muscles_in_group{i}(2:end-1); % remove '(' and ')'
    muscles_in_group{i,:}   = split(all_muscles_in_group{i},' '); 
    
    % group has to be re-initialized for each ForceSet
    clear group 
end

%% Write
muscle_groups = zeros(num_groups,nMuscles)

for i = 1:num_groups
    % crosscheck for each muscle group if input muscles are in it or not
    muscle_groups(i,:) = double(ismember(muscleNames,muscles_in_group{i}'));
end

end

