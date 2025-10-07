function reportHistory
% codes.reportHistory() creates a report of the Kalman filter results for all model parametrizations.
%
% Usage: codes.reportHistory()
%
% codes.reportFilter loads the model, the observed and filtered data, and
% creates a PDF report depicting selected results of the Kalman filter.
% The charts can show the following:
% - charts of the observed data used by the filter
% - charts of estimated trends and gaps
% - charts and tables of decompositions of equations
% - charts of shock decompositions
% - charts and table of estimated shocks
%
% Relevant options are:
% - opts.filter.plotRange:    the range of the charts (except ther shocks,
%                             which will be plotted in the whole filtration
%                             range)
% - opts.filter.tableRange:   range of the tables
% - opts.trendGapVars:        the variables in the trend/gap charts. The
%                             value of this options is a two-dimensional
%                             string array with three columns. The first
%                             column is the name of the variable to be
%                             decomposed, the second is the name of the
%                             trend, the third is the name of the gap. The
%                             second and the third columns can be empty.
% - opts.eqDecompVars:        the variables in the equations decomposition
%                             charts
% - opts.shockDecomp.Vars:    the variables in the shock decomposition
%                             charts
% - opts.shockDecomp.Groups:  the grouping of the shocks used in the shock
%                             decompositions
%
% The PDF report is saved as opts.resultsDirPdf/filterReport.pdf
%
% See also: codes.fitlerHistory, codes.readModel, codes.reportModel

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
  
  rprt = codes.reporting.addShockDecompositions(opts, rprt, m, db, dbShockDecomp, optsFH.rangePlot, legends, "history");
  
end

% Shocks

if optsRH.shocks.run
  
  codes.utils.writeMessage(mfilename + ": adding shocks to the history report ...");
  
  rprt = codes.reporting.addShocks(opts, rprt, m, db, optsFH.range, legends, "history");

  shockNames = string(get(m, "eList"))';
  varNames = [shockNames, shockNames];

  tableTitle = "Shocks";

  rprt = codes.reporting.addTablePage(opts, rprt, m, db, varNames, tableTitle, legends);
  
end

% Publish report

codes.utils.writeMessage(mfilename + ": compiling the history report ...");
codes.utils.saveReport(opts, "historyReport", rprt)
codes.utils.writeMessage(mfilename + ": done");

end
