function rprt = addShockDecompositions(opts, rprt, m, db, dbContr, range, legends)

xnamesAll = string(get(m, "xnames"));
xdescrAll = string(get(m, "xdescript"));

rprt.section('Shock decomposition');
rprt.pagebreak;

paramNum = length(m);

groupNames = string(fieldnames(opts.filterHistory.shockDecompGroups));

legendEntries = [groupNames(1:end-1); opts.filterHistory.shockDecompGroups.Rest];

varNames = opts.filterHistory.shockDecompVars;

for i = 1:length(varNames)
  
  seriesName = varNames(i);
  figureName = xdescrAll(xnamesAll == seriesName) + " [" + seriesName + "]";
  rprt.figure(char(figureName), opts.barconOptions{:}, 'subplot', [paramNum 1]);
  
  for j = 1:paramNum
    decompContribs = dbContr(j).(varNames(i)){:,1:end-1};
    decompSeries = db.(seriesName){:,j};
    rprt = codes.reporting.barContrib(rprt, range, decompSeries, decompContribs, legends(j), legendEntries, jet());
  end
  
end

end