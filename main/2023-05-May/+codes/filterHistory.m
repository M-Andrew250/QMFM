function filterHistory

% ------- Setup --------

opts = mainSettings();

optsFH = opts.filterHistory;

cln = onCleanup(@(x) cleanupFun(opts));

% ----- Load model -----

codes.writeMessage("filterHistory: loading model ...");

tmp = codes.loadResult(opts, "model");
m = tmp.m;

% ----- Load observed data -----

codes.writeMessage("filterHistory: loading data ...");

tmp = codes.loadResult(opts, "data");
dbObs = tmp.dbObs;

% -------- Run the filter --------

% ----- Set tunes -----

codes.writeMessage("filterHistory: setting historical tunes ...");

% Predefine historical tune-s
ynames  = string(get(m, "ynames"));
ind     = startsWith(ynames, "tune_");
tnames  = ynames(ind);
for i = 1:length(tnames)
  dbObs.(tnames{i}) = Series();
end

% Set historical tunes
cd(fullfile(opts.mainDir, "tunes"))
dbObs = Historical(dbObs);
cd(opts.mainDir)

% ----- Run smoother, "relative" false means no multiplier -----

codes.writeMessage("filterHistory: running filtration ...");
[~, dbFilt] = filter(m, dbObs, optsFH.range, "relative", false);

% -------- Run shock decomposition --------

codes.writeMessage("filterHistory: running shock decomposition ...");

% ----- Check if all shocks are in a group -----

groupedShocks = struct2cell(opts.filterHistory.shockDecompGroups);
groupedShocks = vertcat(groupedShocks{:});

missingShocks = setdiff(get(m, "eList"), groupedShocks);

if ~isempty(missingShocks)
  warning("The following shocks have not been assigned to a group")
  disp(missingShocks(:))
end

% ----- Simulate and group contributions -----

for i = 1:prod(size(m)) %#ok<PSIZE> % IRIS will not do the decomposition with multiple parametrizations
  
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

codes.writeMessage("filterHistory: calculating equation decompositions ...");
dbEqDecomp = codes.reporting.calcDecompositions(m, dbFilt.mean, optsFH.range);

% -------- Save results --------

codes.writeMessage("filterHistory: saving results ...");

fileName = fullfile(opts.mainDir, "results", "filter.mat");
save(fileName, "dbObs", "dbFilt", "dbShockDecomp", "dbEqDecomp")

codes.writeMessage("filterHistory: done.");

end

function cleanupFun(opts)

cd(opts.mainDir)

end