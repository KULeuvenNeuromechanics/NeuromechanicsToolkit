function ParamsToOsim(muscleParams,muscleNames,modelPath)
% ParamsToOsim
%   This function writes muscle parameters to a new osim model, based on a
%   given model.
%
% INPUT:
%   -muscleParams-
%   * 5 x nMuscles structure with
%       * FMo         : maximal isometric force
%       * lMo         : optimal fiber length
%       * lTs         : tendon slack length 
%       * alphao      : optimal pennation angle OR penation angle at lMo
%       * kT          : tendon stiffness; this parameter is not used.
%  
%   -muscleNames-  
%   * cell structure with the muscles from which muscle parameters are 
%   available
%
%   -modelPath-
%   * path to the original model file
% 
% OUTPUT:
%   * new osim model with the specified parameters. Model is saved at the
%   same location as the original osim model under the name 'newParams';
%   i.e. the original model will not be overwritten.
%
% Original author: Bram Van Den Bosch
% Original date: 12/05/2021


import org.opensim.modeling.*

FMo    = muscleParams.FMo;
lMo    = muscleParams.lMo;
lTs    = muscleParams.lTs;
alphao = muscleParams.alphao;
kT     = muscleParams.kT;

listing = dir(modelPath);
modelFilePath = listing.folder;
modelFile     = listing.name;
newModelFile = 'newParams.osim'; % name of the new osim model 

% Load the original model and initialize
model = Model(fullfile(modelFilePath, modelFile));
model.initSystem();

% Get the muscles of the original model
muscles = model.getMuscles(); 

% Count the muscles with new parameters
nMuscles = length(muscleNames);

disp(['Number of muscles with new parameters: ' num2str(nMuscles)]);

% loop through muscles to adapt new parameters
for i = 1:nMuscles 
    
    % get the muscle in the generic model
    currentMuscle = muscles.get(muscleNames{i});

    % set new parameters
    currentMuscle.setMaxIsometricForce(FMo(i));
    currentMuscle.setOptimalFiberLength(lMo(i));
    currentMuscle.setTendonSlackLength(lTs(i));
    currentMuscle.setPennationAngleAtOptimalFiberLength(alphao(i));
    
    % er is geen mogelijkheid om kT te definiëren in het model? 
    
end
 
% save the new model to an osim file
model.print(fullfile(modelFilePath, newModelFile));

end


