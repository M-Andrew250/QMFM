function plotLLH(post)

N = 100;

numParams = length(post.ParameterNames);
rn = ceil(sqrt(numParams));

c = 0;
for pn = post.ParameterNames
  c = c + 1;
  params.(pn) = post.InitParam(c);
end

figure();

c = 0;
for pn = post.ParameterNames

  c = c + 1;

  x = linspace(post.Lower(c), post.Upper(c), N);
  y = nan(size(x));

  for i = 1 : N
    params.(pn) = x(i);
    y(i) = eval(post, params);
  end
  params.(pn) = post.InitParam(c);

  subplot(rn, rn, c)
  plot(x, y, '.-')
  xline(post.InitParam(c))
  grid on
  title("LLH of " + pn, "interpreter", "none")

end

end