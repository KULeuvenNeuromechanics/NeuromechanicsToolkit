function [] = OpenFolder(varargin)
%OpenFolder Opens specific folder in explorer. Opens current folder in
%matlab when used without input arguments
%   Input arguments:
%       (1) varargin:
%           (1.1) Path to folder

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

