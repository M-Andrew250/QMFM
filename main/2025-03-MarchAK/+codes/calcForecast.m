function calcForecast(scenarios)
% codes.calcForecast() calculates the forecast for all forecast scenarios.
%
% Usage: codes.calcForecast()
% 
% codes.calcForecast loads the model object, the filtered data, the
% auxiliary database, and calculates the forecast for all scenarios listed
% in otps.forecast.scenarioNames. The forecast is calcualted using the
% 'simulate' methods of IRIS models.
% For each scenario, the scenario assumptions are defined in
% tunes/<scenarioName>.m. The assumptions include soft and hard tunes, the
% corresponding simulation plan, and possible modifications of the model.
% The default forecast model uses the first parametrization in
% opts.parameterNames.
% The reporting equations, i.e. the auxiliary model, are also evaluated.
% Equation decompositions are calculated over the forecast horizon, and the
% results are combined with the historical decompositions.
%
% Relevant options are:
% - opts.forecast.scenarioNames:  names of the scenarios, also the names of the
%                                 scenario assumptions files in tunes/
% - opts.forecast.range:          the simulation range
%
% Results are saved in opts.resultsDirMat/forecast.m. The save results are
% as follows:
% - m:            the scenario specific model object, with as many (not
%                 necessarily different) parametrizations as there are
%                 scenarios
% - pln:          a cell array of the simulation plans for each scenario
% - dbTunes:      a cell array of databases of the soft and hard tunes for
%                 each scenario
% - dbInit:       the initial conditions for each scenario; the i-th columns
%                 correspond to the i-th scenario
% - dbFcast:      the database of forecasts; the i-th columns
%                 correspond to the i-th scenario
% - dbEqDecomp:   the database of equations decompositions, combined over
%                 the filter and forecast ranges
%
% See also: codes.filterHistory, codes.reportForecast,
% codes.reportForecastChangeDecomp

% -------- Setup --------

opts    = mainSettings();
optsF   = opts.forecast;
optsFH  = opts.filterHistory;

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

tmp           = codes.utils.loadResult(opts, "filter");
dbFilt        = dbcol(tmp.dbFilt.mean, 1);
dbDecompFilt  = tmp.dbEqDecomp;
dbAux         = dbcol(tmp.dbAux, 1);

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

  % Evaluate to the tune function (from mainDir)
  tuneFuncName = scenarios(i);
  [dbTunesi, plni, mi] = opts.tunes.(tuneFuncName)(opts, M);
  dbInit = dboverlay(dbFilt, dbTunesi);
  
  % ----- Solve the (possibly modified) forecast model -----
  
  mi = steady(mi, ...
    "solver", {'IRIS-Qnsd', 'display', 'none'});
  mi = solve(mi);
  chksstate(mi);
  
  % ----- Simulate the model -----
  
  codes.utils.writeMessage(mfilename ...
    + ": scenario " + scenarios(i) + ": calculating forecast ..." ...
    );
  
  dbFcasti = simulate(mi, dbInit, optsF.range, 'Plan', plni, ...
    "prependInput", true, ...
    "method", "stacked", ...
    "solver", {'IRIS-Qnsd', 'display', 'none'});

  % ----- Calculate shock decompolsitions -----

  dbShockDecompi = simulate(mi, dbFcasti, optsF.shockDecompRange, ...
    "Contributions", true, "Anticipate", false);
  
  % Create groups for shock decomposition
  g = grouping(mi, 'Shocks');
  groupNames = fieldnames(optsFH.shockDecompGroups);
  for gn = groupNames(1:end-1)'
    g = addgroup(g, gn{:}, cellstr(optsFH.shockDecompGroups.(gn{:})));
  end
  dbShockDecompi = eval(g, dbShockDecompi);
  
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

  dbShockDecomp(i) = dbShockDecompi; %#ok<NASGU> 
  
end

% ----- Save results to mat file -----

codes.utils.saveResult(opts, "forecast", "m", "pln", ...
  "dbTunes", "dbInit", "dbFcast", "dbEqDecomp", "dbShockDecomp")
codes.utils.writeMessage(mfilename + ": done.");

end
