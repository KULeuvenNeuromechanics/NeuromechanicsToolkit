function [comStruct] = getOpenSimCOM(file_model)
% OpenSimCOM reads the center of mass of all bodies in the provided OpenSim
% model and writes it to a struct
%
%   INPUT:
%   (1) file_model
%           filepath to the OpenSim model
%
%   OUTPUT:
%   (1) struct with the names of the bodies as fieldnames and the values of
%   the center of mass.
%
%
% Original author: Bram Van Den Bosch 
% Original date: 23/01/2023
% --------------------------------------------------------------------------
import org.opensim.modeling.*

% Load the model
model = Model(file_model);

% Get the number of bodies in the model
numBodies = model.getBodySet().getSize();

% Initialize a struct to store the center of mass position of each body
comStruct = struct;

% Loop through each body in the model
for i = 0:numBodies-1
    % Get the current body
    body = model.getBodySet().get(i);
    % Get the name of the current body
    bodyName = char(body.getName());
    % Get the center of mass position of the current body
    com = body.getMassCenter();
    % store the x,y,z coordinates in an array
    comPos = [com.get(0), com.get(1), com.get(2)];
    % Create a new field in the struct with the body name and the center of mass position
    comStruct.(bodyName) = comPos;
end

end