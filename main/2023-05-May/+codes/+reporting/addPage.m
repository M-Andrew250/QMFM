function rprt = addPage(opts, rprt, m, db, varNames, figureTitle, legends)

xnamesAll = string(get(m, "xnames"));
xdescrAll = string(get(m, "xdescript"));

legendState = length(legends) > 1;

opts.style.legend.orientation  = 'vertical';
opts.style.legend.location     = 'best';

rprt.figure(char(figureTitle), 'range', opts.forecastReport.plotRange, ...
  'style', opts.style, 'zeroline', true);

for v = varNames(:)'
  
  varDescr  = xdescrAll(xnamesAll == v);
  rprt.graph(char(varDescr + " [" + v + "]"),  'Legend', legendState);
  rprt.series('',     db.(v), 'LegendEntry', cellstr(legends));
  rprt.highlight('',  opts.forecastReport.highlightRange);
  
  legendState = false;
  
end

end