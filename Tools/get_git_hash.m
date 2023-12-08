function [repo_name,local_hash, branch_name, remote_hash] = get_git_hash
% --------------------------------------------------------------------------
%get_git_hash 
%   Gets the hash of the current github code used. The git hash is used to
%   identify a specific version of the code. You can find the specific
%   version's code on GitHub by pasting the hash at 'commit-hash':
%   https://github.com/User/repo_name/tree/remote_hash
% 
% INPUT: none
% 
% OUTPUT:
%   -local_hash-
%   * the full hash for the commit you are currently using
%
%   -branch_name-
%   * the branch you are currently using
%
%   -remote_hash-
%   * the full hash for the latest commit on the remote
% 
% Original author: Bram Van Den Bosch
% Original date: 28/02/2023
%
% Last edit by: Bram Van Den Bosch
% Last edit date: 08/12/2023
% --------------------------------------------------------------------------

% get hash of the local instance
command = ['git rev-parse HEAD'];
[status,local_hash] = system(command);
local_hash = regexprep(local_hash, '\n', '');

if contains(local_hash,"'git' is not recognized as an internal or external command")
    warning('Unable to get git hash. Git seems not to be installed on your machine or cannot be executed from the command line.');
elseif status ~= 0 
    warning('Unable to get git hash. It is advised to get your code through GitHub to have version control and to receive future updates.');
end

if status == 0   
    % get name of the repo
    command = ['git rev-parse --show-toplevel'];
    [~, repo_path] = system(command);
    [~,repo_name,~] = fileparts(repo_path);
    repo_name = regexprep(repo_name, '\n', '');
    
    % get name of the current branch
    command = ['git branch --show-current'];
    [~,branch_name] = system(command);
    branch_name = regexprep(branch_name, '\n', '');
    
    % get the hash of the latest commit on the remote
    command = ['git rev-parse origin/' branch_name];
    [~,remote_hash] = system(command);
    remote_hash = regexprep(remote_hash, '\n', '');
    
    % display warning, pointing to the most recent commit on the remote
    if ~strcmp(local_hash,remote_hash)
        warning(['There is a more recent version of this branch on the remote: https://github.com/USER/' repo_name '/tree/' remote_hash]);
    end
end

end