function [nr, nc] = calcSubplotSize(n)

nr = ceil(sqrt(n));
if nr * (nr - 1) >= n
  nc = nr - 1;
else
  nc = nr;
end

end