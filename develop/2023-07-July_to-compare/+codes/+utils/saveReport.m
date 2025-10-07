function saveReport(opts, fileName, rprt)

fullFileName = fullfile(opts.resultsDirPdf, fileName + ".pdf");

% Check if the file can be overwritten (i.e. not open in a pdf reader)
if codes.utils.checkFile(fullFileName)
  rprt.publish(char(fullFileName), opts.publishOptions{:});
end

% Close invisible figure windows
codes.utils.closeFigures();

end