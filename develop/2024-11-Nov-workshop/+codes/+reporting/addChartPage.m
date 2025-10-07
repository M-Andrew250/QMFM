function rprt = addChartPage(opts, rprt, m, db, range, varNames, figureTitle, legends, highlightRange)
% codes.reporting.addChartPage adds a single page of charts to a report.
%
% Usage: rprt = codes.reporting.addChartPage(opts, rprt, m, db, varNames, figureTitle, legends, highlightRange)
%
% Inputs:
% - opts:             options as returned by mainSettings()
% - rprt:             the report to which the charts will be added
% - m:                the model object
% - db:               the database of the variables
% - range:            range of the charts
% - varNames:         list of variables on the charts
% - figureTitle:      title of the figure 
% - legends:          legends on the charts
% - highlightRange:   range to be higlighted (optional)
%
% Outputs:
% - rprt: the report with the charts added
%
% See also: codes.reporting.addTablePage, codes.reportForecast

if nargin < 9
  highlightRange = [];
end

descr = get(m, "descript");

legendState = length(legends) > 1;
legends = replace(legends, "_", "\_");

opts.style.legend.orientation  = 'vertical';
opts.style.legend.location     = 'best';

rprt.figure(char(figureTitle), 'range', range, ...
  'style', opts.style, 'zeroline', true);

for v = varNames(:)'
  
  varDescr  = descr.(v);
  graphTitle = {varDescr, char("[" + v + "]")};
  rprt.graph(graphTitle,  'Legend', legendState);
  rprt.series('', db.(v), 'LegendEntry', cellstr(legends));
  rprt.highlight('',  highlightRange);
  
  legendState = false;
  
end

end