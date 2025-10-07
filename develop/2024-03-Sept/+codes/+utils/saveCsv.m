function saveCsv(opts, fileName, db)

fullFileName = fullfile(opts.resultsDirCsv, fileName + ".csv");

if codes.utils.checkFile(fullFileName)
  databank.toCSV(db, fullFileName, 'Class', false, 'NaN', '', 'Format', '%.16f');
end

end