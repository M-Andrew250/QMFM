function readModel(paramFiles)

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

% -------- Calculate steady state and resovle expectations -------

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
