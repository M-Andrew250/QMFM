function fcast_histCharts

% MINECOFIN Quarterly Macro-Fiscal Outlook 2023-26 QuaMFO, forecast part
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
%  Highlighted range represents the past devts. before filtration range

%% For historical/past devlopments charts
% Comment or uncomment section above/below, resp.
% Change dbFcast to dbFilt.mean whole file; Filter uses dbEqDecomp,but forecast dbDecomp
%===================================================================================================================================================================================================================================
%% GDP growth decomposition by FD growth components LETS RETHINK SEE ATTEMPT
% output gap discrepancy shocks matter for past (outputgap =/= weighted sum FD gaps) but projected zero
% but output y-on-y growth rate has different discrepancy for past, zero % for projection
% we calculate discrepancy first, then include in barcon decomposition
% (d4ly_discr_shock removed from legends--it is almost zero for past/forecast
% HighRange1 = qq(2020,1) : qq(2020,4); if you want to highlight a covid region separately

figure("visible", "off");
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
  'Exports','Imports','Discrep. shock','FontSize',8, ...
  'orientation', 'horizontal', 'location', 'southoutside',...
  'interpreter', 'none');
grid on
% highlight (HighRange); %, "FaceColor", 'b');
% highlight (HighRange1, "FaceColor", 'r') % can used to highlight the COVID region
title ('Real GDP growth, YY % (d4l_y)', Interpreter='none', FontSize=12);
fileName = "GDP_growth";
codes.utils.saveEmf(opts, gcf, fileName);

%=======================================================================================================================================================================================================================================%% Final Demand (FD)
%% Output gap 

ygap_decomp = dbDecomp.l_y_gap;
figure("visible", "off");
barcon(plotRange,ygap_decomp.decompContribs{1}, ...
  'colormap', parula);
hold on
plot(plotRange, ygap_decomp.decompSeries{1}, ...
  'linewidth', 3, ...
  'color',    'w');
plot(plotRange, ygap_decomp.decompSeries{1}, ...
  'linewidth', 1, ...
  'color', 'k');
grid on
legend(ygap_decomp.legendEntries, ...
  'location', 'southoutside', ...
  'orientation', 'horizontal');
% highlight(HighRange);
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
figure("visible", "off");
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
  'location', 'southoutside', ...
  'orientation', 'horizontal');
% highlight(HighRange);
title(cons_decomp.figureName, 'FontSize',12,...
  'interpreter', 'none');
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
  'linewidth', 3, ...
  'color',    'w');
plot(plotRange, inv_decomp.decompSeries{1}, ...
  'linewidth', 1, ...
  'color',    'k');
grid on
legend(inv_decomp.legendEntries, ...
  'location', 'southoutside', ...
  'orientation', 'horizontal');
highlight(HighRange);
title(inv_decomp.figureName, 'FontSize',12,...
  'interpreter', 'none');
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
title('Inflation (CPI) & components, ann. QQ %', 'FontSize',12);
fileName = "inflation_compon";
codes.utils.saveEmf(opts, gcf, fileName);

%======================================================================================================================================================================================================================
%% CPI decomposition

figure("visible", "off");
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
%highlight(HighRange);
title ('Headline CPI, YY %', 'interpreter', 'none');
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
  'location', 'southoutside', ...
  'orientation', 'horizontal');
highlight(HighRange);
title(core_decomp.figureName, 'FontSize',12, 'interpreter', 'none');
fileName = "cpi_core_decomp";
codes.utils.saveEmf(opts, gcf, fileName);

%=========================================================================================================================================================================================================================
%% Exchange rate

% Nom exch rate (ER) and ER target depreciation
figure("visible", "on");
plot(plotRange, db.dl_s, 'linewidth', 2); %'color', 'k');
hold on
plot(plotRange, db.dl_s_tar, 'linewidth', 2); %'color', 'r'),...
  legend ('Actual', 'Target', 'interpreter', 'none','Fontsize',10,...
      'location', 'southoutside', 'orientation', 'horizontal', 'fontsize', 12);
zeroline;
%ylim ([-1,16]);
grid on
highlight(HighRange) %,'EdgeColor','m','LineWidth',1.5);
title('Exchange Rate (ER) depreciation, QQ % : Actual vs. Target', 'FontSize',12 ,'interpreter', 'none');
fileName = "ER & ER target depr";
codes.utils.saveEmf(opts, gcf, fileName);

%===========================================================================================================================================================================================================
%% RER (real exchange rate) % YoY vs RER gap, %
% RER (l_z_gap) goes to final dem thru rmci_cons, rmci_inv, rmci_exp
% RER equals nom ER + diff btn foreign inflation and dom. core inflation

figure("visible", "on");
plot(plotRange, db.dl_z, 'linewidth', 2);
hold on
plot(plotRange, db.l_z_gap, 'linewidth', 2);
plot(plotRange, db.dl_z_tnd, 'linewidth', 2);
zeroline;
grid on
highlight(HighRange); %,'EdgeColor','m','LineWidth',1.5);
legend ('Level','Gap','Trend','interpreter', 'none',...
    'location', 'southoutside', 'orientation', 'horizontal', 'fontsize', 12);
title('Real Exchange Rate (RER), QQ %', 'interpreter', 'none', 'FontSize',12);
fileName = "RER_QQ %";
codes.utils.saveEmf(opts, gcf, fileName);

%==========================================================================================================================================================================================================
%% RER components
% Generate RER components per model eq.: l_z = l_s + l_cpistar - l_cpi_core;

figure("visible", "off");
RER_compon = [db.dl_s,...
  + db.dl_cpistar,...
  - db.dl_cpi_core];
barcon(plotRange,RER_compon,'colormap', parula)
hold on
grid on
plot(plotRange, db.dl_z, 'linewidth', 3, 'color', 'w');
plot(plotRange, db.dl_z, 'linewidth', 1, 'color', 'k');
legend ('Nominal ER', 'CPI_star','CPI_core', 'interpreter','none',...
  'location', 'southoutside', 'orientation', 'horizontal', 'fontsize', 12);
%highlight(HighRange)
title('Real Exchange Rate (RER), QQ % (dl_z)', 'fontsize', 12,...
  'interpreter','none');
fileName = "RER_decomp";
codes.utils.saveEmf(opts, gcf, fileName);

%======================================================================================================================================================================================================================
%% Nominal Exhange Rate (ER) (l_s) equation decomposition

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
  'location', 'southoutside', 'orientation', 'horizontal');
%highlight(HighRange);
title(ls_decomp.figureName, 'FontSize',12,...
  'interpreter', 'none');
fileName = "ER_decomp";
codes.utils.saveEmf(opts, gcf, fileName);

%=======================================================================================================================================================================================================================
%% Interbank (IB) rate and IB rate trend

% IB trend (i_tnd) is neutral interest rate, i.e. when IB rate equals
% foreign ss real interest rate plus domestic core inflation

figure("visible", "off");
plot(plotRange, db.i,...
  'linewidth', 2);% 'color', 'b');
hold on
plot(plotRange, db.i_tnd,...
  'linewidth', 2),%'color', 'r');
hold on
plot(plotRange, dbObsTrans.obs_i_pol,...
  'linewidth', 2), %'color', 'k');
legend ('IB', 'IB trend', 'CBR', 'interpreter', 'none','Fontsize',12,...
  'location', 'southoutside', 'orientation', 'horizontal');
zeroline;
grid on
% highlight(HighRange) %,'EdgeColor','m','LineWidth',1.5);
title('Policy (IB) rate, IB trend and CBR', 'FontSize', 12); %,'interpreter', 'none');
fileName = "IB_rate_trend";
codes.utils.saveEmf(opts, gcf, fileName);

%===========================================================================================================================================================================================================================
%% IB rate (i) equation decomposition

figure("visible", "off");
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
  'orientation', 'horizontal');
%highlight(HighRange);
title(i_decomp.figureName, 'FontSize', 12,...
  'interpreter', 'none');
ylim ([-3, 8.5]);
fileName = "IB rate decomp";
codes.utils.saveEmf(opts, gcf, fileName);

%=================================================================================================================================================================================
%% AK 10/31 RIR components: generate compon per model eq. r = i - e_dl_cpi_core{+1}

figure("visible", "off");
RIR_compon = [db.i,...
  - db.e_dl_cpi_core{+1}];
barcon(plotRange,RIR_compon,'colormap', parula)
hold on
grid on
plot(plotRange, db.r, 'linewidth', 3, 'color', 'w');
plot(plotRange, db.r, 'linewidth', 1, 'color', 'k');
legend ('Nominal IB rate', 'CPI (core) expecation', 'interpreter','none',...
  'location', 'southoutside','orientation', 'horizontal', 'fontsize', 12);
%highlight(HighRange)
title('Real Interest Rate (RIR) Components, r %', 'fontsize', 12,...
  'interpreter','none');
fileName = "RIR_decomp";
codes.utils.saveEmf(opts, gcf, fileName);

%==============================================================================================================================================
%% Real market interest rates

% real lending rate, RIR trend, RIR lending, lending premium
% figure("visible", "off");
% plot(plotRange, [dbFcast.r4_gap dbFcast.r dbFcast.r_tnd dbFcast.prem_d], 'linewidth', 2);
% legend ('RIR (r4 gap)', 'RIR(IB)','RIR (IB) trend','lending premium');
% title('RIR gap, RIR rate, RIR trend (IB), lending premium, %', 'FontSize',12,...
%     'interpreter', 'none');
% highlight(HighRange);
% alternative, preferred presentation:

figure("visible", "off");
plot(plotRange, [(db.r4_gap + db.r_tnd + db.ss_prem_d) db.r_tnd + db.prem_d...
  db.r  db.r_tnd], 'linewidth', 2);
legend ('Real lending rate', 'Lending rate trend','RIR (IB)', 'RIR trend',...
    'location', 'southoutside','orientation', 'horizontal','interpreter', 'none');

title('Real lending rate and trend, RIR (IB) rate and trend, %', 'FontSize',12);
fileName = "real_int_ratesF";
codes.utils.saveEmf(opts, gcf, fileName);

%================================================================================================================================================================================
%% Fiscal indicators

% Output gap vs fiscal impulse (fisc_imp)
% Outputgap, govt demand, fiscal impulse, govt demand domestic * share GDP

figure("visible", "off");
plot(plotRange, db.l_y_gap,...
  'linewidth', 2); %, 'color', 'k');
hold on
plot(plotRange, (db.l_gdem_gap * db.w_y_gdem),...
  'linewidth', 2); %, 'color', 'r');
plot(plotRange, db.fisc_imp, 'linewidth', 2); %'color', 'b');
% plot share of gdem in GDP * Domestic share in Govt dem
% plot(plotRange, db.w_y_gdem * (1-db.lam_imp_gdem) * db.l_gdem_gap,...
%   'linewidth', 2);%, 'color', 'g');
legend ('Output gap', 'Govt demand gap', 'Fiscal impulse',... % 'Direct effect of govt demand'
  'interpreter', 'none','Fontsize', 10, 'location', 'southoutside', 'orientation', 'horizontal');
zeroline;
grid on
%highlight(HighRange) %,'EdgeColor','m','LineWidth',1.5);
title('Fiscal policy (Govt Demand & Fiscal Impulse) vs. final demand, % GDP',...
    'FontSize',12 ,'interpreter', 'none');
fileName = "outputgap_gdem_fiscimp";
codes.utils.saveEmf(opts, gcf, fileName);
%============================================================================================================================================================================================================================
%% deficit and its components 
% plot decompostions of components (structural,cyclical, discretional)

def_decomp = dbDecomp.def_y_scd;
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
highlight(HighRange);
title(def_decomp.figureName, 'FontSize', 12,...
  'interpreter', 'none');
fileName = "fiscal_deficit_decomp";
codes.utils.saveEmf(opts, gcf, fileName);
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
legend ('Govt demand','Fiscal impulse', 'interpreter', 'none','Fontsize',12,...
'location', 'southoutside', 'orientation', 'horizontal');
zeroline;
grid on
%highlight(HighRange) %,'EdgeColor','m','LineWidth',1.5);
title('Direct(Govt demand) and indirect(fiscal impulse) effects on output, % GDP', 'FontSize',12 ,'interpreter', 'none');
fileName = "outputgap_gdem_fiscimp_effects.emf";
codes.utils.saveEmf(opts, gcf, fileName);
%========================================================================================================================================================================================================
%% Fiscal impulse decompostion

fisc_decomp = dbDecomp.fisc_imp;
figure("visible", "off");
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
title(fisc_decomp.figureName, 'FontSize', 12,...
  'interpreter', 'none');
fileName = "fisc imp decomp";
codes.utils.saveEmf(opts, gcf, fileName);
%===================================================================================================================================
%% Govt demand

govDem_decomp = dbDecomp.l_gdem_gap;
figure("visible", "on");
barcon(plotRange, govDem_decomp.decompContribs{1}, ...
  'colormap', parula);
hold on
plot(plotRange, govDem_decomp.decompSeries{1}, ...
  'linewidth', 3, 'color',    'w');
plot(plotRange, govDem_decomp.decompSeries{1}, ...
  'linewidth', 1.2, 'color',    'k');
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

def_decomp = dbDecomp.gdem_y;
figure("visible", "on");
barcon(plotRange, def_decomp.decompContribs{1}, ...
  'colormap', parula);
hold on
plot(plotRange, def_decomp.decompSeries{1}, ...
  'linewidth', 3, 'color',    'w');
plot(plotRange, def_decomp.decompSeries{1}, ...
  'linewidth', 2, 'color',    'k');
grid on
legend(def_decomp.legendEntries, ...
  'location', 'southoutside', ...
  'orientation', 'horizontal');
highlight(HighRange);
title(def_decomp.figureName, 'FontSize', 12,...
  'interpreter', 'none');
fileName = "deficit decomp";
codes.utils.saveEmf(opts, gcf, fileName);

%===============================================================================================================================================================
%% some ad-hoc charts: (real) exchange and interest rates

figure("visible", "off");
plot(plotRange, [db.dl_s/4, db.dl_s_tar/4],'linewidth',2);
%highlight(HighRange)
legend 'ER depr., % QQ' 'Target ER depr., % QQ'

plot(plotRange, [db.dl_z, db.dl_s db.dl_cpi_core]);
%highlight(HighRange)
legend 'RER depr. %, QQ' 'ER depr., % QQ' 'CPI_core, % QQ'

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
title('(Real) Exchange Rate components, % YoY', 'interpreter', 'none','FontSize',12)

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
highlight(HighRange); %,'EdgeColor','m','LineWidth',1.5);
legend ('Level', 'Trend', 'interpreter', 'none','Fontsize',10,...
    'location', 'southoutside', 'orientation', 'horizontal');
title('Trading partner demand, YoY %','interpreter', 'none','FontSize',12);
fileName = "growth_ystar";
codes.utils.saveEmf(opts, gcf, fileName);
%===============================================================================================================================================================
%% int food price foodstar vs trend proxied w. CPI and rel price

figure("visible", "off");
plot(plotRange, db.d4l_foodstar,'linewidth', 2);
hold on
plot(plotRange, db.dl_cpistar + db.dl_rp_foodstar_tnd,'linewidth', 2);
zeroline;
grid on
%highlight(HighRange); %,'EdgeColor','m','LineWidth',1.5);
legend ('Level', 'Trend', 'interpreter', 'none','Fontsize',10);
title('Foreign food price (WEO), YoY %','interpreter', 'none','FontSize',12);
fileName = "foodstar_and_trend.emf";
codes.utils.saveEmf(opts, gcf, fileName);
%===========================================================================================================================================================================
%% int energy price enerstar vs trend proxied w. CPI and rel price

figure("visible", "off");
plot(plotRange, db.d4l_enerstar,'linewidth', 2);
hold on
plot(plotRange, db.dl_cpistar + db.dl_rp_enerstar_tnd,'linewidth', 2);
zeroline;
grid on
%highlight(HighRange); %,'EdgeColor','m','LineWidth',1.5);
legend ('Level', 'Trend', 'interpreter', 'none','Fontsize',10);
title('Foreign energy price (WEO), YoY %','interpreter','none','FontSize',12);
fileName = "enerstar_and_trend.emf";
codes.utils.saveEmf(opts, gcf, fileName);
%=================================================================================================================================================================================================

%% international interest rate vs trend proxied

figure("visible", "off");
% plot(plotRange, db.istar - db.e_dl_cpistar,...
% 'linewidth', 2); %foreign RIR fluctuates too much
% hold on
plot(plotRange, db.rstar_tnd,...
'linewidth', 2);
zeroline;
grid on
%highlight(HighRange); %,'EdgeColor','m','LineWidth',1.5);
legend ('Trend', 'interpreter', 'none','Fontsize',10);
title('Foreign (US) Real Interest Rate (RIR), %','interpreter', 'none','FontSize',12);
fileName = "rstar_and_trend.emf";
codes.utils.saveEmf(opts, gcf, fileName);
%=========================================================================================================================================================
%% CPI level and target 

figure("visible", "off");
% plot(plotRange, db.istar - db.e_dl_cpistar,...
% 'linewidth', 2); %foreign RIR fluctuates too much
% hold on
plot(plotRange, db.d4l_cpi, 'linewidth', 2);
hold on
plot(plotRange, db.d4l_cpi_tar, 'linewidth', 2);
zeroline;
grid on
%highlight(HighRange); %,'EdgeColor','m','LineWidth',1.5);
legend ('Level', 'Trend', 'interpreter', 'none','Fontsize',10,...
    'location', 'southoutside', 'orientation', 'horizontal');
title('Trading partner CPI, YY %','interpreter', 'none','FontSize',12);
%fileName = "rstar_and_trend.emf";
%codes.utils.saveEmf(opts, gcf, fileName);

yticks([0 2 4 6 8 10 12 14 16 18 20]);
ylim ([-1,20]);
%close all
%% Plot trend and gaps & levels
% use this section to plot all trend and gaps charts as we have in
% historical and forecast report
% Real GDP

figure("visible", "on");
plot(plotRange, db.l_y, 'linewidth', 2);
hold on
plot(plotRange, db.l_y_tnd, 'linewidth', 2);
zeroline;
grid on
highlight(HighRange); %,'EdgeColor','m','LineWidth',1.5);
legend ('Level', 'Trend', 'interpreter', 'none','Fontsize',10,...
    'location', 'southoutside', 'orientation', 'horizontal');
title('Real GDP, 100*log','interpreter', 'none','FontSize',12);

%% 
figure("visible", "on");
plot(plotRange, db.r, 'linewidth', 2);
hold on
plot(plotRange, db.r_tnd, 'linewidth', 2);
zeroline;
grid on
highlight(HighRange); %,'EdgeColor','m','LineWidth',1.5);
legend ('Level', 'Trend', 'interpreter', 'none','Fontsize',10,...
    'location', 'southoutside', 'orientation', 'horizontal');
title('"Policy real interest (IB), %"','interpreter', 'none','FontSize',12);
end