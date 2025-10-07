function rprt = addDecompTables(opts, rprt, m, dc, range, legends)
% codes.reporting.addDecompTables adds equations decomposition tables to a report.
%
% Usage: rprt = codes.reporting.addDecompTables(opts, rprt, m, dc, range, legends, vLine)
%
% Inputs:
% - opts:     options as returned by mainSettings()
% - rprt:     the report to which the tables will be added
% - m:        the model object used to calculate the decompositons
% - dc:       the database of decompositions, calculated in
%             codes.reporting.calcDecompositions
% - range:    range of the tables
% - legends:  legends on the tables
% - vLine:    range to be higlighted (optional)
%
% Outputs:
% - rprt: the report with the decomposition tables added
%
% See also: codes.reporting.calcDecompositions,
% codes.reporting.addDecompCharts, codes.reporting.addTrendsAndGaps,
% codes.reportFilter, codes.reportForecast

rprt.section('Decomposition of equations: tables');
rprt.pagebreak;

paramNum = length(m);

seriesNames = opts.filterHistory.eqDecompVars;

for i = 1:numel(seriesNames)
  
  seriesName = seriesNames(i);
  
  rprt.pagebreak;
  rprt.figure(char(dc.(seriesName).figureName), opts.barconOptions{:}, 'subplot', [paramNum 1]);
  
  for j = 1:paramNum
    
    rprt = codes.reporting.tableContrib(rprt, range, ...
      dc.(seriesName).decompSeries{j}, dc.(seriesName).decompContribs{j}, legends(j), ...
      dc.(seriesName).legendEntries, opts.forecast.range(1)-1);
    
  end
  
end

end
