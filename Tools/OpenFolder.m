function [] = OpenFolder(varargin)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

if ~isempty(varargin);
    startpath=pwd;
    FolderPath=varargin{1};
    cd(FolderPath);
    system('start.');
    cd(startpath);
else
    system('start.');
end
    

end

