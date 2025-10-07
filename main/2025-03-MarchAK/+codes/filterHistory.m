function filterHistory
% codes.filterHistory() estimated unobserved variables for all model parametriztations, using the Kalman smoother.
%
% Usage: codes.filterHistory()
% 
% codes.filterHistory loads the observed data in dbObs, loads the model
% object, applies the filter tunes as set in tunes/Historical.m, runs the
% Kalman filter for all parametrizations, and calculates equation and shock
% decompositions.
%
% Relevant settings are:
% - opts.filter.range:        the filtration range
% - opts.shockDecomp.Groups:  the grouping of the shocks used in the shock
%                             decompositions
%
% Results are saved in opts.resultsDirMat/filter.mat. The saved databases
% are the following:
% - dbFilt:         the result of the Kalman filter (or more precisely, the Kalman
%                   smoother). Measurement variables are copied from the
%                   observed database, so that there are no 'artificial'
%                   estimated observations.
% - dbObs:          observed data, combined with the filter tunes
% - dbShockDecomp:  shock decomposition database
% - dbEqDecomp:     equations decomposition database; the decompositions
%                   are defined in codes.reporting.calcDecompositions
% - dbAux:          pct_ and pct4_ variables are calculated here, to make sure
%                   they exist even when history is missing
% 
% See also: codes.reporting.calcDecompositions, codes.reportFilter,
% codes.readModel, codes.calcForecast


% ------- Setup --------

opts = mainSettings();

optsFH = opts.filterHistory;

% ----- Load model -----

codes.utils.writeMessage(mfilename + ": loading model ...");

tmp = codes.utils.loadResult(opts, "model");
m = tmp.m;

% ----- Load observed data -----

codes.utils.writeMessage(mfilename + ": loading data ...");

tmp = codes.utils.loadResult(opts, "data");
dbObs = tmp.dbObs;
dbAux = tmp.dbAux;

% -------- Run the filter --------

% ----- Set tunes -----

codes.utils.writeMessage(mfilename + ": setting historical tunes ...");

% Predefine historical tune-s
ynames  = string(get(m, "ynames"));
ind     = startsWith(ynames, "tune_");
tnames  = ynames(ind);
for i = 1:length(tnames)
  dbObs.(tnames{i}) = Series();
end

% Evaluate to the tune function (from mainDir)
dbObs = opts.tunes.Historical(dbObs);

% ----- Run smoother, "relative" false means no multiplier is estimated -----

codes.utils.writeMessage(mfilename + ": running filtration ...");
[~, dbFilt] = filter(m, dbObs, optsFH.range, "relative", false);

% -------- Run shock decomposition --------

codes.utils.writeMessage(mfilename + ": running shock decomposition ...");

% ----- Check if all shocks are in a group -----

groupedShocks = struct2cell(opts.filterHistory.shockDecompGroups);
groupedShocks = vertcat(groupedShocks{:});

missingShocks = setdiff(get(m, "eList"), groupedShocks);

if ~isempty(missingShocks)
  warning("The following shocks have not been assigned to a group")
  disp(missingShocks(:))
end

% ----- Simulate and group contributions -----

for i = 1 : prod(size(m)) %#ok<PSIZE> % IRIS will not do the decomposition with multiple parametrizations
  
  % Simulate with the historical shocks
  dbSim = simulate(m(i), dbcol(dbFilt.mean,i), optsFH.range, ...
    "Contributions", true, "Anticipate", false);
  
  % Create groups for shock decomposition
  g = grouping(m, 'Shocks');
  groupNames = fieldnames(optsFH.shockDecompGroups);
  for gn = groupNames(1:end-1)'
    g = addgroup(g, gn{:}, cellstr(optsFH.shockDecompGroups.(gn{:})));
  end
  dbShockDecomp(i) = eval(g, dbSim); %#ok<AGROW>
  
end

% -------- Calculate equation decompositions --------

codes.utils.writeMessage(mfilename + ": calculating equation decompositions ...");
dbEqDecomp = codes.reporting.calcDecompositions(m, dbFilt.mean, optsFH.range);

% -------- Calculate pct/pct4 variables in dbAux (history might be missing) --------

% Ideally, this list should be defined in main settings, e.g. opts.filter.pctVariables

varNames = [
  "y"
  "cons"
  "inv"
  "gdem"
  "exp"
  "imp"
  "cpi"
  "cpi_core"
  "cpi_food"
  "cpi_ener"
  "s"
  "z"
  ];

for n = varNames(:)'
  dbAux.("pct_"  + n)  = 100*exp(dbFilt.mean.("dl_"  + n)/100) - 100;
  dbAux.("pct4_" + n)  = 100*exp(dbFilt.mean.("d4l_" + n)/100) - 100;
end

dbAux.tb_rat = 100*(exp(dbFilt.mean.l_exp/100) - exp(dbFilt.mean.l_imp/100))/exp(dbFilt.mean.l_y/100); 
% AK Mar29 2025 recalc res.bal. (cf. Aux. in ReadData) from filter results for missing data E, M

dbAux.pct_i = 100 * (exp(dbFilt.mean.i/100) - 1);

% -------- Save results --------

codes.utils.writeMessage(mfilename + ": saving results ...");
codes.utils.saveResult(opts, "filter", "dbObs", "dbFilt", "dbShockDecomp", "dbEqDecomp", "dbAux")
codes.utils.writeMessage(mfilename + ": done.");

end
