function rprt = addTrendsAndGaps(opts, rprt, m, db0, db1, range, legends, caller)
% codes.reporting.addTrendsAndGaps adds trend-gap charts to a report.
%
% Usage: rprt = codes.reporting.addTrendsAndGaps(opts, rprt, m, db, range, legends, caller)
% 
% Inputs:
% - opts:             options as returned by mainSettings()
% - rprt:             the report to which the charts will be added
% - m:                the model object
% - db:               the database
% - range:            range of the charts
% - varNames:         list of variables on the charts
% - legends:          legends on the charts
% - caller:           range to be higlighted (optional)
%
% Outputs:
% - rprt: the report with the charts added
%
% See also: codes.reportForecast, codes.reporting.addDecompCharts,
% codes.reporting.addChartPage, codes.reporting.addTablePage

switch caller
  
  case "history"
    
    actPrefix = "obs_";
    actLabel  = "Observed";
    doHighlight = false;
    
  case "forecast"
    
    actPrefix = "";
    actLabel  = "Forecast";
    doHighlight = true;
    
end

xnamesAll = string(get(m, "xnames"));
xdescrAll = string(get(m, "xdescript"));

rprt.section('Trends and gaps');
rprt.pagebreak;

legend_t = strtrim(legends + " tnd");
legend_g = strtrim(legends + " gap");

legendState = length(legends) > 1;

for i = 1:size(opts.filterHistory.trendGapVars, 1)
  
  name        = opts.filterHistory.trendGapVars(i, 1);
  trendName   = opts.filterHistory.trendGapVars(i, 2);
  gapName     = opts.filterHistory.trendGapVars(i, 3);
  
  figureTitle = xdescrAll(xnamesAll == name) + " [" + name + "]";
  rprt.figure(char(figureTitle), 'style', opts.style, 'subplot', [2 2]);
  
  if isfield(db0, trendName)
    
    rprt.graph('Level', 'legend', legendState, 'range', range);
    rprt.series('', db0.(trendName), 'legendentry', cellstr(legend_t));

    if isfield(db1, actPrefix + name)
      rprt.series(char(actLabel), db1.(actPrefix + name));
    elseif isfield(db0, name) % e.g. no obs for r, plot the filtered
      rprt.series('Filtered', db0.( name));
    end

    if doHighlight
      rprt.highlight('',  opts.forecastReport.highlightRange);
    end
    
  end
  
  if isfield(db0, gapName)
    
    rprt.graph('Gap', 'legend', legendState, 'range', range);
    rprt.series('Gap', db0.(gapName), 'legendentry', cellstr(legend_g));
    
    if doHighlight
      rprt.highlight('',  opts.forecastReport.highlightRange);
    end
    
  end
  
  if isfield(db0, "d" + name)
    
    rprt.graph('Quarterly change (annualized)', 'legend', legendState, 'range', range);
    rprt.series('', db0.("d" + trendName), 'legendentry', cellstr(legend_t));
    rprt.series(char(actLabel), db1.(actPrefix + "d" + name));

    if doHighlight
      rprt.highlight('',  opts.forecastReport.highlightRange);
    end
    
  end
  
  if isfield(db0, "d4" + name)
    
    rprt.graph('Yearly change', 'legend', legendState, 'range', range);
    rprt.series('', db0.("d4" + trendName), 'legendentry', cellstr(legend_t));
    rprt.series(char(actLabel), db1.(actPrefix + "d4" + name));
    
    if doHighlight
      rprt.highlight('',  opts.forecastReport.highlightRange);
    end
    
  end
  
end

end