function plotLLH(post, N, scale)

if nargin < 2
  N = 100;
end

if nargin < 3
  scale = 1;
end

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

  mid = post.InitParam(c);
  lb  = post.Lower(c);
  ub  = post.Upper(c);

  lb = mid + scale*(lb - mid);
  ub = mid + scale*(ub - mid);

  x = linspace(lb, ub, N);

  y = nan(N, 1);
  for i = 1 : N
    params.(pn) = x(i);
    y(i) = eval(post, params);
  end
  params.(pn) = post.InitParam(c);

  subplot(rn, rn, c)
  plot(x, y, '.-')
  xline(post.InitParam(c))
  grid on

end

end