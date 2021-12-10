function [] = delete_box(varargin)
%DELETE_BOX Makes the lines around a matab plot white
%	Input arguments:
%			1. handle of the figure
%   

if ~isempty(varargin)
    fig_handle=varargin{1};
else
    fig_handle=gcf;
end

child_handles = allchild(gcf);
for i=1:length(child_handles);
    if strcmp('axes',get(child_handles(i),'type'));   
        set(child_handles(i),'box','off');
    end
end
end

