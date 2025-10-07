function reportCompareData

optsCurr = mainSettings();
optsPrev = optsCurr.compOpts;

tmp_curr = codes.utils.loadResult(optsCurr, "data");
tmp_comp = codes.utils.loadResult(optsPrev, "data");

tmp = codes.utils.loadResult(optsCurr, "model");
m = tmp.m;

legends = ["Current", optsCurr.compRound];

descr = get(m, "descript");

% ------------- Create the report -------------

reportTitle = "Data comparison report";
rprt = report.new(char(reportTitle));

% -------- Compare observed data --------

rprt.section('Observed data');
rprt.pagebreak;

db_curr = tmp_curr.dbObs;
db_comp = tmp_comp.dbObs;

% ----- Removed / added variables -----

names_curr = fieldnames(db_curr);
names_comp = fieldnames(db_comp);

rprt.array('Added observation variables', ...
  setdiff(names_curr, names_comp) ...
  );

rprt.array('Removed observation variables', ...
  setdiff(names_comp, names_curr) ...
  );

% ----- Plot common variables -----

db = databank.merge("horzcat", db_comp, db_curr);

varNames = string(intersect(names_curr, names_comp, "stable"));

rprt = addVariableCharts(rprt, db, varNames, legends, descr, optsCurr);

% databank.plot(db, fieldnames(db));

% -------- Compare auxiliary data --------

rprt.section('Auxiliary data');
rprt.pagebreak;

db_curr = tmp_curr.dbAux;
db_comp = tmp_comp.dbAux;

% ----- Removed / added variables -----

names_curr = fieldnames(db_curr);
names_comp = fieldnames(db_comp);

rprt.array('Added auxiliary variables', ...
  setdiff(names_curr, names_comp) ...
  );

rprt.array('Removed auxiliary variables', ...
  setdiff(names_comp, names_curr) ...
  );

% ----- Plot common variables -----

db = databank.merge("horzcat", db_comp, db_curr);

varNames = string(intersect(names_curr, names_comp, "stable"));

rprt = addVariableCharts(rprt, db, varNames, legends, [], optsCurr);

% databank.plot(db, fieldnames(db));

% ------------- Publish report -------------

codes.utils.writeMessage(mfilename + ": compiling the data comparison report ...");
codes.utils.saveReport(optsCurr, "reportCompareData", rprt);
codes.utils.writeMessage(mfilename + ": done.");

end

function rprt = addVariableCharts(rprt, db, varNames, legends, descr, opts)

cntr = 0;
while ~isempty(varNames)

  nVars = min(6, numel(varNames));
  varNamesCurrPage = varNames(1 : nVars);

  cntr = cntr + 1;
  figureTitle = "Observed variables (page " + cntr + ")";

  opts.style.line.marker = '*';
  opts.style.line.markerSize = 4;

  rprt.figure(char(figureTitle), 'range', opts.filterHistory.range, ...
    'style', opts.style, 'zeroline', true, 'subplot', [2, 3]);

  for v = varNamesCurrPage(:)'

    if ~isempty(descr)
      varDescr  = descr.(v);
    else
      varDescr = "";
    end

    rprt.graph(char(varDescr + " [" + v + "]"), 'legend', true);
    rprt.series('', db.(v), 'LegendEntry', cellstr(legends));

  end

  varNames(1 : nVars) = [];

end

end