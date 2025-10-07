function rprt = addShocks(opts, rprt, m, db, range, legends)

enamesAll = string(get(m, "enames"));
edescrAll = string(get(m, "edescript"));

rprt.pagebreak;
rprt.section('Shocks');
rprt.pagebreak;

paramNum = length(m);

sbplt  = [3 3];
nsbplt = prod(sbplt);
npages = ceil(length(enamesAll)/nsbplt);

sty = opts.style;
sty.legend.location     = 'Best';
sty.legend.orientation  = 'vertical';

for np = 1:npages
  
  figureTitle = "Shocks (page " + num2str(np) + ")";
  rprt.figure(char(figureTitle), 'style', sty, 'subplot', sbplt);
  
  for i = nsbplt*(np-1)+1:min(nsbplt*np,length(enamesAll))
   % graphTitle = edescrAll(enamesAll == enamesAll(i)) + " [" + enamesAll(i) + "]";
    graphTitle = " [" + enamesAll(i) + "]";
    if i == nsbplt*(np-1)+1 && paramNum > 1
      rprt.graph(char(graphTitle), 'range', range, 'legend', true);
        %ak add shading for past from AddPage.m
    rprt.highlight('',  opts.forecastReport.highlightRange);
    
    else
      rprt.graph(char(graphTitle), 'range', range);
        %ak add shading for past from AddPage.m
    rprt.highlight('',  opts.forecastReport.highlightRange);
    end
    rprt.series(cellstr(legends), db.(enamesAll(i)));
  end
  
end

end