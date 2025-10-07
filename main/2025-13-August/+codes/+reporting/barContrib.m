function rprt = barContrib(rprt, range, decompSeries, decompContribs, figureName, legendEntries, colorMap)
% codes.reporting.barContrib adds a graph of contributions to a report.
%
% Usage: rprt = codes.reporting.barContrib(rprt, range, decompSeries, decompContribs, figureName, legendEntries, colorMap)

rprt.graph(char(figureName), 'range', range, 'xlabel', ' ', 'legend', true, 'ColorMap', colorMap);
rprt.series('', decompContribs, 'plotFunc', @barcon, 'legendEntry', cellstr(legendEntries));
rprt.series('', decompSeries, 'legendEntry', NaN); % Background (white)
rprt.series('', decompSeries, 'legendEntry', NaN); % Foreground

end