function rprt = barContrib(rprt, range, decompSeries, decompContribs, figureName, legendEntries, colorMap)

rprt.graph(char(figureName), 'range', range, 'xlabel', ' ', 'legend', true, 'ColorMap', colorMap);
rprt.series('', decompContribs, 'plotFunc', @barcon, 'legendEntry', cellstr(legendEntries));
rprt.series('', decompSeries, 'legendEntry', NaN); % Background (white)
rprt.series('', decompSeries, 'legendEntry', NaN); % Foreground

end