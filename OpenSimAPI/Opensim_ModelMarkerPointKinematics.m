function Opensim_ModelMarkerPointKinematics(osimmodel,events,ikfile,markername,prefixname,PKfolder)


% --------------------------------------------------------------------------
%FUNCTIONNAME 
% Reconstruct model marker positions in the event of missing experimental
% markers.
%
% INPUT:
%   osimmodel
%       Either OpenSim model class or path to model xml file.
%  
%   events
%       Time window for which point kinematics will be calculated.
% 
%   ikfile
%       Path to IKfile.
%
%   markername
%       Marker name to reconstruct.
%
%   prefixname
%       Prefix of the file name under which the data is saved.
%
%   PKfolder
%       Output folder.
%
% OUTPUT:
%
%   Output is saved in the PKfolder under the name specified in prefixname
%   and markername
% 
% Original author: Wouter Muijres
% Original date: 07/03/2022
%
% Last edit by: Wouter Muijres
% Original date: 07/03/2022
% --------------------------------------------------------------------------

import org.opensim.modeling.*

% use the loaded model if model input is path to model
if ~isa(osimmodel,'org.opensim.modeling.Model')
    model = Model(osimmodel);
end
model.initSystem();

markerset = model.getMarkerSet; % get markerset
% search for marker in the marker set
for ii = 0:markerset.getSize-1
    marker = markerset.get(ii);
    if strcmp(marker.getName,markername), break; end
end

% create pointkinematics instance
pointkinematics = org.opensim.modeling.PointKinematics();

% check whether point location is of correct class
pointkinematics.setPoint(marker.get_location); % Set point location
pointkinematics.setBody(marker.getParentFrame); % Movement frame of model marker
pointkinematics.setRelativeToBody(model.get_ground); % Frame in which point moment is calculated
% set default values
pointkinematics.setInDegrees(true)
pointkinematics.setOn(true);
pointkinematics.setStepInterval(1);
pointkinematics.setPointName(markername); % set name of point

% Setting analyse tool
model.addAnalysis(pointkinematics); % add analysis to file
tool = org.opensim.modeling.AnalyzeTool(model);
tool.setLoadModelAndInput(true); % load model to load pk analysis
tool.setCoordinatesFileName(ikfile); % ik mot file path
tool.setName(prefixname); % prefix name of saved file
tool.setResultsDir(PKfolder); % output folder
tool.setStartTime(events(1)); % start time 
tool.setFinalTime(events(2)); % end time
tool.run(); % run pointkinematics

end