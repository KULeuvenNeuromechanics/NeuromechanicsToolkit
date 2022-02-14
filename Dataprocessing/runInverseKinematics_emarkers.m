function runInverseKinematics_emarkers(osimModel,IKTemplateFile,TrajectoryFile,IKMotOutputFile,SettingsDir,varargin)
% --------------------------------------------------------------------------
% This function runs the Inverse Kinematics tool based on OpenSim API
% syntax. In addition, this function also calculates marker errors per
% pamerker.
% 
% INPUT:
%   osimModel 
%       the OpenSim model instance
%  
%   TemplateFile
%       load template file in which the weighting of the different markers
%       are specified.
%
%   TrajectoryFile
%       the marker trajectories that will be tracked. 
% 
%   IKMotOutputFile
%       full path length of the output .mot file.
%
%   Variable input argument
%       individual_marker_errors
%           false(Default): no marker error is calculated.
%           true: calculates mean marker error and standard deviations
%
% Original author: Wouter Muijres
% Original date: 14/06/2021
%
% Last edit by: -
% Last edit date: -
% --------------------------------------------------------------------------

marker_errors = getarg('individual_marker_errors',false,varargin{:});

% Conditionally add individual marker errors to output in Command Window (mean error and standard deviation)
if marker_errors
    % Generate file with model markers
    iksetup = xmlread(IKTemplateFile);
    rep_merk_locs = iksetup.getElementsByTagName('report_marker_locations').item(0).getFirstChild.getNodeValue;
    if strcmp(rep_merk_locs,'false')
        iksetup.getElementsByTagName('report_marker_locations').item(0).getFirstChild.setNodeValue('true');
        xmlwrite(IKTemplateFile,iksetup)
    end
end

% import osim libs
import org.opensim.modeling.*

% Instantiate InverseKinematicsTool
ikTool = InverseKinematicsTool(IKTemplateFile);

% Set output
ikTool.setOutputMotionFileName(IKMotOutputFile);

% extract first and final time from the trajectory file
sto         = Storage(TrajectoryFile);
starttime   = sto.getFirstTime();
endtime     = sto.getLastTime();
% set first and final time for inverse kinematic file
ikTool.setStartTime(starttime)
ikTool.setEndTime(endtime)

% Set model
ikTool.setModel(osimModel);

% Set marker data
ikTool.setMarkerDataFileName(TrajectoryFile);

% Run IKTool
ikTool.run;

% Print settingsfile
[~,file_name,file_ext] = fileparts(IKTemplateFile);
ikTool.print(fullfile(SettingsDir,[file_name,file_ext]));

% report mean error and standard deviations per marker
if marker_errors
    % model marker position file produced by setting
    % report_marker_locations to true in the xml file
    storagedata = importdata(fullfile(SettingsDir,'_ik_model_marker_locations.sto'));
    modelmarker_loc = storagedata.data(:,2:end); % omit time vector
    modelmarker_labels = storagedata.colheaders(:,2:end);
    
    % read marker location and omit frame rate and time
    [marker_loc_temp, marker_labels_temp] = importTRCdata(TrajectoryFile);
    marker_labels   = marker_labels_temp(3:end);
    marker_loc      = marker_loc_temp(:,3:end);
    
    % model markers to only 
    modelmarker_labels_temp = cellfun(@(x) x(1:end-3),modelmarker_labels,'UniformOutput', false);
    modelmarker_labels_new = modelmarker_labels_temp(3:3:end);
    
    % number of markers in both model and experimantal marker set
    nmark_model = length(modelmarker_labels_new);
    nmark_data  = length(marker_labels);
    
    % check for which marker set has the most markers
    if nmark_model >= nmark_data
        lab_short_temp = marker_labels;
        data_short_temp = marker_loc;
        lab_long_temp = modelmarker_labels_new;
        data_long_temp = modelmarker_loc;
        
        nmark_short = nmark_data;
    else
        lab_short_temp = modelmarker_labels_new;
        data_short_temp = modelmarker_loc;
        lab_long_temp = marker_labels;
        data_long_temp = marker_loc;
        
        nmark_short = nmark_model;
    end
    
    ind_long_temp = zeros(1,nmark_short);
    
    % find markers that donot appear in the long marker matrix
    ind_remove_short_lab = find(contains(lab_short_temp,lab_long_temp));
    lab_short = lab_short_temp(ind_remove_short_lab);
    % select indeces in matrix coresponding to the removed labels
    ind_lab_short_mat   = [-2:0]'+ind_remove_short_lab*3;
    data_short          = data_short_temp(:,ind_lab_short_mat(:));
    
    % fond the order to sort sucht that the long labels/matrix is the order of
    % the short matrix
    nmark_short_upd = length(lab_short);
    i_array_long    = 1;
    for ii = 1:nmark_short_upd
        ind    = find(strcmp(lab_long_temp,lab_short{ii}), 1);
        if isempty(ind)
            i_array_long = i_array_long + 1;
            continue;
        else
            ind_long_temp(i_array_long) = ind;
            i_array_long = i_array_long + 1;
        end
    end
    
    % sort long labels
    ind_long_sort = ind_long_temp(ind_long_temp~=0);
    lab_long = lab_long_temp(ind_long_sort);
    
    % sort long matrix
    sortmarkers_long = [-2:0]' + ind_long_sort*3;
    data_long        = data_long_temp(:,sortmarkers_long(:));
    
    % calculate distance between model markers and experimental for each
    % timepoint
    error_markers = (data_long - data_short).^2;
    error_markers_norm = NaN(size(error_markers,1),length(lab_short));
    for i = 1:nmark_short_upd
        error_markers_norm(:,i) = sqrt(sum(error_markers(:,[0:2]+i),2));
    end
    
    % print the mean difference and standard deviation
    error_mean = mean(error_markers_norm,1);
    error_std  = std(error_markers_norm,1);
    fprintf('marker,\t mean,\t std \n')
    for jj = 1:nmark_short_upd
        fprintf('%s\t %.4f\t %.4f\n',lab_short{jj},error_mean(jj),error_std(jj))
    end
end

end

%% checking variable input list
% function adapted from script Prof. Dr. Andreas Daffertshofer
function val=getarg(name,default,varargin)
    index=find(strcmpi(name,varargin));
    if isempty(index)
        val=default;
    else
        val=varargin{index+1};
    end
end