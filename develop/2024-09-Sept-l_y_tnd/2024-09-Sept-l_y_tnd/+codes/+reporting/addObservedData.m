function rprt = addObservedData(opts, rprt, m, db, range)

ynamesAll = string(get(m, "ylist"));
ydescrAll = string(get(m, "ydescript"));

rprt.section('Observed data');
rprt.pagebreak;

sbplt  = [2 3];
nsbplt = prod(sbplt);
npages = ceil(length(ynamesAll)/nsbplt);

for np = 1:npages
  
  figureTitle = "Observed data (page " + num2str(np) + ")";
  rprt.figure(char(figureTitle), 'style', opts.style, 'subplot', sbplt);
  
  for i = nsbplt*(np-1)+1 : min(nsbplt*np, length(ynamesAll))
    graphTitle = ydescrAll(i) + " [" + ynamesAll(i) + "]";
    rprt.graph(char(graphTitle), 'range', range);
    if isfield(db, ynamesAll(i))
      rprt.series('', db.(ynamesAll(i)));
    else
      rprt.series('', Series());
    end
  end
  
end

end