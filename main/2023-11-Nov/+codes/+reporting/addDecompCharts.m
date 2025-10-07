function rprt = addDecompCharts(opts, rprt, m, dc, range, legends, caller)

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
 
  rprt.figure(char(dc.(seriesName).figureName), opts.barconOptions{:}, 'subplot', [paramNum 1]);
      
  for j = 1:paramNum
    
    rprt = codes.reporting.barContrib(rprt, range, ...
      dc.(seriesName).decompSeries{j}, dc.(seriesName).decompContribs{j}, legends(j), ...
      dc.(seriesName).legendEntries, feval(dc.(seriesName).colorMap));

    if doHighlight
      rprt.highlight('',  opts.forecastReport.highlightRange);
    end
    
  end
  
end

end
