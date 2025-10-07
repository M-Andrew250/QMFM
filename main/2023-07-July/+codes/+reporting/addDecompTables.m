function rprt = addDecompTables(opts, rprt, m, dc, range, legends)

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
