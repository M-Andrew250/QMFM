function yList = selectFromList(xList, xListAll, yListAll)

yList = xList;

for i = 1 : length(xList)
  
  ind = xListAll == xList(i);
  yList(i) = yListAll(ind);
  
end

end