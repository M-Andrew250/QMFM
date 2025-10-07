function [nr, nc] = calcSubplotSize(n)
% codes.utils.calcSubplotSize calculates the number of rows and columns of a subplot grid to accomodate a given numebr of charts.
%
% Usage: [nr, nc] = code.utils.calcSubplotSize(n)
% 
% Iputs:
% - n: the number of subplots
%
% Outputs:
% - nr: number of rows
% - nc: number of columns

nr = ceil(sqrt(n));
if nr * (nr - 1) >= n
  nc = nr - 1;
else
  nc = nr;
end

end