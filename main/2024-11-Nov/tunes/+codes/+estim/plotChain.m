function plotChain(specEstim, chain, accRat, logPost)

paramNames  = string(fieldnames(specEstim));
numParams   = length(paramNames);

[r, c] = codes.utils.calcSubplotSize(numParams);
r = r + 1;

figure();

subplot(r, c, 1)
plot(accRat)
grid on
title("Acceptance ratio")

subplot(r, c, 2)
plot(logPost)
grid on
title("Log of the posterior density at the simulated values")

for i = 1 : numParams

  subplot(r, c, c+i)
  plot(chain(i,:))
  grid on
  title("Simulated values for " + paramNames(i), "interpreter", "none")

end

end