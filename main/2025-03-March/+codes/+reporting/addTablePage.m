function rprt = addTablePage(opts, rprt, m, db, range, varNames, tableTitle, legends, vLine)

% codes.reporting.addTablePage adds a table to a report, starting on a new page.
%
% Usage: rprt = codes.reporting.addTablePage(opts, rprt, m, db, range, varNames, figureTitle, legends, highlightRange)
%
% Inputs:
% - opts:         options as returned by mainSettings()
% - rprt:         the report to which the table will be added
% - m:            the model object
% - db:           the database of the variables
% - range:        range of the table
% - varNames:     list of variables in the table
% - tableTitle:   title of the figure 
% - legends:      legends on the table
% - vLine:        period after which a separator is drawn (optional)
%
% Outputs:
% - rprt: the report with the table added
%
% See also: codes.reporting.addChartPage, codes.reportForecast

if nargin < 9
  vLine = [];
end

rprt.table(char(tableTitle), 'range', range, ...
  'typeface', '\small', 'long', true, ...
  'vline', vLine);

for i = 1 : size(varNames,1)
  rprt.series(char(varNames(i,2)), db.(varNames(i,1)));
end

end