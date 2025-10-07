function readModel(paramFiles)

% -------- Setup --------

opts = mainSettings();

cln = onCleanup(@(x) cleanupFun(opts));

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

modelDir = fullfile(opts.mainDir, "model");

% -------- Set parameters -------

cd(modelDir)
for i = 1 : paramNum
  
  [filePath, fileName] = fileparts(paramFiles(i));
  if filePath ~= ""
    cd(filePath)
  end
  
  p = feval(fileName);
  m(i) = assign(m(i), p);
  m(i) = refresh(m(i));
  
  if filePath ~= ""
    cd(modelDir)
  end
  
end
cd(opts.mainDir)

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

function cleanupFun(opts)

cd(opts.mainDir)

end