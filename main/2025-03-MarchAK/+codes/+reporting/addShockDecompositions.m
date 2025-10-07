function rprt = addShockDecompositions(opts, rprt, m, db, dbContr, range, legends, caller)
% codes.reporting.addShockDecompositions adds shock decomposition charts to a report.
%
% Usage: rprt = codes.reporting.addShockDecompositions(opts, rprt, m, db, dbContr, range, legends)
%
% Inputs:
% - opts:     options as returned by mainSettings()
% - rprt:     the report to which the tables will be added
% - m:        the model object from which the parameter values are taken
% - db:       the database of model variables (i.e. dbFilt)
% - dbContr:  the database of shock decompositions
% - range:    range of the charts
% - legends:  legends on the charts
%
% Outputs:
% - rprt: the report with the charts added
%
% See also: codes.reporting.addDecompCharts,
% codes.reporting.addTrendsAndGaps, codes.reportFilter,
% codes.reportForecast

switch caller
  case "history"
    doHighlight = false;
    graphNum = length(m);
  case "forecast"
    doHighlight = true;
    graphNum = length(opts.forecast.scenarioNames);
end

xnamesAll = string(get(m, "xnames"));
xdescrAll = string(get(m, "xdescript"));

rprt.section('Shock decomposition');
rprt.pagebreak;

groupNames = string(fieldnames(opts.filterHistory.shockDecompGroups));

legendEntries = [groupNames(1:end-1); opts.filterHistory.shockDecompGroups.Rest];

seriesNames = opts.filterHistory.shockDecompVars;

for i = 1:length(seriesNames)
  
  seriesName = seriesNames(i);

  figureName = xdescrAll(xnamesAll == seriesName) + " [" + seriesName + "]";

  rprt.figure(char(figureName), opts.barconOptions{:}, 'subplot', [graphNum 1]);
  
  for j = 1:graphNum

    decompContribs  = dbContr(j).(seriesNames(i)){:,1:end-1};
    decompSeries    = db.(seriesName){:,j};
    
    rprt = codes.reporting.barContrib(rprt, range, decompSeries, decompContribs, ...
      legends(j), legendEntries, jet());

    if doHighlight
      rprt.highlight('',  opts.forecastReport.highlightRange);
    end

  end
  
end

end