function saveCsv(opts, fileName, db)
% codes.utils.saveCsv saves the content of a database as a CSV file.
%
% Usage: codes.utils.saveCsv(opts, fileName, db)
%
% Inputs:
% - opts:       options as returned by mainSettings()
% - fileName:   the name of the CSV file (without the extension)
% - db:         the database to be written to the CSV file
%
% Example: codes.utils.saveCsv(opts, "forecast", dbFcast) will save the
% forecast database in the file opts.resultsDirCsv/forecast.csv
%
% See also: codes.utils.saveResult, codes.utils.saveReport,
% codes.utils.saveEmf, codes.utils.loadResult

fullFileName = fullfile(opts.resultsDirCsv, fileName + ".csv");

if codes.utils.checkFile(fullFileName)
  databank.toCSV(db, fullFileName, 'Class', false, 'NaN', '', 'Format', '%.16f');
end

end