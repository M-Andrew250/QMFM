function rprt = addTablePage(opts, rprt, m, db, varNames, tableTitle, legends)

rprt.table(char(tableTitle), 'range', opts.forecastReport.tableRange, ...
  'typeface', '\small', 'long', true, ...
  'vline', opts.forecast.range(1)-1);

for i = 1 : size(varNames,1)
  rprt.series(char(varNames(i,2)), db.(varNames(i,1)));
end

end