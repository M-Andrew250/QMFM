function saveResult(opts, fileName, varargin)

fullFileName = fullfile(opts.resultsDirMat, fileName + ".mat");
evalString = "save '" + fullFileName + "' " + join(string(varargin), " ");
evalin("caller", evalString);

end