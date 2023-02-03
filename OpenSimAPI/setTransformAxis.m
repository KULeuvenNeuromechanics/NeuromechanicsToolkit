function setTransformAxis(file_model_in,coordinateTransforms,file_model_out)
% setTransformAxis sets the transform axis of a given coordinate and
% saves the adjusted model
%
%   INPUT:
%   (1) file_model_in
%           filepath to the base model
%   (2) coordinateTransforms
%           a struct with the names of the joints as field names which 
%           contain fields with the names of the coordinates and the
%           values of the x, y, z values for the transform axis
%   (3) file_model_out
%           filepath of the new model with the set axis
%
%   OUTPUT:
%   (1) adjusted OpenSim model
%
%
% Original author: Bram Van Den Bosch 
% Original date: 30/01/2023
%
% Last edit by: Bram Van Den Bosch 
% Last edit date: 31/01/2023
% --------------------------------------------------------------------------

import org.opensim.modeling.*;

% Load the model.
model = Model(file_model_in);

% get the joints referenced in coordinateTransforms
joints = fieldnames(coordinateTransforms);

% get the joint set
jointSet = model.getJointSet();

% iterate through the joints
for i = 1:numel(joints)
    joint_name = joints{i};

    % get the opensim joint object
    joint = jointSet.get(joint_name);
    joint = org.opensim.modeling.CustomJoint.safeDownCast(joint);

    % get the coordinates and their indexes in SpatialTransform
    coordNames = joint.getSpatialTransform.getCoordinateNames;
    for c = 0:coordNames.getSize()-1
        coord_names{:,c+1} = char(coordNames.get(c));
    end

    % get coordinates referenced in coordinateTransforms.joint_name
    coordinates = fieldnames(coordinateTransforms.(joint_name));

    % iterate through the coorndinates
    for j = 1:numel(coordinates)
        coord = coordinates{j};

        % get the index of where the coord is in the transform axis
        idx = find(strcmp(coord,coord_names));

        % set the transform axis for this coord
        joint.getSpatialTransform().getTransformAxis(idx-1).setAxis(Vec3(...
            coordinateTransforms.(joint_name).(coord)(1),...
            coordinateTransforms.(joint_name).(coord)(2),...
            coordinateTransforms.(joint_name).(coord)(3)));
    end
end

% Save the updated model.
model.print(file_model_out);
model.delete();

end
