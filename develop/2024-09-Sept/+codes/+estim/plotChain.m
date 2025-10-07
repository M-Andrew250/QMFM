function plotChain(chain)

paramNames = string(fieldnames(chain));
numParams = numel(paramNames);

[numRows, numCols] = codes.utils.calcSubplotSize(numParams);

figure();
c = 0;
for pn = paramNames(:)'
  
  c = c + 1;
  subplot(numRows, numCols, c);
  
  x = chain.(pn);
  plot(chain.(pn));
  grid on
  title("Simulated values for " + pn, "interpreter", "none");
  yline(mean(x));

end

end