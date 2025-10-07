function rprt = addDecompCharts(opts, rprt, m, dc, range, legends, caller)
% codes.reporting.addDecompCharts adds equations decomposition charts to a report.
%
% Usage: rprt = codes.reporting.addDecompCharts(opts, rprt, m, dc, range, legends, highlightRange)
%
% Inputs:
% - opts:             options as returned by mainSettings()
% - rprt:             the report to which the charts will be added
% - m:                the model object used to calculate the decompositons
% - dc:               the database of decompositions, calculated in
%                     codes.reporting.calcDecompositions
% - range:            range of the charts
% - legends:          legends on the charts
% - highlightRange:   range to be higlighted (optional)
%
% Outputs:
% - rprt: the report with the decomposition charts added
%
% See also: codes.reporting.calcDecompositions,
% codes.reporting.addDecompTables, codes.reporting.addTrendsAndGaps,
% codes.reportFilter, codes.reportForecast

switch caller
  case "history"
    doHighlight = false;
  case "forecast"
    doHighlight = true;
end

rprt.section('Decomposition of equations: charts');
rprt.pagebreak;

paramNum = length(m);

seriesNames = opts.filterHistory.eqDecompVars;

for i = 1:numel(seriesNames)
  
  seriesName = seriesNames(i);

  figureName = dc.(seriesName).figureName;
 
  rprt.figure(char(figureName), opts.barconOptions{:}, 'subplot', [paramNum 1]);
      
  for j = 1:paramNum

    decompContribs  = dc.(seriesName).decompContribs{j};
    decompSeries    = dc.(seriesName).decompSeries{j};
    legendEntries   = dc.(seriesName).legendEntries;
    colorMap        = feval(dc.(seriesName).colorMap);
    
    rprt = codes.reporting.barContrib(rprt, range, decompSeries, decompContribs, ...
      legends(j), legendEntries, colorMap);

    if doHighlight
      rprt.highlight('',  opts.forecastReport.highlightRange);
    end
    
  end
  
end

end
