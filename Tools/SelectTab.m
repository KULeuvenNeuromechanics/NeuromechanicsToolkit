function [h] = SelectTab()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
h = gcf;
Pos = get(h,'Position');
ax = h.Children.SelectedTab.Children;
copyobj(ax,figure())
h = gcf;
set(h,'Position',Pos);
end

