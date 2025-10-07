function reportHistForecast()

opts = mainSettings();
optsHF = opts.histForecast;

codes.writeMessage("reportHistForecast: loading model and data ...");

% Load historical forecasts
tmp     = codes.loadResult(opts, "histForecast");
dbFcast = tmp.dbFcast;

% Adjust histForecast range
tmp = databank.range(dbFcast(1));
optsHF.range = tmp(2:end);

% Load smoothed data
tmp = codes.loadResult(opts, "filter");
dbFilt = tmp.dbFilt;

% Load model
tmp = codes.loadResult(opts, "model");
m = tmp.m;

% Get variable names and comments

xNamesAll = string(get(m, "xnames"));
xDescrAll = string(get(m, "xdescript"));

paramNum = length(opts.parameterNames);

% Legend
legends = codes.reporting.createParamLegend(opts);

xNames = optsHF.variables;
xDescr = codes.selectFromList(xNames, xNamesAll, xDescrAll);

enamesAll = string(get(m, "enames"));
edescrAll = string(get(m, "edescript"));

pnamesAll = string(get(m, "pnames"));
pdescrAll = string(get(m, "pdescript"));

pnamesAll = [pnamesAll, "std_" + enamesAll];
pdescrAll = [pdescrAll, edescrAll];

% Create report
rprt = report.new('Historical forecasts');

% Comparison of parameters

if 1 < paramNum
  
  rprt.section('Comparing parameters');
  
  p   = get(m, "Parameters");
  p   = structfun(@transpose, p, "Uniformoutput", false);
  p   = table2array(struct2table(p))';
  
  ind = any(abs(p(:,2:end) - repmat(p(:,1), 1, paramNum-1)) > 1e-12, 2);
  ind = ind | any(isnan(p),2);
  p   = p(ind,:);
  
  rn = pdescrAll(ind)' + " [" + pnamesAll(ind)' + "]";
  
  rprt.matrix('Differing parameters', p, ...
    'rownames',       cellstr(rn), ...
    'colnames',       cellstr(opts.parameterLegends), ...
    'rotatecolnames', false);
  rprt.pagebreak;
  
end

% Calculate forecast error statistics

codes.writeMessage("reportHistForecast: calculating forecast error statistics ...");

for n = 1 : paramNum
  
  for i = 1:length(optsHF.variables)
    
    varName = optsHF.variables(i);
    
    fc    = [dbFcast(:, n).(varName)];
    act   = dbFilt.mean.(varName){:, n};
    
    fcErr       = fc - act;
    fcErrNum    = fcErr(:);
    fcErrRange  = range(fcErr);
    
    fcErrHor.(varName)   = Series([], []);
    fcErrRWHor.(varName) = Series([], []);
    
    for h = 1 : optsHF.horizon
      
      fcErrRangeH = fcErrRange(h+1 : end);
      
      fcErrHor.(varName) = [ ...
        fcErrHor.(varName), ...
        Series(fcErrRangeH, diag(fcErrNum, -h))
        ];
      
      actH = act{fcErrRangeH};
      
      fcErrRWHor.(varName) = [ ...
        fcErrRWHor.(varName), ...
        actH{-h} - actH
        ];
      
    end
        
  end
  
  meanErr(n) = databank.batch(fcErrHor, '$0', ...
    ['Series(1:', num2str(optsHF.horizon), ',nanmean($0))'], ...
    'AddToDatabank', struct()); %#ok<AGROW>
  
  meanAbsErr(n) = databank.batch(fcErrHor, '$0', ...
    ['Series(1:', num2str(optsHF.horizon), ',nanmean(abs($0)))'], ...
    'AddToDatabank', struct()); %#ok<AGROW>
  
  rmse(n) = databank.batch(fcErrHor, '$0', ...
    ['Series(1:', num2str(optsHF.horizon), ',sqrt(nanmean($0^2)))'], ...
    'AddToDatabank', struct()); %#ok<AGROW>
  
  rmseRW(n) = databank.batch(fcErrRWHor, '$0', ...
    ['Series(1:', num2str(optsHF.horizon), ',sqrt(nanmean($0^2)))'], ...
    'AddToDatabank', struct()); %#ok<AGROW>
  
end

for i = 1:length(optsHF.variables)
  
  varName = optsHF.variables(i);
  
  figureTitle = xDescr(i) + " [" + xNames(i) + "]";
  rprt.figure(char(figureTitle));
  
  for n = 1:paramNum
    
    if paramNum > 1
      rprt.graph(char(legends(n)), 'axesOptions', {'box','off','fontsize',9});
    else
      rprt.graph('', 'axesOptions', {'box','off','fontsize',9});
    end
    
    % "Actual"
    rprt.series('', dbFilt.mean.(varName){:, n}, 'plotOptions', opts.style_hist_actual);
    
    % Forecasts
    rprt.series('', [dbFcast(:, n).(varName)], 'plotOptions', opts.style_hist_forecast);
    
    % Markers
    markers = Series();
    
    for t = 1:length(optsHF.range)
      tmp = dbFcast(t, n).(varName);
      markers(optsHF.range(t) - 1) = tmp(optsHF.range(t) - 1);
    end
    rprt.series('', markers, 'plotOptions', opts.style_hist_mark);
    
  end
  
end

for n = 1:paramNum
  
  rowNames = xDescr + " [" + xNames + "]";
  colNames = num2str((1:8)') + "q";
  
  matrixTitle = "Root-mean-square error, " + legends(n);
  data        = databank.toSeries(rmse(n));
  rprt.matrix(char(matrixTitle), data(:)', ...
    'rownames', cellstr(rowNames), ...
    'colnames', cellstr(colNames), ...
    'format',   '%.3f');
  
  matrixTitle = "Mean absolute error, " + legends(n);
  data        = databank.toSeries(meanAbsErr(n));
  rprt.matrix(char(matrixTitle), data(:)', ...
    'rownames', cellstr(rowNames), ...
    'colnames', cellstr(colNames), ...
    'format',   '%.3f');
  
  matrixTitle = "Mean error, " + legends(n);
  data        = databank.toSeries(meanErr(n));
  rprt.matrix(char(matrixTitle), data(:)',...
    'rownames', cellstr(rowNames), ...
    'colnames', cellstr(colNames), ...
    'format',   '%.3f');
  
  matrixTitle = "Root-mean-square error compared to random walk, " + legends(n);
  data        = databank.toSeries(rmse(n)) / databank.toSeries(rmseRW(n));
  rprt.matrix(char(matrixTitle), data(:)',...
    'rownames', cellstr(rowNames), ...
    'colnames', cellstr(colNames), ...
    'format',   '%.3f');
  
end

codes.writeMessage("reportHistForecast: compiling the report ...");

fname = fullfile(opts.mainDir, "reports", "histForecastReport.pdf");
if codes.checkFile(fname)
  rprt.publish(fname,opts.publishOptions{:},'textscale',[0.95 0.8]);
end

codes.writeMessage("reportHistForecast: done.");