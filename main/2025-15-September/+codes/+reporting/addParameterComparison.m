function rprt = addParameterComparison(opts, rprt, m)
% codes.reporting.addParameterComparison adds a table of differing parameter values to a report.
%
% Usage: rprt = codes.reporting.addParameterComparison(opts, rprt, m)
%
% Inputs:
% - opts:   options as returned by mainSettings()
% - rprt:   the report to which the tables will be added
% - m:      the model object from which the parameter values are taken.
%
% Outputs:
% - rprt: the report with the table added
%
% See also: codes.reporting.addDecompCharts,
% codes.reporting.addTrendsAndGaps, codes.reportModel

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