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

% -------- Load preivous results --------

codes.writeMessage(mfilename + ": loading model and data");

% ----- Load model -----

tmp = codes.loadResult(opts, "model");
M   = tmp.m(1);

% ----- Load filtered data -----

tmp       = codes.loadResult(opts, "filter");
dbFilt    = dbcol(tmp.dbFilt.mean,1);
dbDecompFilt  = tmp.dbEqDecomp;

% ----- Load auxiliary data -----

tmp     = codes.loadResult(opts, "data");
dbAux   = tmp.dbAux;

% -------- Initialize the equations decompositions --------

varNames = string(fieldnames(dbDecompFilt));
for v = varNames(:)'
  dbDecomp.(v).figureName     = dbDecompFilt.(v).figureName;
  dbDecomp.(v).legendEntries  = dbDecompFilt.(v).legendEntries;
  dbDecomp.(v).colorMap       = dbDecompFilt.(v).colorMap;
end

% -------- Calculate forecast for all scenarios --------

for i = 1 : scenNum
  
  codes.writeMessage(mfilename ...
    + ": scenario " + scenarios(i) + ": setting tunes ..." ...
    );
  
  % ----- Set tunes and simulation plan -----
  
  cd(fullfile(opts.mainDir, "tunes"))
  tuneFuncName  = scenarios(i);
  [dbTunesi, plni, mi]  = feval(tuneFuncName, opts, M);
  dbInit = dboverlay(dbFilt, dbTunesi);
  cd(opts.mainDir)
  
  % ----- Solve the (possibly modified) forecast model -----
  
  mi = sstate(mi, ...
    "solver", {'IRIS-Qnsd', 'display', 'none'});
  mi = solve(mi);
  chksstate(mi);
  
  % ----- Simulate the model -----
  
  codes.writeMessage(mfilename ...
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
  
  codes.writeMessage(mfilename ...
    + ": scenario " + scenarios(i) + ": writing results to CSV ..." ...
    );
  
  fileName = fullfile(opts.mainDir, "results", "forecast" + scenarios(i) + ".csv");
  if codes.checkFile(fileName)
    databank.toCSV(dbFcasti, fileName, 'Class', false, 'NaN', '', 'Format', '%.16f');
  end
  
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
    dbDecomp.(v).decompSeries{i}    = [dbDecompFilt.(v).decompSeries{1}; dbDecompi.(v).decompSeries{1}];
    dbDecomp.(v).decompContribs{i}  = [dbDecompFilt.(v).decompContribs{1}; dbDecompi.(v).decompContribs{1}];
  end
  
end

% ----- Save results to mat file -----

fileName = fullfile(opts.mainDir, "results", "forecast.mat");
save(fileName, "m", "pln", "dbTunes", "dbFcast", "dbDecomp")

codes.writeMessage(mfilename + ": done.");

end

function cleanupFun(opts)

cd(opts.mainDir)

end
