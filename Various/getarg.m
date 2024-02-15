% --------------------------------------------------------------------------
% getarg 
% Get varariable arguments based on preceeding string argument
%
% INPUT:
%   name
%       string argument indicating the variable to change.
%  
%   default
%       default when name is not in varargin
% 
%   varargin
%       vararging
% OUTPUT:
%   val
%       value related to argument (Either the default value or a value 
%       specified in varargin)
%
%   function adapted from script Prof. Dr. Andreas Daffertshofer
% --------------------------------------------------------------------------
function val=getarg(name,default,varargin)
    index=find(strcmpi(name,varargin));
    if isempty(index)
        val=default;
    else
        val=varargin{index+1};
    end
end