function plotPriorPosterior(specEstim, chain, nbins)

chainLength = size(chain, 2);
if nargin < 3 || isempty(nbins)
  stdChain  = std(chain, [], 2);
  wbins     = 3.5 * stdChain * chainLength^(-1/3); % Scott's rule, see https://en.wikipedia.org/wiki/Scott%27s_rule
else
  maxChain  = max(chain, [], 2);
  minChain  = min(chain, [], 2);
  nbins     = nbins(:);
  wbins     = (maxChain - minChain) ./ nbins;
end

paramNames  = string(fieldnames(specEstim));
numParams   = length(paramNames);

[r, c] = codes.utils.calcSubplotSize(numParams);

figure();

for i = 1 : numParams
  
  subplot(r, c, i)

  pn = paramNames(i);
  spi = specEstim.(pn);

  lb  = spi{2};
  ub  = spi{3};

  if length(spi) < 4 || isempty(spi{4})
    pr  = distribution.Uniform.fromLowerUpper(lb, ub);
  else
    pr  = spi{4};
  end
  
  x = linspace(lb, ub, 100);
  y = pr.pdf(x);

  plot(x, y, "lineWidth", 1.5);
  hold on
  histogram(chain(i, :), "binWidth", wbins(i), "normalization", "pdf")

  grid on
  title("Prior PDF and post. hist. for " + paramNames(i), "interpreter", "none")

  xlim([lb, ub])
  yl = get(gca, "ylim");
  ylim([0, yl(2)])

end

end