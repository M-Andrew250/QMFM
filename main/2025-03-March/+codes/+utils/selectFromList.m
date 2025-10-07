function yList = selectFromList(xList, xListAll, yListAll)
% codes.utils.selectFromList selects related elements from a list.
%
% Usage: yList = codes.utils.selectFromList(xList, xListAll, yListAll)
%
% Selects the elements from yListAll corresponding to the postion of the
% elements of xList in xListAll.

yList = xList;

for i = 1 : length(xList)
  
  ind = xListAll == xList(i);
  yList(i) = yListAll(ind);
  
end

end