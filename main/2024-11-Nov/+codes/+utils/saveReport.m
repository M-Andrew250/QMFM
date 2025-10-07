function saveReport(opts, fileName, rprt)
% codes.utils.saveReport saves an IRIS report object in a PDF file.
%
% Usage: codes.utils.saveReport(opts, fileName, rprt)
%
% Inputs:
% - opts:       options as returned by mainSettings()
% - fileName:   the name of the MAT file (without the extension)
% - rprt:       the IRIS report object to be published.
%
% Example: codes.utils.saveReport(opts, "report", rprt) will save the
% report rprt in opts.resultsDirPdf/report.pdf.
%
% See also: codes.utils.saveCsv, codes.utils.saveResult,
% codes.utils.saveEmf, codes.utils.loadResult

fullFileName = fullfile(opts.resultsDirPdf, fileName + ".pdf");

% Check if the file can be overwritten (i.e. not open in a pdf reader)
if codes.utils.checkFile(fullFileName)
  rprt.publish(char(fullFileName), opts.publishOptions{:});
end

% Close invisible figure windows
codes.utils.closeFigures();

end