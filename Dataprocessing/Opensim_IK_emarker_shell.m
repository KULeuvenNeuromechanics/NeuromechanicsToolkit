function Opensim_IK_emarker_shell(osimModel,IKTemplateFile,TrajectoryFile,IKMotOutputFile,varargin)
% to do: adjust instructions function
% --------------------------------------------------------------------------
% This function runs the Inverse Kinematics tool based on OpenSim API
% syntax. This function provides as shell that makes it possible to
% calculate individuals marker errors.
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
%       Verbose: Output model marker errors to command window
%       extrainfo: write extra info at the start of the trial in the diary
%       file.
%       
% Original author: Wouter Muijres
% Original date: 16/02/2022
%
% Last edit by: -
% Last edit date: -
% --------------------------------------------------------------------------

verbose       = getarg('verbose',false,varargin{:}); % get verboselevel
extrainfo     = getarg('extra_trialinfo',[],varargin{:});

% Generate individual marker errors (mean error and standard deviation)
% Change setup file to generate file with model markers
iksetup = xmlread(IKTemplateFile);
rep_merk_locs = iksetup.getElementsByTagName('report_marker_locations').item(0).getFirstChild.getNodeValue;
if strcmp(rep_merk_locs,'false')
    iksetup.getElementsByTagName('report_marker_locations').item(0).getFirstChild.setNodeValue('true');
    xmlwrite(IKTemplateFile,iksetup)
end
% set directory for model marker/error file
ikresults_dir = fullfile(fileparts(IKMotOutputFile),'Results');
if ~isfolder(ikresults_dir)
    mkdir(ikresults_dir);
end

% print diary individual_marker_error
[filepath,name] = fileparts(IKMotOutputFile);
diary_file      = fullfile(filepath,'diary.txt');

% % Change weights of certain markers
% if ~(contains(name,'ankle') || contains(name,'knee'))
%     iksetup.getElementsByTagName('IKTaskSet').item(0).getFirstChild.getNodeValue;
%     IKMarkerTask = iksetup.getElementsByTagName('IKTaskSet').item(0).getElementsByTagName('IKMarkerTask');
%     weightClav = IKMarkerTask.item(2).getElementsByTagName('weight').item(0).getFirstChild;
%     weightClav.setNodeValue('5');
%     weightC7 = IKMarkerTask.item(37).getElementsByTagName('weight').item(0).getFirstChild;
%     weightC7.setNodeValue('5');
%     xmlwrite(IKTemplateFile,iksetup);
% end

% start new file from static file (assume static file is the first file)
if contains(name,'static')
    fid = fopen(diary_file,'w');
else
    fid = fopen(diary_file,'a+');
end

% print trial information
fprintf(fid,'Trial:\t %s \n',name);
% print extra information if available
if ~isempty(extrainfo)
    for k = 1:length(extrainfo)
        fprintf(fid,'%s \n',extrainfo{k});
    end
end
fprintf(fid,'\n\n');

% run IK
Opensim_IK(osimModel,TrajectoryFile,IKTemplateFile,IKMotOutputFile,[],IKTemplateFile,... % variable input arguments
    'printresults',ikresults_dir);

% report mean error and standard deviations per marker
% model marker position file produced by setting
% report_marker_locations to true in the xml file
[~, name, ~]=fileparts(IKMotOutputFile);
storagedata = importdata(fullfile(ikresults_dir,[name,'_ik_model_marker_locations.sto']));
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
    error_markers_norm(:,i) = sqrt(sum(error_markers(:,[1:3]+(i-1)*3),2));
end

% print the mean difference and standard deviation
error_mean = mean(error_markers_norm,1,'omitnan');
error_std  = std(error_markers_norm,1,'omitnan');
[~,isort_error] = sort(error_mean,'descend'); % sort to largest error
%     isort_error = 1:length(error_mean);
error_mean_sort = error_mean(isort_error);
error_std_sort  = error_std(isort_error);
lab_short_sort  = lab_short(isort_error);

% conditionally print to command window
if verbose
    fprintf('mean,\t std,\t marker\n');
    for jj = 1:nmark_short_upd
        fprintf('%.4f\t %.4f\t %s\n',error_mean_sort(jj),error_std_sort(jj),lab_short_sort{jj});
    end
end

% conditionally print to file
fprintf(fid,'mean,\t std,\t marker\n');
for jj = 1:nmark_short_upd
    fprintf(fid,'%.4f\t %.4f\t %s\n',error_mean_sort(jj),error_std_sort(jj),lab_short_sort{jj});
end
fprintf(fid,'\n\n');
fclose(fid);
end

%% checking variable input list
% Function that searches variable arguments input for string pattern and
% returns value of subsequent index.
% adapted from script Prof. Dr. Andreas Daffertshofer
function val=getarg(name,default,varargin)
index=find(strcmpi(name,varargin));
if isempty(index)
    val=default;
else
    val=varargin{index+1};
end
end