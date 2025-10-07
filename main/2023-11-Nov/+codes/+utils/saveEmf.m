function saveEMF(opts, fHandle, fileName)

fullFileName = fullfile(opts.resultsDirEmf, fileName + ".emf");
exportgraphics(fHandle, fullFileName);

end