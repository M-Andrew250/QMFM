function plotPriors(priors, m)

paramNames = string(fieldnames(priors));
numParams = numel(paramNames);

[nunRows, numCols] = codes.utils.calcSubplotSize(numParams);

figure();
c = 0;
for pn = paramNames(:)'

  pr = priors.(pn);
  
  bounds = [pr.Mean-6*pr.Std, pr.Mean+6*pr.Std];
  bounds(1) = max(bounds(1), pr.Domain(1));
  bounds(2) = min(bounds(2), pr.Domain(2));

  x = linspace(bounds(1), bounds(2), 100);
  
  c = c + 1;
  subplot(nunRows, numCols, c);
  
  plot(x, pr.pdf(x));
  title("Prior for " + pn, "interpreter", "none");
  xline(m.(pn));
  grid on

end

end