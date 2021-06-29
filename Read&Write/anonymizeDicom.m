function anonymizeDicom(inputPath,outputPath,subjectname)
% --------------------------------------------------------------------------
%anonymizeDicom 
%   anonimizeDicom anonimizes dicom images (mri). It removes all meta-data
%   with exception of some image settings. An anonimized patientID can be
%   added.
%   Before you use the script, please check which fields contain sensitive
%   information and which fields you want to keep. This might be different
%   per center/device/settings etc.
% 
% INPUT:
%   - inputPath -
%   * character string of the inputPath (folder with IM_ files)
%  
%   - outputPath -
%   * character string of the path where you want to save the anonymized
%   files
%
%   - subjectname -
%   * character string with the name you want to give to your subject
%
% OUTPUT:
%   This function has no outputs.
% 
% Original author: Marije Goudriaan
% Original date: 05/05/2017
%
% Last edit by: Bram Van Den Bosch
% Last edit date: 29/06/2021
% --------------------------------------------------------------------------

%% Input
files = dir(inputPath);

for i = 1:size(files);
    % only anonymize and copy 'IM_' files
    if size(files(i).name,2)>4 && strcmp(files(i).name(1:3),'IM_')  
        file = files(i).name;
        FullFileName = fullfile(inputPath,file);
        
        % Anonimize all dicom files.
        newfile = fullfile(outputPath, file);
        dicomanon(FullFileName, newfile);
        
        % Convert dates from yyyymmdd to yyyymm and remove all names that
        % were not removed in Matlab anonimization function. 
        info = dicominfo(newfile);
        INFO = fieldnames(info);
        
        info.InstanceCreationDate = info.InstanceCreationDate(1:6);
        info.StudyDate = info.StudyDate(1:6);
        info.SeriesDate = info.SeriesDate(1:6);
        
        if length(info.(INFO{26})) == 8;
            info.AcquisitionDate = info.AcquisitionDate(1:6);
        end
        
        info.ContentDate = info.ContentDate(1:6);
        info.PatientID = subjectname;
        info.ReferringPhysicianName = '';
        info.RequestingPhysician = '';
        info.PerformingPhysicianName = '';
        info.ScheduledPerformingPhysicianName = '';
        info.PerformedProcedureStepStartDate = info.PerformedProcedureStepStartDate(1:6);
        info.PerformedProcedureStepEndDate = info.PerformedProcedureStepEndDate(1:6);
        info.IssueDateOfImagingServiceRequest = info.IssueDateOfImagingServiceRequest(1:6);

        % Replace original metadata with anonimized metadata specified
        % above.
        I = dicomread(info);
        dicomwrite(I, newfile, info, 'CreateMode', 'copy');        
    end
end
end

