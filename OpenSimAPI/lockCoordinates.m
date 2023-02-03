function lockCoordinates(file_model_in, coordinates,file_model_out)
% lockCoordinates locks specified coordinates in the given joint and saves
% the adapted model with locked joints
%
%   INPUT:
%   (1) file_model_in
%           filepath to the base model
%   (2) coordinates
%           1xn cell array with the names of the joints to lock
%   (3) file_model_out
%           filepath of the new model with the locked joints
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

% load the model
model = Model(file_model_in);

% get a set of all the coordinates in the model
coordSet = model.getCoordinateSet();

for i = 1:numel(coordinates)
    coordinate = coordinates{i};

    % lock the coordinate
    coordSet.get(coordinate).set_locked(1);
end

% Save the updated model.
model.print(file_model_out);
model.delete();

end