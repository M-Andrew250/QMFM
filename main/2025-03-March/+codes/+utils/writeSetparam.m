function writeSetparam(opts, fileName, m, chainStats)
% codes.utils.writeSetparam creates a function in the model folder returning the parameter values in a model object.
%
% Usage: codes.utils.writeSetparam(opts, fileName, m)
%
% Inputs:
% - opts:       options as returned by mainSettings()
% - fileName:   the name of the M file (without the extension)
% - m:          the model object from where the parameter names and values
%               will be taken.
%
% Example: codes.utils.writeSetparam(opts, "setparam", m) will create the
% file opts.modelDir/setparam.m. Subsequently, the function p = setparam()
% will return the model parameters in the database p.
%
% See also: codes.readModel

params = get(m, "parameters");

if 3 < nargin
  for pn = string(fieldnames(chainStats))'
    params.(pn) = chainStats.(pn);
  end
end

fullFileName  = fullfile(opts.mainDir, "model", fileName + ".m");
fid           = fopen(fullFileName, "w");

fprintf(fid, "%s\n", "function p = " + fileName + "()");

paramNames = string(fieldnames(params));
for pn = paramNames(:)'
  fprintf(fid, "\np.%s = %0.8g;", pn, params.(pn));
end

fprintf(fid, "\n\n%s", "end");

fclose(fid);

end