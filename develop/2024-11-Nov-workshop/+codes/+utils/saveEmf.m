function saveEMF(opts, fHandle, fileName)
% codes.utils.saveEmf saves a figure in an EMF file.
%
% Usage: codes.utils.saveEmf(opts, fileName, fHandle)
%
% Inputs:
% - opts:       options as returned by mainSettings()
% - fileName:   the name of the EMF file (without the extension)
% - fHandle:    handle to the figure to be saved.
%
% See also: codes.utils.saveResult, codes.utils.saveReport,
% codes.utils.saveEmf, codes.utils.loadResult

fullFileName = fullfile(opts.resultsDirEmf, fileName + ".emf");
exportgraphics(fHandle, fullFileName);

end