function fcast_histCharts

% MINECOFIN Quarterly Macro-Fiscal Outlook 2023-26 QMFO, forecast part
% QMFM team consisting of ES, EvM, SI, and AK, charts prepared in Jan-Feb, July-Sept 2023

%% Settings

clear, clc, close all

opts = mainSettings();

whatToPlot = "filter";
plotRange = qq(2015,1) : qq(2023,2);
HighRange = qq(2015,1) : qq(2019,4);

% whatToPlot = "forecast";
% plotRange = qq(2017,1) : qq(2027,4);
% HighRange = qq(2017,1) : qq(2023,2);
%===========================================================================================================================================================================================
%% Setup data

% The model and observed data are the same for both the history and forecast
% charts

tmp = codes.utils.loadResult(opts, "model")   ; %ak needed to read certain pars
m = tmp.m;

tmp = codes.utils.loadResult(opts, "data");
dbObsTrans = tmp.dbObsTrans;

switch whatToPlot

  case "filter"

    tmp = codes.utils.loadResult(opts, "filter");
    db = tmp.dbFilt.mean;
    dbDecomp = tmp.dbEqDecomp;

  case "forecast"

    tmp = codes.utils.loadResult(opts, "forecast");
    db = tmp.dbFcast;
    dbDecomp = tmp.dbEqDecomp;

end
%=========================================================================================================================================================================
%% For forecast charts
% Load data (observed/forecast) set, set plot/highlight ranges
% Highlighted range represents the past devts. before forecast range

%% For historical/past developments charts
% Comment or uncomment section 'case "filter"' above
% Both filterHistory and calcForecast now has name dbEqDecomp (before calcForecast used name "dbDecomp")
%===================================================================================================================================================================================================================================
%% GDP growth decomposition by FD growth components
% output gap discrepancy shocks matter for past (outputgap =/= weighted sum FD gaps) but projected at zero
% but output y-on-y growth rate has different discrepancy for past, also projected at zero
% we calculate discrepancy first, then include in barcon decomposition
% (we can remove d4ly_discr_shock from legends as almost zero for past)
% HighRange1 = qq(2020,1) : qq(2020,4); if you want to highlight Covid region separately

figure("visible", "on");
d4ly_discr_shock = db.d4l_y - (m.w_y_cons * db.d4l_cons + m.w_y_inv  * db.d4l_inv + m.w_y_gdem * db.d4l_gdem + ...
    m.w_y_exp  * db.d4l_exp - m.w_y_imp * db.d4l_imp);
d4ly_decomp = [ ...
  m.w_y_cons * db.d4l_cons, ...
  m.w_y_inv  * db.d4l_inv, ...
  m.w_y_gdem * db.d4l_gdem, ...
  m.w_y_exp  * db.d4l_exp, ...
  - m.w_y_imp * db.d4l_imp, ...
  d4ly_discr_shock];
barcon(plotRange,d4ly_decomp,'colormap', parula);
hold on
plot(plotRange, db.d4l_y, 'linewidth', 3, 'color', 'w');
plot(plotRange, db.d4l_y, 'linewidth', 1, 'color', 'k');
hold on
legend ('Consumption','Investment','Govt demand', ...
  'Exports','Imports','discrep. shock','FontSize',8, ...
  'orientation', 'vertical', 'location', 'southoutside',...
  'interpreter', 'none');
grid on
highlight (HighRange); %, "FaceColor", 'b');
% highlight (HighRange1, "FaceColor", 'r') % can used to highlight the COVID region
title ('Real GDP growth, Y-on-Y % (d4l_y)', Interpreter='none', FontSize=12);
fileName = "GDP_growth";
codes.utils.saveEmf(opts, gcf, fileName);

%=======================================================================================================================================================================================================================================%% Final Demand (FD)
%% Output gap 

ygap_decomp = dbDecomp.l_y_gap;
figure("visible", "on");
barcon(plotRange,ygap_decomp.decompContribs{1}, 'colormap', parula);
hold on
plot(plotRange, ygap_decomp.decompSeries{1}, 'linewidth', 3, 'color', 'w');
plot(plotRange, ygap_decomp.decompSeries{1}, 'linewidth', 1, 'color', 'k');
grid on
legend(ygap_decomp.legendEntries, ...
  'location',  'southoutside',...
  'orientation', 'vertical');
highlight(HighRange);
title(ygap_decomp.figureName, 'FontSize',12,...
  'interpreter', 'none');
fileName = "outputgap_decomp";
codes.utils.saveEmf(opts, gcf, fileName);

%============================================================================================================================================================================================================================
%% Consumption equation decomposition
% dbDecomp is set of equation/variables' contributions (i.e. title,legends,series,independent factors) stored in forecast
% results (read/extract from forecast.mat just to avoid a new generation of equation)
% dbdecomp stores decompContribs{1}(independent components and decompSeries(dependent var--l_cons_gap)
% legendEntries (all eq. legends),figureName (title of variable)

cons_decomp = dbDecomp.l_cons_gap;
figure("visible", "on");
barcon(plotRange,cons_decomp.decompContribs{1}, ...
  'colormap', parula);
hold on
plot(plotRange, cons_decomp.decompSeries{1}, ...
  'linewidth', 3, ...
  'color',    'w');
plot(plotRange, cons_decomp.decompSeries{1}, ...
  'linewidth', 1, ...
  'color', 'k');
grid on
legend(cons_decomp.legendEntries, ...
    'location', 'southoutside', 'orientation', 'vertical');
% highlight(HighRange);
title(cons_decomp.figureName, 'FontSize',12, 'interpreter', 'none');
fileName = "cons_decomp";
codes.utils.saveEmf(opts, gcf, fileName);

%==========================================================================================================================================================================================================================================
%% Investment equation decomposition
% one can replace l_inv_gap with e.g. l_gdem_gap,  l_exp_gap or l_imp_gap(remember to
% exchange inv_decomp with gdem_decomp, exp_decomp or imp_decomp) to plot other components

inv_decomp = dbDecomp.l_inv_gap;
figure("visible", "on");
barcon(plotRange,inv_decomp.decompContribs{1}, ...
  'colormap', parula);
hold on
plot(plotRange, inv_decomp.decompSeries{1}, ...
  'linewidth', 3, 'color',    'w');
plot(plotRange, inv_decomp.decompSeries{1}, ...
  'linewidth', 1, 'color',    'k');
grid on
legend(inv_decomp.legendEntries, ...
  'location', 'southoutside', 'orientation', 'vertical');
%highlight(HighRange);
title(inv_decomp.figureName, 'FontSize',12,'interpreter', 'none');
fileName = "inv_decomp";
codes.utils.saveEmf(opts, gcf, fileName);

%=========================================================================================================================================================================================================================
%% Inflation (cpi)
% Components of headline inflation: core, food and energy inflation series

figure("visible", "on");
plot(plotRange, db.dl_cpi, 'linewidth', 2 );%, 'color', 'r');
hold on
plot(plotRange, db.dl_cpi_core, 'linewidth', 2);%, 'color', 'b'),...
plot(plotRange, db.dl_cpi_food, 'linewidth', 2);%, 'color', 'g'),...
plot(plotRange, db.dl_cpi_ener,'linewidth', 2);%, 'color', 'y'),...
legend ('Headline','Core','Food', 'Energy','interpreter', 'none','Fontsize',12,...
  'orientation', 'horizontal', 'location', 'southoutside',...
  'interpreter', 'none');
zeroline;
grid on
highlight(HighRange) %,'EdgeColor','m','LineWidth',1.5);
title('Inflation (CPI) & components, annualized Q-on-Q %', 'FontSize',12);
fileName = "inflation_compon";
codes.utils.saveEmf(opts, gcf, fileName);

%======================================================================================================================================================================================================================
%% CPI decomposition

figure("visible", "on");
cpi_discr_shock = db.d4l_cpi - (m.w_core * db.d4l_cpi_core + m.w_food * db.d4l_cpi_food + m.w_ener * db.d4l_cpi_ener);
d4l_cpi_decomp = [m.w_core * db.d4l_cpi_core,...
  m.w_food * db.d4l_cpi_food,...
  m.w_ener * db.d4l_cpi_ener,...
  cpi_discr_shock];
barcon(plotRange,d4l_cpi_decomp, 'colormap', parula);
hold on
plot(plotRange, db.d4l_cpi, 'color', 'w', 'linewidth', 3);
plot(plotRange, db.d4l_cpi, 'color', 'k', 'linewidth', 1)
legend ('Core', 'Food' ,'Energy', 'Discrep. shock',...
  'orientation', 'horizontal', 'location', 'southoutside', 'fontsize', 12);
highlight(HighRange);
title ('Headline CPI, Y-on-Y %', 'fontsize', 12, 'interpreter', 'none');
grid on
fileName = "cpi_decomp";
codes.utils.saveEmf(opts, gcf, fileName);
%=============================================================================================================================================================================
%% Core inflation equation decomposition (and similar for food, energy)
% paste 'food' or 'ener' to replace 'core', e.g. replace dbDecomp.dl_cpi_core with dbDecomp.dl_cpi_food

figure("visible", "on");
core_decomp = dbDecomp.dl_cpi_core;
barcon(plotRange,core_decomp.decompContribs{1}, ...
  'colormap', parula);
hold on
plot(plotRange,core_decomp.decompSeries{1}, ...
  'linewidth', 3, 'color', 'w');
plot(plotRange,core_decomp.decompSeries{1}, ...
  'linewidth', 1, 'color',    'k');
grid on
legend(core_decomp.legendEntries, ...
  'location', 'southoutside', 'orientation', 'horizontal');
highlight(HighRange);
title(core_decomp.figureName, 'FontSize',12, 'interpreter', 'none');
fileName = "cpi_core_decomp";
codes.utils.saveEmf(opts, gcf, fileName);

%=========================================================================================================================================================================================================================
%% Exchange rate

% Nominal exchange rate (ER) and ER target depreciation
figure("visible", "on");
plot(plotRange, db.dl_s, 'linewidth', 2); %'color', 'k');
hold on
plot(plotRange, db.dl_s_tar, 'linewidth', 2); %'color', 'r'),...
  legend ('ER depreciation', 'target ER depreciation', 'interpreter', 'none','Fontsize',10,...
      'location', 'southoutside', 'orientation', 'horizontal', 'fontsize', 12);
zeroline;
ylim ([-1,16]);
grid on
highlight(HighRange) %,'EdgeColor','m','LineWidth',1.5);
title('Exchange Rate (ER) depreciation: Actual vs. Target, Q-on-Q %', 'FontSize',12 ,'interpreter', 'none');
fileName = "ER & ER target depr";
codes.utils.saveEmf(opts, gcf, fileName);

%===========================================================================================================================================================================================================
%% RER (real exchange rate) YoY vs RER gap, %
% RER (l_z_gap) goes to final demand thru rmci_cons, rmci_inv, rmci_exp
% RER equals nom ER + diff between foreign inflation and dom. core inflation

figure("visible", "on");
plot(plotRange, db.dl_z, 'linewidth', 2, 'color', 'k'); %match color with next chart
hold on
plot(plotRange, db.dl_z_tnd, 'linewidth', 2);
plot(plotRange, db.l_z_gap, 'linewidth', 2);
zeroline;
grid on
highlight(HighRange); %,'EdgeColor','m','LineWidth',1.5);
legend ('RER, ann. Q-on-Q %','RER trend, ann. Q-on-Q %', 'RER gap %', 'interpreter', 'none',...
    'location', 'southoutside', 'orientation', 'vertical', 'fontsize', 12);
title('RER depreciation rate vs its trend and RER gap, %', 'interpreter', 'none', 'FontSize',12);
fileName = "RER_QQ %";
codes.utils.saveEmf(opts, gcf, fileName);

%==========================================================================================================================================================================================================
%% RER components
% Generate RER components per model eq.: l_z = l_s + l_cpistar - l_cpi_core;

figure("visible", "on");
RER_compon = [db.dl_s,...
  + db.dl_cpistar,...
  - db.dl_cpi_core];
barcon(plotRange,RER_compon,'colormap', parula)
hold on
grid on
plot(plotRange, db.dl_z, 'linewidth', 1, 'color', 'k');
legend ('Nominal ER', 'CPI_star','CPI_core', 'interpreter','none',...
  'location', 'southoutside', 'orientation', 'horizontal', 'fontsize', 12);
highlight(HighRange)
title('Real Exchange Rate components, Q-on-Q % (dl_z)', 'fontsize', 12,...
  'interpreter','none');
fileName = "RER_decomp";
codes.utils.saveEmf(opts, gcf, fileName);

%======================================================================================================================================================================================================================
%% Nominal Exchange Rate (ER) (l_s) equation decomposition

figure("visible", "on");
ls_decomp = dbDecomp.l_s;
barcon(plotRange,ls_decomp.decompContribs{1}, ...
  'colormap', parula);
hold on
plot(plotRange,ls_decomp.decompSeries{1}, ...
  'linewidth', 3, 'color',    'w');
plot(plotRange,ls_decomp.decompSeries{1}, ...
  'linewidth', 1, 'color', 'k');
grid on
legend(ls_decomp.legendEntries, ...
  'location', 'southoutside', 'orientation', 'vertical');
highlight(HighRange);
title(ls_decomp.figureName, 'FontSize',12,...
  'interpreter', 'none');
fileName = "ER_decomp";
codes.utils.saveEmf(opts, gcf, fileName);
%====================================================================================================================
%% target Nominal Exchange Rate (ER) (dl_s_tar) equation decomposition

figure("visible", "on");
ls_decomp = dbDecomp.dl_s_tar;
barcon(plotRange,ls_decomp.decompContribs{1}, ...
  'colormap', parula);
hold on
plot(plotRange,ls_decomp.decompSeries{1}, ...
  'linewidth', 3, 'color',    'w');
plot(plotRange,ls_decomp.decompSeries{1}, ...
  'linewidth', 1, 'color', 'k');
grid on
legend(ls_decomp.legendEntries, ...
  'location', 'southoutside', 'orientation', 'vertical');
highlight(HighRange);
title(ls_decomp.figureName, 'FontSize',12,...
  'interpreter', 'none');
fileName = "ER_tar_decomp";
codes.utils.saveEmf(opts, gcf, fileName);

%=======================================================================================================================================================================================================================
%% Interbank (IB) rate and IB rate trend (i_tnd)
% IB trend (neutral) interest rate = foreign ss real interest rate + domestic core inflation+exp RERdepr
figure("visible", "on");
plot(plotRange, db.i,...
  'linewidth', 2);% 'color', 'b'); %match blue color of IB with chart below
hold on
plot(plotRange, db.i_tnd,...
  'linewidth', 2),%'color', 'r');
hold on
plot(plotRange, dbObsTrans.obs_i_pol,...
  'linewidth', 2), %'color', 'k');
plot(plotRange, dbObsTrans.obs_i_repo,...
  'linewidth', 2), %'color', 'k');
legend ('IB rate', 'IB rate trend', 'CBR', 'Repo rate', 'interpreter', 'none','Fontsize',12,...
  'location', 'southoutside', 'orientation', 'horizontal');
zeroline;
grid on
highlight(HighRange) %,'EdgeColor','m','LineWidth',1.5);
title('Interbank (IB) rate, IB trend and CBR', 'FontSize', 12); %,'interpreter', 'none');
fileName = "IB_rate_trend";
codes.utils.saveEmf(opts, gcf, fileName);

%===========================================================================================================================================================================================================================
%% IB rate (i) equation decomposition

figure("visible", "on");
i_decomp = dbDecomp.i;
barcon(plotRange,i_decomp.decompContribs{1}, ...
  'colormap', parula);
hold on
plot(plotRange,i_decomp.decompSeries{1}, ...
  'linewidth', 3,'color',    'w');
plot(plotRange, i_decomp.decompSeries{1}, ...
  'linewidth', 1, 'color',    'k');
grid on
legend(i_decomp.legendEntries, ...
  'location', 'southoutside', ...
  'orientation', 'vertical');
highlight(HighRange);
title(i_decomp.figureName, 'FontSize', 12,...
  'interpreter', 'none');
ylim ([-3, 8.5]);
fileName = "IB rate decomp";
codes.utils.saveEmf(opts, gcf, fileName);

%===================================================================================================================================
%% RIR components: IB rate minus Exp.CPI_core{+1} gives RIR(IB)
% RIR affects final demand thru r4_gap incl. rmci_cons, rmci_inv & rmci_exp

figure("visible", "on");
plot(plotRange, db.i, 'linewidth', 2); % 'color', 'b'); %match blue color of IB with chart above
hold on
plot(plotRange, db.e_dl_cpi_core, 'linewidth', 2); % 'color', 'r');
hold on
plot(plotRange, db.r, 'linewidth', 2, 'color', 'k');
legend ('IB rate', 'CPI_core{+1}','RIR(IB)', 'interpreter', 'none','Fontsize',12,...
  'location', 'southoutside',...
  'orientation', 'horizontal');
zeroline;
grid on
highlight(HighRange) %,'EdgeColor','m','LineWidth',1.5);
title('Interbank (IB) rate, Expected CPI and RIR', 'FontSize',12,...
  'interpreter', 'none');
fileName = "IB_core_RIR";
codes.utils.saveEmf(opts, gcf, fileName);

%=================================================================================================================================================================================
%% AK 10/31 RIR components: generate compon per model eq. r = i - e_dl_cpi_core{+1}

figure("visible", "on");
RIR_compon = [db.i,...
  - db.e_dl_cpi_core]; % this should not be {+1}, already expected
barcon(plotRange,RIR_compon,'colormap', parula)
hold on
grid on
plot(plotRange, db.r, 'linewidth', 1, 'color', 'k');
legend ('Interbank (IB) rate', 'CPI_core{+1}', 'interpreter','none',...
  'location', 'southoutside',...
  'orientation', 'horizontal', 'fontsize', 12);
highlight(HighRange)
title('RIR components, % (r)', 'fontsize', 12,...
  'interpreter','none');
fileName = "RIR_decomp";
codes.utils.saveEmf(opts, gcf, fileName);

%==============================================================================================================================================
%% Real market interest rates
% real lending rate gap, RIR trend, RIR lending, lending premium
% figure("visible", "off");
% plot(plotRange, [db.r4_gap db.r db.r_tnd db.prem_d], 'linewidth', 2);
% legend ('real lending rate gap', 'RIR(IB)','RIR (IB) trend','lending premium');
% title('Real lending rate gap, RIR rate, RIR trend (IB), lending premium, %', 'FontSize',12,...
%     'interpreter', 'none');
% highlight(HighRange);
% alternative, preferred presentation:

figure("visible", "on");
plot(plotRange, [(db.r4_gap + db.r_tnd + db.ss_prem_d) db.r_tnd + db.prem_d...
  db.r  db.r_tnd], 'linewidth', 2);
legend ('Real lending rate', 'Real lending rate trend','RIR (IB)', 'RIR trend',...
    'location', 'southoutside','orientation', 'horizontal','interpreter', 'none');

title('Real lending rate and trend, RIR (IB) rate and trend, %', 'FontSize',12);
fileName = "real_int_ratesF";
codes.utils.saveEmf(opts, gcf, fileName);

%================================================================================================================================================================================
%% Fiscal indicators
% Output gap, govt demand gap, fiscal impulse; govt demand domestic * share GDP

figure("visible", "on");
plot(plotRange, db.l_y_gap,...
  'linewidth', 2); %, 'color', 'k');
hold on
plot(plotRange, (db.l_gdem_gap * db.w_y_gdem),...
  'linewidth', 2); %, 'color', 'r');
plot(plotRange, db.fisc_imp, 'linewidth', 2); %'color', 'b');
% plot share of gdem in GDP * domestic share in Govt dem
% plot(plotRange, db.w_y_gdem * (1-db.lam_imp_gdem) * db.l_gdem_gap,...
%   'linewidth', 2);%, 'color', 'g');
legend ('Output gap', 'Govt demand gap', 'Fiscal impulse',... % 'Direct effect of govt demand'
  'interpreter', 'none','Fontsize', 10, 'location', 'southoutside', 'orientation', 'vertical');
zeroline;
grid on
highlight(HighRange) %,'EdgeColor','m','LineWidth',1.5);
title('Output gap, govt demand gap and fiscal impulse, in % of GDP',...
    'FontSize', 12 ,'interpreter', 'none');
fileName = "outputgap_gdem_fiscimp";
codes.utils.saveEmf(opts, gcf, fileName);
%============================================================================================================================================================================================================================
%% Fiscal impulse (fisc_imp) effect on output cpd with gdem effect on output
% Fiscal impulse effect on cons-inv and govt demand impact on output (GDP and import shares!)

figure ("visible", "on");
plot(plotRange, (db.l_gdem_gap * db.w_y_gdem * (1-db.lam_imp_gdem)),...
'linewidth', 2);%, 'color', 'r');
hold on
plot(plotRange, db.fisc_imp * (db.a5_cons * (1-db.lam_imp_cons) * db.w_y_cons...
    + db.a5_inv * (1-db.lam_imp_inv) * db.w_y_inv),...
'linewidth', 2); %, 'color', 'b');
hold on
% % plot govt demand gap itself
% plot(plotRange, db.l_gdem_gap,'linewidth', 2, 'color', 'g');
legend ('Govt demand (direct)','Private demand (indirect)',...
  'interpreter', 'none','Fontsize',12,...
'location', 'southoutside', 'orientation', 'horizontal');
zeroline;
grid on
%highlight(HighRange) %,'EdgeColor','m','LineWidth',1.5);
title('Fiscal stance: effect of govt & private demand on output, % GDP', 'FontSize',12 ,'interpreter', 'none');
fileName = "outputgap_gdem_fiscimp_effects";
codes.utils.saveEmf(opts, gcf, fileName);
%========================================================================================================================================================================================================
%% Fiscal impulse decomposition (deficit affecting private demand, indirect effect on output)

fisc_decomp = dbDecomp.fisc_imp;
figure("visible", "on");
barcon(plotRange, fisc_decomp.decompContribs{1}, ...
  'colormap', parula);
hold on
plot(plotRange, fisc_decomp.decompSeries{1}, ...
  'linewidth', 3, 'color',    'w');
plot(plotRange, fisc_decomp.decompSeries{1}, ...
  'linewidth', 1, 'color',    'k');
grid on
legend(fisc_decomp.legendEntries, ...
  'location', 'southoutside', ...
  'orientation', 'horizontal');
%highlight(HighRange);
title('Fiscal impulse components, % of GDP', 'FontSize', 12,...
  'interpreter', 'none');
fileName = "fisc imp decomp";
codes.utils.saveEmf(opts, gcf, fileName);
%===================================================================================================================================
%% Govt demand for G&S decomposition (direct effect on output)

figure("visible", "on");
govDem_decomp = dbDecomp.l_gdem_gap; % not dbDecomp.l_gdem does not exist

barcon(plotRange, govDem_decomp.decompContribs{1}, ...
  'colormap', parula);
hold on
plot(plotRange, govDem_decomp.decompSeries{1}, ...
  'linewidth', 3, 'color',    'w');
plot(plotRange, govDem_decomp.decompSeries{1}, ...
  'linewidth', 1, 'color',    'k');
grid on
legend(govDem_decomp.legendEntries, ...
  'location', 'southoutside', ...
  'orientation', 'horizontal');
%highlight(HighRange);
title(govDem_decomp.figureName, 'FontSize', 12,...
  'interpreter', 'none');
fileName = "govt dem decomp";
codes.utils.saveEmf(opts, gcf, fileName);
%===============================================================================================================================
%% Budget decifit decompositions

def_decomp = dbDecomp.def_y_scd; % can also do def_y_scd, def_y_cyc, def_y_str, def_y_discr
figure("visible", "on");
barcon(plotRange, def_decomp.decompContribs{1}, ...
  'colormap', parula);
hold on
plot(plotRange, def_decomp.decompSeries{1}, ...
  'linewidth', 3, 'color',    'w');
plot(plotRange, def_decomp.decompSeries{1}, ...
  'linewidth', 1, 'color',    'k');
grid on
legend(def_decomp.legendEntries, ...
  'location', 'southoutside', ...
  'orientation', 'horizontal');
%highlight(HighRange);
title(def_decomp.figureName, 'FontSize', 12,...
  'interpreter', 'none');
fileName = "deficit decomp";
codes.utils.saveEmf(opts, gcf, fileName);

%===============================================================================================================================================================
%% some ad-hoc charts: (real) exchange and interest rates

figure("visible", "on");
plot(plotRange, [db.dl_s/4, db.dl_s_tar/4],'linewidth',2);
%highlight(HighRange)
legend 'ER depr. Q-on-Q' 'Target ER depr. Q-on-Q %'

plot(plotRange, [db.dl_z, db.dl_s db.dl_cpi_core]);
%highlight(HighRange)
legend 'RER depr. Q-on-Q %' 'ER depr. Q-on-Q %' 'CPI-core, Q-on-Q %'

% strictly speaking, interest shown must be calculated back: exp(i/100)*100-100
plot(plotRange, [db.r, db.i, db.dl_cpi_core{+1} ],'linewidth', 2);
%highlight(HighRange);
legend 'RIR' 'IB interest' 'CPI-core(+1)';

plot(plotRange, [db.i db.i_tnd], 'linewidth', 2);
legend 'IB interest' 'Trend';

plot(plotRange, [db.d4l_cpistar db.d4l_z db.d4l_s db.d4l_cpi_core],'linewidth', 2);
%highlight(HighRange);
legend ('Foreign CPI', 'RER', 'Nominal ER', 'CPI core','interpreter', 'none','Fontsize',10,...
'location', 'southoutside', 'orientation', 'horizontal');
title('Real Exchange Rate components, Y-on-Y %', 'interpreter', 'none','FontSize',12)

%====================================================================================================================0=================================
%% Foreign GDP and demand (trading partners, WEO-GAS)

figure("visible", "on");
help = db.l_ystar_gap + dbObsTrans.obs_l_ystar_tnd;
d4l_ystar = help - help{-4};
help  = dbObsTrans.obs_l_ystar_tnd;
d4l_ystar_tnd = help - help{-4};
plot(plotRange, d4l_ystar,'linewidth', 2);
hold on
plot(plotRange, d4l_ystar_tnd,...
  'linewidth', 2);
zeroline;
grid on
%highlight(HighRange); %,'EdgeColor','m','LineWidth',1.5);
legend ('Foreign demand growth, Y-on-Y %', 'Trend', 'interpreter', 'none','Fontsize',10,...
     'location', 'southoutside', 'orientation', 'horizontal');

title('Trading partner demand vs trend, Y-on-Y growth %','interpreter', 'none','FontSize',12);
fileName = "growth_ystar";
codes.utils.saveEmf(opts, gcf, fileName);
%===============================================================================================================================================================
%% int food price foodstar vs trend proxied w. CPI and rel price

figure("visible", "on");
plot(plotRange, db.d4l_foodstar,'linewidth', 2);
hold on
plot(plotRange, db.dl_cpistar + db.dl_rp_foodstar_tnd,'linewidth', 2);
zeroline;
grid on
%highlight(HighRange); %,'EdgeColor','m','LineWidth',1.5);
legend ('Foreign food price, Y-on-Y change in %', 'Trend', 'interpreter', 'none','Fontsize',10);
title('Foreign food price (WEO) vs trend, Y-on-Y change in %','interpreter', 'none','FontSize',12);
fileName = "foodstar_and_trend.emf";
codes.utils.saveEmf(opts, gcf, fileName);
%===========================================================================================================================================================================
%% int energy price enerstar vs trend proxied w. CPI and rel price

figure("visible", "on");
plot(plotRange, db.d4l_enerstar,'linewidth', 2);
hold on
plot(plotRange, db.dl_cpistar + db.dl_rp_enerstar_tnd,'linewidth', 2);
zeroline;
grid on
%highlight(HighRange); %,'EdgeColor','m','LineWidth',1.5);
legend ('Foreign energy price, Y-on-Y change in %', 'Trend', 'interpreter', 'none','Fontsize',10);
title('Foreign energy price (WEO) vs trend, Y-on-Y change in %','interpreter','none','FontSize',12);
fileName = "enerstar_and_trend.emf";
codes.utils.saveEmf(opts, gcf, fileName);
%=================================================================================================================================================================================================
%% international interest rate vs trend proxied

figure("visible", "on");
plot(plotRange, db.istar - db.e_dl_cpistar,'linewidth', 2); %foreign RIR fluctuates a lot
hold on
plot(plotRange, db.rstar_tnd,'linewidth', 2);
zeroline;
grid on
highlight(HighRange); %,'EdgeColor','m','LineWidth',1.5);
legend ('Foreign RIR %', 'Trend', 'interpreter', 'none', 'Fontsize', 10);
title('Foreign real interest rate vs trend (US), %','interpreter', 'none','FontSize',12);
fileName = "rstar_and_trend.emf";
codes.utils.saveEmf(opts, gcf, fileName);
%=========================================================================================================================================================
%% Rwanda trading partner CPI

series = db.d4l_cpistar + db.ss_dl_cpistar - db.d4l_cpistar;% show ss trend
figure("visible", "on");
plot(plotRange, db.d4l_cpistar, 'linewidth', 2);
hold on
plot(plotRange, series, 'linewidth', 2);
hold on
grid on
highlight(HighRange); %,'EdgeColor','m','LineWidth',1.5);
legend ('trading partner CPI, Y-on-Y change in %', 'ss trend',  'interpreter', 'none','Fontsize',10,...
    'location', 'southoutside', 'orientation', 'horizontal');
title('Trading partner CPI, Y-on-Y change, in %', 'interpreter', 'none','FontSize',12);
fileName = "cpistar.emf";
codes.utils.saveEmf(opts, gcf, fileName);

% yticks([0 2 4 6 8 10 12 14 16 18 20]);
% ylim ([-1,20]);
%close all
end