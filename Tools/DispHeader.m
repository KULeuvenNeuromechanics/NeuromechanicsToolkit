function [] = DispHeader(header)
%DispHeader Prints a cell array with strings to screen. Typically used to
% print a header.
%   Input arguments:
%       (1) header: cell array with header information (chars of strings)
for i=1:length(header)
    disp([num2str(i) ' - ' header{i}]);
end

