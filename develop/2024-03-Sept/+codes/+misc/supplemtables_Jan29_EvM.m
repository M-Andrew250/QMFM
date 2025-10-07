function supplemtables ()

%% Forecast tables: annual change % for comparison with intMF etc
% proxy Y(4Q)-on-Y(4Q) growth with annualized Q y-on-y growth series 
% Load data (observed/forecast) set, set plot/highlight ranges
clear, clc, close all;
% load("results/data.mat");
opts    = mainSettings();
% load("results/forecast.mat");
% plotRange = qq(2017,1) : qq(2026,4);
% HighRange = qq(2017,1) : qq(2022,4);
tableRange_ann     = yy(2018) : yy(2028);
%% For annual tables 
% Load the forecast
tmp = codes.utils.loadResult(opts, "forecast");
% m   = tmp.m;
db  = tmp.dbFcast;
% dbDecomp  = tmp.dbEqDecomp;
% Create the report
% legends = codes.reporting.createScenarioLegend(opts);
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

% govt deficit, govt demand % real GDP, other deficit parts (ignoring deflators)
dc.def_a = convert(db.def_y,'a'); % unweighted by Q GDP, but series s.a.!
db.def_inc_grants = db.def_y - db.grants_y;
dc.def_inc_grants_a = convert(db.def_inc_grants,'a');
dc.grev_a = convert(db.grev_y,'a'); % real GDP
dc.oexp_a = convert(db.oexp_y,'a'); % real GDP

% real govt demand G&S % real GDP (check if shares add up despite proxies)
gdem_y = (exp(db.l_gdem/100)+exp(db.l_gdem{-1}/100)+exp(db.l_gdem{-2}/100)+exp(db.l_gdem{-3}/100))/...
    (exp(db.l_y/100)+exp(db.l_y{-1}/100)+exp(db.l_y{-2}/100)+exp(db.l_y{-3}/100));
dc.gdem_a = convert(gdem_y,'a', 'method', 'last')*100; 
% real private consumption % real GDP
cons_y = (exp(db.l_cons/100)+exp(db.l_cons{-1}/100)+exp(db.l_cons{-2}/100)+exp(db.l_cons{-3}/100))/...
    (exp(db.l_y/100)+exp(db.l_y{-1}/100)+exp(db.l_y{-2}/100)+exp(db.l_y{-3}/100));
dc.cons_a = convert(cons_y,'a', 'method', 'last')*100; 
% real private investment % real GDP
inv_y = (exp(db.l_inv/100)+exp(db.l_inv{-1}/100)+exp(db.l_inv{-2}/100)+exp(db.l_inv{-3}/100))/...
    (exp(db.l_y/100)+exp(db.l_y{-1}/100)+exp(db.l_y{-2}/100)+exp(db.l_y{-3}/100));
dc.inv_a = convert(inv_y,'a', 'method', 'last')*100;
% real exports % real GDP
exp_y = (exp(db.l_exp/100)+exp(db.l_exp{-1}/100)+exp(db.l_exp{-2}/100)+exp(db.l_exp{-3}/100))/...
    (exp(db.l_y/100)+exp(db.l_y{-1}/100)+exp(db.l_y{-2}/100)+exp(db.l_y{-3}/100));
dc.exp_a = convert(exp_y,'a', 'method', 'last')*100;
% real imports % real GDP
imp_y = (exp(db.l_imp/100)+exp(db.l_imp{-1}/100)+exp(db.l_imp{-2}/100)+exp(db.l_imp{-3}/100))/...
    (exp(db.l_y/100)+exp(db.l_y{-1}/100)+exp(db.l_y{-2}/100)+exp(db.l_y{-3}/100));
dc.imp_a = convert(imp_y,'a', 'method', 'last')*100; 

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
dc.checkNA = dc.cons_y_nom_a + dc.gdem_y_nom_a + dc.inv_y_nom_a + dc.exp_y_nom_a - dc.imp_y_nom_a - 100;

% savings (domestic, before grants) - investment, % nom.GDP (AK Oct 16 2023)
dc.psavdom_a = 100 - dc.cons_y_nom_a - dc.grev_a + dc.oexp_a; % govt oexp: transfers, interest (error: for.interest)
dc.gsavdom_a = dc.grev_a - 0.55*dc.gdem_y_nom_a - dc.oexp_a; % assume 45% nominal gdem is investment
dc.totsavdom_a  = dc.psavdom_a + dc.gsavdom_a; % nb grev, oexp are /realGDP (proxy) but cancel out in total S
dc.totinv_a  = dc.inv_y_nom_a + 0.45*dc.gdem_y_nom_a; % private: /nomGDP, govt: /realGDP

dc.tb_rat_a = convert(db.tb_rat,'a'); % resource balance in % of GDP AK 7/1

dc.dl_md_a  = convert(db.dl_md,'a'); % average 4 Q of annualized Q-on-Q growth

% debt ratios
Qshare = db.ny/(db.ny+db.ny{-1}+db.ny{-2}+db.ny{-3}); % more accurate than 1/4
% db.debt_y = (db.debt_fcy_y + db.debt_lcy_y)/4;
dc.debt_y_a = convert(db.debt_y*Qshare,'a', 'method', 'last'); % ak Oct 12 2023: divide by 4
dc.debt_fcy_a = convert(db.debt_fcy_y*Qshare,'a', 'method', 'last');
dc.debt_lcy_a = convert(db.debt_lcy_y*Qshare,'a', 'method', 'last');

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
  
  "def_a",              "Fiscal deficit before grants, % of GDP"
  "def_inc_grants_a",   "Fiscal deficit incl. grants, % of GDP"
  "grev_a",             "Govt non/tax revenue, % of real GDP" %ak 10/16
  "gdem_a",             "Govt demand G&S, % of real GDP"  
  "oexp_a",             "Govt other expenditure, % of real GDP" %ak 10/16
  "gsavdom_a",          "Govt domestic savings, % of real GDP"
  
  "pct4_s_eop",  "Exchange rate, % change end-year"
  "pct4_s_pa",   "Exchange rate, % change period-average"
  "pct4_z_pa",   "Real exchange rate, % change period average"
%   "d4l_s_eop",  "Exchange rate, % change end-year"
%   "d4l_s_pa",   "Exchange rate, % change period-average"
%   "d4l_z_pa",   "Real exchange, rate % change period average"
  
  "debt_y_a",      "Total public debt, % of GDP end-year"
  "debt_fcy_a",    "Foreign public debt, % of GDP end-year"
  "debt_lcy_a",    "Domestic public debt, % of GDP end-year"
  
  % "cons_a"          "..Real private consumption, % of real GDP"
  % "inv_a"           "..Real private investment, % of real GDP"
  % "gdem_a"          "..Real govt demand G&S, % of real GDP" 
  % "exp_a"           "..Real exports G&S, % of real GDP" 
  % "imp_a"           "..Real imports G&S, % of real GDP" 

  "cons_y_nom_a"   "Private consumption, % of GDP"
  "psavdom_a"      "....Private domestic savings, % of GDP"
  "inv_y_nom_a"    "Private investment, % of GDP"
  "gdem_y_nom_a"   "Government demand G&S, % of GDP"
  "exp_y_nom_a"    "Exports G&S, % of GDP"
  "imp_y_nom_a"    "Imports G&S, % of GDP"
  "tb_rat_a",      "Resource balance G&S, % of GDP" % AK 7/1
  "totinv_a"        "...investment, % of GDP" % AK 10/16
  "totsavdom_a"     "...-/-domestic savings, % of GDP" %
  "checkNA"         "........check NA"
  "dl_md_a",       "Annual growth money demand, in %" % AK 7/22
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
codes.utils.writeMessage("Table annualized: compiling the report ...");
codes.utils.saveReport(opts, "TableAnnualGrowth.pdf", rprt);
codes.utils.writeMessage("Table annualized: done.");

% save selected indicators for table comparizon with intMF
dc_select = databank.retrieve(dc,["pct4_y_a","dl_py_pa","pct4_cpi_eop","pct4_cpi_pa","pct4_cons_a", "pct4_cons_a", "pct4_inv_a", "pct4_gdem_a", "pct4_exp_a", "pct4_imp_a",...
    "def_a","grev_a", "gdem_a","oexp_a", "grants_y","def_inc_grants_a",...
    "pct4_s_eop", "pct4_s_pa", "pct4_z_pa","debt_y_a","debt_fcy_a","debt_lcy_a"]);

% Write results to csv format with above-specified tableRange_ann = yy(2018):yy(2026)
codes.utils.writeMessage("writing annualized results to CSV ...");
codes.utils.saveCsv(opts, "TableAnnual", dc_select);
codes.utils.writeMessage("writing annualized results to CSV done...");

