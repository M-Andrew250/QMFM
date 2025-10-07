function reportHistory

% Setup

opts = mainSettings();

codes.utils.writeMessage(mfilename + ": loading model and data ...");

% Load model
tmp   = codes.utils.loadResult(opts, "model");
m     = tmp.m;

% Load observed data
tmp     = codes.utils.loadResult(opts, "data");
dbObsTrans   = tmp.dbObsTrans;

% Load filtered data
tmp             = codes.utils.loadResult(opts, "filter");
db              = tmp.dbFilt.mean;
dbShockDecomp   = tmp.dbShockDecomp;
dbEqDecomp      = tmp.dbEqDecomp;

paramNum = length(opts.parameterNames);

optsFH  = opts.filterHistory;
optsRH  = opts.reportHistory;

legends = codes.reporting.createParamLegend(opts);

% Create report
rprt = report.new('Observed and filtered data');

% Comparison of parameters

if 1 < paramNum
  
  rprt.section('Comparing parameters');
  
  rprt = codes.reporting.addParameterComparison(opts, rprt, m);
  
end

% Observed data

if optsRH.obs.run
  
  codes.utils.writeMessage(mfilename + ": adding observed data to the history report ...");
   % if plot should start later, change optsFH.range into optsFH.rangePlot
  rprt = codes.reporting.addObservedData(opts, rprt, m, dbObsTrans, optsFH.rangePlot);
  
end

% Trends & gaps

if optsRH.trends.run
  
  codes.utils.writeMessage(mfilename + ": adding trends and gaps to the history report ...");
  % if plot should start later, change optsFH.range into optsFH.rangePlot
  rprt = codes.reporting.addTrendsAndGaps(opts, rprt, m, db, dbObsTrans, optsFH.rangePlot, legends, ...
    "history");
  
end

% Decompositions of equations

if optsRH.eqDecomps.run
  
  codes.utils.writeMessage(mfilename + ": adding equation decompositions to the history report ...");
  
  rprt  = codes.reporting.addDecompCharts(opts, rprt, m, dbEqDecomp, optsFH.rangePlot, legends, "history");
  
  rprt  = codes.reporting.addDecompTables(opts, rprt, m, dbEqDecomp, optsFH.rangeTable, legends);
    
end

% Shock decompositions

if optsRH.shockDecomps.run
  
  codes.utils.writeMessage(mfilename + ": adding shock decompositions to the history report ...");
  
  rprt = codes.reporting.addShockDecompositions(opts, rprt, m, db, dbShockDecomp, optsFH.rangePlot, legends);
  
end

% Shocks

if optsRH.shocks.run
  
  codes.utils.writeMessage(mfilename + ": adding shocks to the history report ...");
  
  rprt = codes.reporting.addShocks(opts, rprt, m, db, optsFH.range, legends, "history");
  
end

% Publish report

codes.utils.writeMessage(mfilename + ": compiling the history report ...");
codes.utils.saveReport(opts, "historyReport", rprt)
codes.utils.writeMessage(mfilename + ": done");

end
