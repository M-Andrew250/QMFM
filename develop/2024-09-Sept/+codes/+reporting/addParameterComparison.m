function rprt = addParameterComparison(opts, rprt, m)

pnamesAll = string(get(m, "pnames"));
pdescrAll = string(get(m, "pdescript"));

enamesAll = string(get(m, "enames"));
edescrAll = string(get(m, "edescript"));

pnamesAll = [pnamesAll, "std_" + enamesAll];
pdescrAll = [pdescrAll, edescrAll];

p   = get(m, "Parameters");
p   = structfun(@transpose, p, "Uniformoutput", false);
p   = table2array(struct2table(p))';

ind = any(abs(p(:,2:end) - repmat(p(:,1), 1, length(m)-1)) > 1e-12, 2);
ind = ind | any(isnan(p),2);
p   = p(ind,:);

rn = pdescrAll(ind)' + " [" + pnamesAll(ind)' + "]";

rprt.matrix('Differing parameters', p, ...
  'rownames',       cellstr(rn), ...
  'colnames',       cellstr(opts.parameterLegends), ...
  'rotatecolnames', false);
rprt.pagebreak;

end