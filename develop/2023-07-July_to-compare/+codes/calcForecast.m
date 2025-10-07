function calcForecast(scenarios)

% -------- Setup --------

opts    = mainSettings();
optsF   = opts.forecast;
optsRF  = opts.forecastReport;

cln = onCleanup(@(x) cleanupFun(opts));

if nargin < 1
  scenarios = optsF.scenarioNames;
end

scenNum = length(scenarios);

% -------- Load previous results --------

codes.utils.writeMessage(mfilename + ": loading model and data");

% ----- Load model -----

tmp = codes.utils.loadResult(opts, "model");
M   = tmp.m(1);

% ----- Load filtered data -----

tmp       = codes.utils.loadResult(opts, "filter");
dbFilt    = dbcol(tmp.dbFilt.mean,1);
dbDecompFilt  = tmp.dbEqDecomp;

% ----- Load auxiliary data -----

tmp     = codes.utils.loadResult(opts, "data");
dbAux   = tmp.dbAux;

% -------- Initialize the equations decompositions --------

varNames = string(fieldnames(dbDecompFilt));
for v = varNames(:)'
  dbEqDecomp.(v).figureName     = dbDecompFilt.(v).figureName;
  dbEqDecomp.(v).legendEntries  = dbDecompFilt.(v).legendEntries;
  dbEqDecomp.(v).colorMap       = dbDecompFilt.(v).colorMap;
end

% -------- Calculate forecast for all scenarios --------

for i = 1 : scenNum
  
  codes.utils.writeMessage(mfilename ...
    + ": scenario " + scenarios(i) + ": setting tunes ..." ...
    );
  
  % ----- Set tunes and simulation plan -----
  
  % Create the handle to the tune function
  tuneFuncName = scenarios(i);
  cd(fullfile(opts.mainDir, "tunes"))
  tuneFunc = str2func("@" + tuneFuncName);
  cd(fullfile(opts.mainDir))

  % Evaluate to the tune function (from mainDir)
  [dbTunesi, plni, mi] = tuneFunc(opts, M);
  dbInit = dboverlay(dbFilt, dbTunesi);
  cd(opts.mainDir)
  
  % ----- Solve the (possibly modified) forecast model -----
  
  mi = sstate(mi, ...
    "solver", {'IRIS-Qnsd', 'display', 'none'});
  mi = solve(mi);
  chksstate(mi);
  
  % ----- Simulate the model -----
  
  codes.utils.writeMessage(mfilename ...
    + ": scenario " + scenarios(i) + ": calculating forecast ..." ...
    );
  
  dbFcasti = simulate(mi, dbInit, optsF.range, 'Plan', plni, ...
    "prependInput", true, ...
    "method", "firstOrder");
  
  % ----- Calculate equations decompositions, combine with the filter -----
  
  dbDecompi = codes.reporting.calcDecompositions(mi, dbFcasti, optsF.range);
  
  % ----- Evaluate the auxiliary model (in reporting equations) -----
  
  dbFcasti = dbmerge(dbFcasti, dbAux);
  dbFcasti = reporting(mi, dbFcasti, optsF.range, ...
    'AppendPresample', true);

  % ----- Save results to csv file -----
  
  codes.utils.writeMessage(mfilename ...
    + ": scenario " + scenarios(i) + ": writing results to CSV ..." ...
    );

  fileName = "forecast" + scenarios(i);
  codes.utils.saveCsv(opts, fileName, dbFcasti);
  
  % ----- Combine results for the scenarios -----
  
  if i == 1
    
    m         = mi;
    dbFcast   = dbFcasti;
    dbTunes   = {dbTunesi};
    pln       = {plni};
    
  else
    
    m         = [m, mi];
    dbFcast   = dbFcast & dbFcasti;
    dbTunes   = [dbTunes, {dbTunesi}];
    pln       = [pln, {plni}];
    
  end
  
  varNames = string(fieldnames(dbDecompFilt));
  for v = varNames(:)'
    dbEqDecomp.(v).decompSeries{i}    = [dbDecompFilt.(v).decompSeries{1}; dbDecompi.(v).decompSeries{1}];
    dbEqDecomp.(v).decompContribs{i}  = [dbDecompFilt.(v).decompContribs{1}; dbDecompi.(v).decompContribs{1}];
  end
  
end

% ----- Save results to mat file -----

codes.utils.saveResult(opts, "forecast", "m", "pln", "dbTunes", "dbInit", "dbFcast", "dbEqDecomp")
codes.utils.writeMessage(mfilename + ": done.");

end

function cleanupFun(opts)

cd(opts.mainDir)

end
