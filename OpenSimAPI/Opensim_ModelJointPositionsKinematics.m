function jointposkin = Opensim_ModelJointPositionsKinematics(model,ikfile,jointnames,varargin)
% --------------------------------------------------------------------------
% FUNCTIONNAME 
% Reconstruct kinematics joint location in function of movement.
%
% INPUT:
%   osimmodel
%       OpenSim model class
% 
%   ikfile
%       Path to IKfile.
%
%   jointnames
%       Joint names to reconstruct.
%
%   events (OPTIONAL)
%       Time window for which point kinematics will be calculated.
%
% OUTPUT:
%
%   jointposkin
%       structure with positions, velocities, and accelerations of the 
%       selected joints
% 
% --------------------------------------------------------------------------

import org.opensim.modeling.*

% use the loaded model if model input is path to model
model.initSystem();

% get storage IK file
iksto = Storage(ikfile);
default_event = [iksto.getFirstTime,iksto.getLastTime];
dt = diff(default_event)/iksto.getSize;
event = getarg('event',default_event,varargin);
ntpoints = diff(event)/dt;

% get body names
bodyset = model.getBodySet;
nbodies = bodyset.getSize;
all_bodies = cell(1,nbodies);
for j = 0:nbodies-1
    all_bodies{j+1} =  bodyset.get(j).getName.toCharArray';
end

% get joint names
jointset = model.getJointSet;
njoints = jointset.getSize;
all_joints = cell(1,njoints);
for i = 0:njoints-1
    all_joints{i+1} =  jointset.get(i).getName.toCharArray';
end

n_joint_positions = length(jointnames);
positions = NaN(ntpoints,n_joint_positions*3);
velocities = NaN(ntpoints,n_joint_positions*3);
accelerations = NaN(ntpoints,n_joint_positions*3);
for k = 1:n_joint_positions
    jointname = jointnames{k};
    % idx joint in jointset
    ijoint = find(strcmp(jointname,all_joints))-1;
    % get parent frame joint
    child_frame = jointset.get(ijoint).get_frames(1);
    % get ofset in parent frame joint
    offset_in_parent = child_frame.get_translation;
    % get name of parent frame
    child_frame_name = child_frame.getParentFrame.getName.toCharArray';
    % get parent body
    ibody = find(strcmp(child_frame_name,all_bodies))-1;
    child_body = bodyset.get(ibody);

    % create pointkinematics instance
    pointkinematics = org.opensim.modeling.PointKinematics();

    % check whether point location is of correct class
    pointkinematics.setPoint(offset_in_parent); % Set point location
    pointkinematics.setBody(child_body); % Movement frame of model marker
    pointkinematics.setRelativeToBody(model.get_ground); % Frame in which point moment is calculated
    % set default values
    pointkinematics.setInDegrees(true)
    pointkinematics.setOn(true);
    pointkinematics.setStepInterval(1);
    pointkinematics.setPointName(jointname); % set name of point

    % Setting analyse tool
    model.addAnalysis(pointkinematics); % add analysis to file
    tool = org.opensim.modeling.AnalyzeTool(model);
    tool.setLoadModelAndInput(true); % load model to load pk analysis
    tool.setCoordinatesFileName(ikfile); % ik mot file path
    tool.setStartTime(event(1)); % start time
    tool.setFinalTime(event(2)); % end time
    tool.setPrintResultFiles(false); % do not print file
    tool.run(); % run pointkinematics

    % get position data
    position_sto = pointkinematics.getPositionStorage;
    velocity_sto = pointkinematics.getVelocityStorage;
    acceleration_sto = pointkinematics.getAccelerationStorage;
    % loop over time point to extract data
    nrow = position_sto.getSize;
    for i = 1:nrow
        positions(i,(1:3)+3*(k-1)) = position_sto.getStateVector(i-1).getData.getAsVec3.getAsMat';
        velocities(i,(1:3)+3*(k-1)) = velocity_sto.getStateVector(i-1).getData.getAsVec3.getAsMat';
        accelerations(i,(1:3)+3*(k-1)) = acceleration_sto.getStateVector(i-1).getData.getAsVec3.getAsMat';
    end
end

% save outcomes analysis
jointposkin.position = positions;
jointposkin.velocities = velocities;
jointposkin.accelerations = accelerations;
jointposkin.labels   = jointnames;

end