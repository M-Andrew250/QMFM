function readModel(paramFiles)
% codes.readModel() creates the model object containing all parametrizations.
%
% Usage: codes.readModel()
% 
% codes.readModel reads the model equations, applies the parameter values
% from the files specified in, calculates the steady states and the first order
% model solutions for all parametriztions.
%
% Relevant settings are:
% - opts.modelFile:       name of the model file in model/, from where the model
%                         equations will be read
% - opts.parameterNames:  names of the parametrizaation files in model/
%
% Results are saved in opts.resultsDirMat/model.mat:
% - m: solved model object (with possibly multiple parametrizations)
%
% See also: codes.reportModel, codes.filterHistory, codes.calcForecast.

% -------- Setup --------

opts = mainSettings();

if nargin < 1
  paramFiles = opts.parameterNames;
end

% ------- Reading the model file --------

codes.utils.writeMessage(mfilename + ": reading model file ...");

paramNum = numel(paramFiles);

m = Model.fromFile(opts.modelFile, ...
  "Linear", false, ...
  "Growth", true ...
  );
m = alter(m, paramNum); 

% -------- Set parameters -------

c = 0;
for pn = opts.parameterNames(:)'
  p = opts.parameters.(pn)();
  c = c + 1;
  m(c) = assign(m(c), p);
  m(c) = refresh(m(c));
end

% -------- Calculate steady state and resolve expectations -------

codes.utils.writeMessage(mfilename + ": solving the model ...");

m = steady(m, ...
  "solver", {'IRIS-Qnsd', 'display', 'none'});
checkSteady(m);
m = solve(m);

% -------- Save results -------

codes.utils.writeMessage(mfilename + ": saving results ...");
codes.utils.saveResult(opts, "model", "m");
codes.utils.writeMessage(mfilename + ": done.");

end
