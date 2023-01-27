function [pofTranslations] = getPOFtranslations(file_model)
% getPOFtranslations reads the translations of the physical offset frames
% of all joints in the provided OpenSim model and writes it to a struct
%
%   INPUT:
%   (1) file_model
%           filepath to the OpenSim model
%
%   OUTPUT:
%   (1) struct with the names of the joints as fieldnames and the values of
%   translations of proximal and distal physical offset frames.
%
%
% Original author: Bram Van Den Bosch 
% Original date: 24/01/2023
% --------------------------------------------------------------------------
import org.opensim.modeling.*

% Load the OpenSim model
model = Model(file_model);

% Get a set of all the joints in the model
jointSet = model.getJointSet();

% Initialize a variable to store the POF translations
pofTranslations = [];

% Iterate through the set of joints
for i = 0:jointSet.getSize()-1
    joint = jointSet.get(i);
    jointName = char(joint.toString);
    % Get the frames
    proximal = joint.get_frames(0);
    distal  = joint.get_frames(1);
    % Get the translation
    pofTranslations.(jointName) = [proximal.get_translation.getAsMat'; distal.get_translation.getAsMat'];
end

end