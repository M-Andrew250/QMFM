function supplemtables()

%% Forecast tables: annual change % for comparison with intMF etc
% proxy Y(4Q)-on-Y(4Q) growth with annualized Q y-on-y growth series 
% Load data (observed/forecast) set, set plot/highlight ranges
clear, clc, close all;
% load("results/data.mat");
opts    = mainSettings();
load("results/forecast.mat");
% plotRange = qq(2017,1) : qq(2026,4);
% HighRange = qq(2017,1) : qq(2022,4);
tableRange_ann     = yy(2018) : yy(2026);
%% For annual tables 
% Load the forecast
tmp = codes.loadResult(opts, "forecast");
m   = tmp.m;
db  = tmp.dbFcast;
dbDecomp  = tmp.dbDecomp;
% Create the report
legends = codes.reporting.createScenarioLegend(opts);
reportTitle = "Forecast table annual growth";
rprt = report.new(char(reportTitle));
% annualize growth rate: either from pct4_y (exact) or d4l_y (proxy)
dc.pct4_y_a    = convert(db.pct4_y,'a');
%db.d4l_y_a     = convert(db.d4l_y,'a');
% option: go back to Q, use only 4thQ
% help   = convert(db.pct4_y_a, 'q', 'method', 'last');
% db.pct4_y_aq   =  help;

dc.pct4_cons_a = convert(db.pct4_cons,'a');
dc.pct4_gdem_a = convert(db.pct4_gdem,'a');
dc.pct4_inv_a = convert(db.pct4_inv,'a');
dc.pct4_exp_a = convert(db.pct4_exp,'a');
dc.pct4_imp_a = convert(db.pct4_imp,'a');
% second option: log approximation (first option is exact)
% db.d4l_cons_a = convert(db.d4l_cons,'a');
% db.d4l_gdem_a = convert(db.d4l_gdem,'a');
% db.d4l_inv_a = convert(db.d4l_inv,'a');
% db.d4l_exp_a = convert(db.d4l_exp,'a');
% db.d4l_imp_a = convert(db.d4l_imp,'a');

dc.pct4_cpi_eop = convert(db.pct4_cpi,'a', 'method', 'last');
dc.pct4_cpi_pa = convert(db.pct4_cpi,'a');
dc.dl_py_pa  = convert(db.dl_py,'a'); % "log change GDP deflator AK 7/1
dc.pct4_s_eop = convert(db.pct4_s,'a', 'method', 'last');
dc.pct4_s_pa = convert(db.pct4_s,'a');
dc.pct4_z_pa = convert(db.pct4_z,'a');

% db.d4l_cpi_eop = convert(db.d4l_cpi,'a', 'method', 'last');
% db.d4l_cpi_pa = convert(db.d4l_cpi,'a');
% db.d4l_s_eop = convert(db.d4l_s,'a', 'method', 'last');
% db.d4l_s_pa = convert(db.d4l_s,'a');
% db.d4l_z_pa = convert(db.d4l_z,'a');

% govt deficit and govt demand % real GDP (ignoring deflators)
dc.def_a = convert(db.def_y,'a'); % unweighted by Q GDP, but series s.a.!
db.def_inc_grants = db.def_y - db.grants_y;
dc.def_inc_grants_a = convert(db.def_inc_grants,'a');
gdem_y = (exp(db.l_gdem/100)+exp(db.l_gdem{-1}/100)+exp(db.l_gdem{-2}/100)+exp(db.l_gdem{-3}/100))/...
    (exp(db.l_y/100)+exp(db.l_y{-1}/100)+exp(db.l_y{-2}/100)+exp(db.l_y{-3}/100));
dc.gdem_y_a = convert(gdem_y,'a', 'method', 'last');

% demand components % nominal GDP (model: CPI for dom demand, GEE Pexp, Pimp
gdem_y_nom = (db.ngdem+db.ngdem{-1}+db.ngdem{-2}+db.ngdem{-3})/...
    (db.ny+db.ny{-1}+db.ny{-2}+db.ny{-3});
dc.gdem_y_nom_a = convert(gdem_y_nom,'a', 'method', 'last')*100; % annual share GDP w deflators fr AUX .model
cons_y_nom = (db.ncons+db.ncons{-1}+db.ncons{-2}+db.ncons{-3})/...
    (db.ny+db.ny{-1}+db.ny{-2}+db.ny{-3});
dc.cons_y_nom_a = convert(cons_y_nom,'a', 'method', 'last')*100; % annual share GDP w deflators fr AUX .model
inv_y_nom = (db.ninv+db.ninv{-1}+db.ninv{-2}+db.ninv{-3})/...
    (db.ny+db.ny{-1}+db.ny{-2}+db.ny{-3});
dc.inv_y_nom_a = convert(inv_y_nom,'a', 'method', 'last')*100; % annual share GDP w deflators fr AUX .model
exp_y_nom = (db.nexp+db.nexp{-1}+db.nexp{-2}+db.nexp{-3})/...
    (db.ny+db.ny{-1}+db.ny{-2}+db.ny{-3});
dc.exp_y_nom_a = convert(exp_y_nom,'a', 'method', 'last')*100; % annual share GDP w deflators fr AUX .model
imp_y_nom = (db.nimp+db.nimp{-1}+db.nimp{-2}+db.nimp{-3})/...
    (db.ny+db.ny{-1}+db.ny{-2}+db.ny{-3});
dc.imp_y_nom_a = convert(imp_y_nom,'a', 'method', 'last')*100; % annual share GDP w deflators fr AUX .model

dc.tb_rat_a = convert(db.tb_rat,'a'); % resource balance in % of GDP AK 7/1

dc.dl_md_a  = convert(db.dl_md,'a'); % average 4 Q of annualized Q-on-Q growth

% debt ratios
% db.debt_y = (db.debt_fcy_y + db.debt_lcy_y)/4;
dc.debt_y_a = convert(db.debt_y,'a', 'method', 'last');
dc.debt_fcy_a = convert(db.debt_fcy_y/4,'a', 'method', 'last');
dc.debt_lcy_a = convert(db.debt_lcy_y/4,'a', 'method', 'last');

varNames   = [
  "pct4_y_a",     "Real GDP % growth p.a."
  "pct4_cpi_eop", "CPI % change end-year"
  "pct4_cpi_pa",  "CPI % change period-average"
  "dl_py_pa",     "GDP deflator % change period-average" % AK 7/1
  "pct4_cons_a",  "Real consumption % growth p.y."
  "pct4_gdem_a",  "Real government demand G&S % growth p.y."
  "pct4_inv_a",   "Real investment % growth p.y."
  "pct4_exp_a",   "Real exports % growth p.y."
  "pct4_imp_a",   "Real imports % growth p.y."
%   "d4l_y_a",     "Real GDP % growth p.a."
%   "d4l_cpi_eop", "CPI % change end-year"
%   "d4l_cpi_pa",  "CPI % change period-average"
%   "d4l_cons_a",  "Real consumption % growth p.y."
%   "d4l_gdem_a",  "Real government demand G&S % growth p.y."
%   "d4l_inv_a",   "Real investment % growth p.y."
%   "d4l_exp_a",   "Real exports % growth p.y."
%   "d4l_imp_a",   "Real imports % growth p.y."
  
  "def_a",              "Fiscal deficit before grants % of GDP"
  "def_inc_grants_a",   "Fiscal deficit incl. grants % of GDP"
  "gdem_y_a",           "Government demand G&S % of real GDP"
  
  "pct4_s_eop",  "Exchange rate % change end-year"
  "pct4_s_pa",   "Exchange rate % change period-average"
  "pct4_z_pa",   "Real exchange rate % change period average"
%   "d4l_s_eop",  "Exchange rate % change end-year"
%   "d4l_s_pa",   "Exchange rate % change period-average"
%   "d4l_z_pa",   "Real exchange rate % change period average"
  
  "debt_y_a",      "Total public debt % of GDP end-year"
  "debt_fcy_a",    "Foreign public debt % of GDP end-year"
  "debt_lcy_a",    "Domestic public debt % of GDP end-year"
  
  "cons_y_nom_a"   "Private consumption % of GDP"
  "inv_y_nom_a"    "Private investment % of GDP"
  "gdem_y_nom_a"   "Government demand G&S % of GDP"
  "exp_y_nom_a"    "Exports G&S % of GDP"
  "imp_y_nom_a"    "Imports G&S % of GDP"
  "tb_rat_a",      "Resource balance G&S % of GDP" % AK 7/1
  "dl_md_a",       "Annual growth money demand in %" % AK 7/22
    ];

tableTitle = "Key macro aggregates (Y-on-Y % growth)";
% extract some code from addTablePage, but leave addTablePage intact
%rprt = codes.reporting.addTablePage(opts, rprt, m, db, varNames, tableTitle, legends);
rprt.table(char(tableTitle), 'range', tableRange_ann, ...
  'typeface', '\small', 'long', true, ...
  'vline', tableRange_ann(1) -1);
for i = 1 : size(varNames,1)
  rprt.series(char(varNames(i,2)), dc.(varNames(i,1)));
end

% Publish report
codes.writeMessage("Table annualized: compiling the report ...");

fileName = fullfile(opts.mainDir, "reports", "TableAnnualGrowth.pdf");
if codes.checkFile(fileName)
  rprt.publish(fileName, opts.publishOptions{:}, 'textscale', [0.95 0.8]);
end

% Close invisible figure windows
codes.closeFigures();

codes.writeMessage("Table annualized: done.");

% Write results to csv format with above-specified tableRange_ann = yy(2018):yy(2026)
codes.writeMessage("writing annualized results to CSV ...");
fileName = fullfile(opts.mainDir, "results", "TableAnnual" + ".csv");

save(fileName, "dc"); % unclear if this statement is needed
if codes.checkFile(fileName)
databank.toCSV(dc,fileName,'Class', false, 'NaN', '', 'Format', '%.16f');
end