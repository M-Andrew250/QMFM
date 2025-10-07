function rprt = addTrendsAndGaps(opts, rprt, m, db, dbObs, range, legends)

xnamesAll = string(get(m, "xnames"));
xdescrAll = string(get(m, "xdescript"));

rprt.section('Trends and gaps');
rprt.pagebreak;

legend_t = strtrim(legends + " tnd");
legend_g = strtrim(legends + " gap");

legendState = length(legends) > 1;

for i = 1:length(opts.filterHistory.trendGapVars)
  
  name        = opts.filterHistory.trendGapVars(i, 1);
  trendName   = opts.filterHistory.trendGapVars(i, 2);
  gapName     = opts.filterHistory.trendGapVars(i, 3);
  
  obsName     = "obs_" + name;
   fcastName   = name;
  
  figureTitle = xdescrAll(xnamesAll == name) + " [" + name + "]";
  rprt.figure(char(figureTitle), 'style', opts.style, 'subplot', [2 2]);
  
  if isfield(db, trendName)
    
    rprt.graph('Level', 'legend', legendState, 'range', range);
    rprt.series('', db.(trendName), 'legendentry', cellstr(legend_t));
    rprt.highlight('',  opts.forecastReport.highlightRange);
    if isfield(dbObs, obsName)
      rprt.series('Observed', dbObs.("obs_" + name));
      rprt.series('', db.(fcastName));
    elseif isfield(db, name) % e.g. no obs for r, plot the filtered
      rprt.series('Filtered', db.( name));
      
    end
    
  end
  
  if isfield(db, gapName)
    
    rprt.graph('Gap', 'legend', legendState, 'range', range);
    rprt.series('Gap', db.(gapName), 'legendentry', cellstr(legend_g));
    rprt.highlight('',  opts.forecastReport.highlightRange);
    
  end
  
  if isfield(db, "d" + name)
    
    rprt.graph('Quarterly change (annualized)', 'legend', legendState, 'range', range);
    rprt.series('', db.("d" + trendName), 'legendentry', cellstr(legend_t));
    rprt.series('Observed', dbObs.("obs_" + "d" + name));
       rprt.series('', db.("d" + fcastName));
    rprt.highlight('',  opts.forecastReport.highlightRange);
    
  end
  
  if isfield(db, "d4" + name)
    
    rprt.graph('Yearly change', 'legend', legendState, 'range', range);
    rprt.series('', db.("d4" + trendName), 'legendentry', cellstr(legend_t));
    rprt.series('Observed', dbObs.("obs_" + "d4" + name));
        rprt.series('', db.("d4" + fcastName));
    rprt.highlight('',  opts.forecastReport.highlightRange);
    
  end
  
end

end