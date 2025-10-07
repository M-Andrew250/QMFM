function saveResult(opts, fileName, varargin)
% codes.utils.saveResult saves the listed MATLAB variables in a MAT file.
%
% Usage: codes.utils.saveResult(opts, fileName, varargin)
%
% Inputs:
% - opts:       options as returned by mainSettings()
% - fileName:   the name of the MAT file (without the extension)
% - varargin:   a comma separated list of the MATLAB variables to be saved.
%
% Example: codes.utils.saveResult(opts, "data", db1, db2) will save the
% variables db1 and db2 in opts.resultsDirMat/data.mat
%
% See also: codes.utils.saveCsv, codes.utils.saveReport,
% codes.utils.saveEmf, codes.utils.loadResult

fullFileName = fullfile(opts.resultsDirMat, fileName + ".mat");
evalString = "save '" + fullFileName + "' " + join(string(varargin), " ");
evalin("caller", evalString);

end