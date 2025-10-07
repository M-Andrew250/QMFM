function res = loadResult(opts, what)
% codes.utils.loadResult loads the required results from the results folder stored in opts.
%
% Usage: codes.utils.loadResult(opts, what)
%
% Inputs:
% - opts:   options as returned by mainSettings()
% - what:   the result to be loaded. Can be the name of any MAT file created
%           by the main codes.
%
% Example: codes.utils.loadResults(opts, "filter") will load the file
% opts.resultsDirMat/filter.mat
%
% See also: codes.utils.saveResult, codes.utils.saveReport,
% codes.utils.saveCsv, codes.utils.saveEmf

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