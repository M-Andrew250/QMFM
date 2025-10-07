function rprt = tableContrib(rprt, range, decompSeries, decompContribs, figureName, legendEntries, vline)

if nargin < 7
  vline = [];
end

rprt.table(char(figureName), ...
  'range', range, 'typeface' , '\scriptsize', 'vline', vline);

for i = 1:numel(legendEntries)
  if i < numel(legendEntries)
    rprt.series(char(legendEntries(i)), decompContribs{:,i});
  else
    rprt.series(char(legendEntries(i)), decompContribs{:,i}, ...
      'separator', '\hline');
  end
end

rprt.series('Total', decompSeries);

end