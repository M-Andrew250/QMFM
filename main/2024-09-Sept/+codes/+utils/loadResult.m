function res = loadResult(opts, what)

evalString = "load('" + fullfile(opts.resultsDirMat, what + ".mat") + "')";
tmp = eval(evalString);

if nargout == 0

  fn = string(fieldnames(tmp));
  for n = fn(:)'
    assignin("caller", n, tmp.(n));
  end

else

  res = tmp;

end

end