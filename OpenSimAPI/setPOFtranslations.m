function setPOFtranslations(file_model_in, pofTranslations,file_model_out)
% setPOFtranslations writes the translations of the physical offset frames
% of all joints in the provided OpenSim model
%
% INPUT:
%   (1) file_model_in
%           filepath to the base OpenSim model
%   (2) pofTranslations
%           a struct with the names of the joints as field names and the 
%           values of translations of proximal and distal physical offset 
%           frames.
%   (1) file_model_out
%           filepath for the adjusted OpenSim model
%
%
% Original author: Bram Van Den Bosch
% Original date: 30/01/2023
%
% Last edit by: Bram Van Den Bosch
% Last edit date: 30/01/2023
% --------------------------------------------------------------------------

import org.opensim.modeling.*

% Load the OpenSim model
model = Model(file_model_in);

% Get a set of all the joints in the model
jointSet = model.getJointSet();

% Get the joints referenced in pofTranslations
joints = fieldnames(pofTranslations);

% Iterate through the set of joints
for i = 0:jointSet.getSize()-1
    joint = jointSet.get(i);
    jointName = char(joint.toString);

    if ismember(jointName,joints)
        % Get the frames
        proximal = joint.get_frames(0);
        distal = joint.get_frames(1);
    
        % Set the translation
        proximal.set_translation(Vec3(pofTranslations.(jointName)(1,1),pofTranslations.(jointName)(1,2),pofTranslations.(jointName)(1,3)));
        distal.set_translation(Vec3(pofTranslations.(jointName)(2,1),pofTranslations.(jointName)(2,2),pofTranslations.(jointName)(2,3)));
    end
end

% Save the updated model
model.print(file_model_out);
model.delete();

end