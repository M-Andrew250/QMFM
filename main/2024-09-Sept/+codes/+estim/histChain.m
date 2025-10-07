function histChain(chain, m, priors)

paramNames = string(fieldnames(chain));
numParams = numel(paramNames);

[numRows, numCols] = codes.utils.calcSubplotSize(numParams);

figure();
c = 0;
for pn = paramNames(:)'
  
  c = c + 1;
  subplot(numRows, numCols, c);

  histogram(chain.(pn), "normalization", "pdf", "displayName", "Post. hist.");
  grid on

  xline(m.(pn), "lineWidth", 2, "displayName", "Model value");

  xl = get(gca, "xlim");
  x = linspace(xl(1), xl(2), 100);
  y = priors.(pn).pdf(x);
  hold on
  plot(x, y, "lineWidth", 2, "displayName", "Prior density")

  legend();
  title("Post. hist. for " + pn, "interpreter", "none")

end

end