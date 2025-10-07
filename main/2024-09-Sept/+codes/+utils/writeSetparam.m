function writeSetparam(opts, fileName, m)

% opts is mainsetting(round), fileNamem is estimated model

fullFileName = fullfile(opts.mainDir, "model", fileName + ".m");

fid = fopen(fullFileName, "w");

fprintf(fid, "%s\n", "function p = " + fileName + "()");

params = get(m, "parameters");
paramNames = string(fieldnames(params));

for pn = paramNames(:)'
  fprintf(fid, "\np.%s = %0.8g;", pn, params.(pn));
end

fprintf(fid, "\n\n%s", "end");

fclose(fid);

end