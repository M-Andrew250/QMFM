% MINECOFIN Quarterly Macro-Fiscal Outlook 2023-26 QuaMFO, forecast part
% QMFM team consisting of ES, EvM, SI, and AK, charts prepared in Jan-Feb, July-Sept 2023

%% Settings

clear, clc, close all

% whatToPlot = "filter";
% plotRange = qq(2015,1) : qq(2023,1);
% HighRange = qq(2015,1) : qq(2019,4);

whatToPlot = "forecast";
plotRange = qq(2017,1) : qq(2027,4);
HighRange = qq(2017,1) : qq(2023,1);

%% Setup data

% The model and observed data are the same for both the history and forecast
% charts

tmp = load("results/model.mat"); %ak needed to read certain pars
m = tmp.m;

tmp = load("results/data.mat");
dbObsTrans = tmp.dbObsTrans;

switch whatToPlot

  case "filter"

    tmp = load("results/Filter.mat");
    db = tmp.dbFilt.mean;
    dbDecomp = tmp.dbEqDecomp;

  case "forecast"

    tmp = load("results/forecast.mat");
    db = tmp.dbFcast;
    dbDecomp = tmp.dbDecomp;

end

%% For forecast charts
% Load data (observed/forecast) set, set plot/highlight ranges
%  Highlighted range represents the past devts. before filtration range


%% For historical/past devlopments charts
% Comment or uncomment section above/below, resp.
% Change dbFcast to dbFilt.mean whole file; Filter uses dbEqDecomp,but forecast dbDecomp

%===================================================================================================================================================================================================================================
%% GDP growth decomposition by FD growth components LETS RETHINK SEE ATTEMPT
% output gap discrepancy shocks matter for past (outputgap =/= weighted sum FDgaps) but projected zero
% but output y-on-y growth rate has different discrepancy for past, zero % for projection
% we calculate discrepancy first, then include in barcon decomposition
% (d4ly_discr_shock removed from legends--it is almost zero for past/forecast
figure("visible", "off");
d4ly_discr_shock = db.d4l_y - (m.w_y_cons * db.d4l_cons + m.w_y_inv  * db.d4l_inv + m.w_y_gdem * db.d4l_gdem + m.w_y_exp  * db.d4l_exp -  m.w_y_imp * db.d4l_imp);
d4ly_decomp = [ ...
  m.w_y_cons * db.d4l_cons, ...
  m.w_y_inv  * db.d4l_inv, ...
  m.w_y_gdem * db.d4l_gdem, ...
  m.w_y_exp  * db.d4l_exp ...
  - m.w_y_imp * db.d4l_imp,...
  d4ly_discr_shock];
barcon(plotRange,d4ly_decomp,'colormap', parula);
hold on
plot(plotRange, db.d4l_y, 'linewidth', 3, 'color', 'w');
plot(plotRange, db.d4l_y, 'linewidth', 1, 'color', 'k');
hold on
legend ('Consumption','Investment','Govt demand', ...
  'Exports','Imports','FontSize',8, ...
  'orientation', 'horizontal', 'location', 'southoutside',...
  'interpreter', 'none');
grid on
highlight(HighRange);
title ('GDP growth, Y-on-Y %');
exportgraphics(gcf, 'graphs/GDP_growth.emf');
%=======================================================================================================================================================================================================================================
%% Final Demand (FD)
% Consumption equation decomposition
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
  'linewidth', 2, ...
  'color',    'k');
grid on
legend(cons_decomp.legendEntries, ...
  'location', 'southoutside', ...
  'orientation', 'horizontal');
highlight(HighRange);
title(cons_decomp.figureName, 'FontSize',12,...
  'interpreter', 'none');
exportgraphics(gcf, 'graphs/cons_decomp.emf');
%==========================================================================================================================================================================================================================================
%% Investment equation decomposition
% one can replace l_inv_gap with e.g. l_gdem_gap,  l_exp_gap or l_imp_gap(remember to
% exchange inv_decomp with gdem_decomp, exp_decomp or imp_decomp) to plot other components
inv_decomp = dbDecomp.l_inv_gap;
figure("visible", "off");
barcon(plotRange,inv_decomp.decompContribs{1}, ...
  'colormap', parula);
hold on
plot(plotRange, inv_decomp.decompSeries{1}, ...
  'linewidth', 3, ...
  'color',    'w');
plot(plotRange, inv_decomp.decompSeries{1}, ...
  'linewidth', 2, ...
  'color',    'k');
grid on
legend(inv_decomp.legendEntries, ...
  'location', 'southoutside', ...
  'orientation', 'horizontal');
highlight(HighRange);
title(inv_decomp.figureName, 'FontSize',12,...
  'interpreter', 'none');
exportgraphics(gcf, 'graphs/inv_decomp.emf');
%=========================================================================================================================================================================================================================
%% Inflation (cpi)
% Components of headline inflation: core, food and energy inflation series
figure("visible", "off");
plot(plotRange, db.dl_cpi,...
  'linewidth', 2,...
  'color', 'r');
hold on
plot(plotRange, db.dl_cpi_core,...
  'linewidth', 2,...
  'color', 'b'),...
  plot(plotRange, db.dl_cpi_food,...
  'linewidth', 2,...
  'color', 'g'),...
  plot(plotRange, db.dl_cpi_ener,...
  'linewidth', 2,...
  'color', 'y'),...
  legend ('Headline','Core','Food', 'Energy','interpreter', 'none','Fontsize',10);
zeroline;
grid on
highlight(HighRange) %,'EdgeColor','m','LineWidth',1.5);
title('CPI Inflation, ann. Q-on-Q %', 'FontSize',12);
exportgraphics(gcf, 'graphs/inflation_compon.emf');
%======================================================================================================================================================================================================================
%% CPI decomposition
figure("visible", "off");
discr_shock = db.d4l_cpi - (m.w_core * db.d4l_cpi_core + m.w_food * db.d4l_cpi_food + m.w_ener * db.d4l_cpi_ener);
d4l_cpi_decomp = [m.w_core * db.d4l_cpi_core,...
  m.w_food * db.d4l_cpi_food,...
  m.w_ener * db.d4l_cpi_ener,...
  discr_shock];
barcon(plotRange,d4l_cpi_decomp, 'colormap', parula);
hold on
plot(plotRange, db.d4l_cpi, 'color', 'w', 'linewidth', 3);
plot(plotRange, db.d4l_cpi, 'color', 'k', 'linewidth', 2)
legend ('Core', 'Food' ,'Energy', 'Discr_shock',...
  'orientation', 'horizontal', 'location', 'southoutside',...
  'interpreter', 'none')
highlight(HighRange);
title ('CPI Inflation (d4l_cpi) decomposition', 'interpreter', 'none');
grid on
exportgraphics(gcf, 'graphs/cpi_decomp.png');
%% Core inflation equation decomposition (and similar for food, energy)
% paste 'food' or 'ener' to replace 'core', e.g. replace dbDecomp.dl_cpi_core with dbDecomp.dl_cpi_food
core_decomp = dbDecomp.dl_cpi_core;
figure("visible", "off");
barcon(plotRange,core_decomp.decompContribs{1}, ...
  'colormap', parula);
hold on
plot(plotRange,core_decomp.decompSeries{1}, ...
  'color',    'w');
plot(plotRange,core_decomp.decompSeries{1}, ...
  'linewidth', 2, ...
  'color',    'k');
grid on
legend(core_decomp.legendEntries, ...
  'location', 'southoutside', ...
  'orientation', 'horizontal');
highlight(HighRange);
title(core_decomp.figureName, 'FontSize',12,...
  'interpreter', 'none');
exportgraphics(gcf, 'graphs/cpi_core_decomp.emf');
%=========================================================================================================================================================================================================================
%% Exchange rate
% Nom exch rate (ER) and ER target depreciation
figure("visible", "off");
plot(plotRange, db.dl_s,...
  'linewidth', 2,...
  'color', 'k');
hold on
plot(plotRange, db.dl_s_tar,...
  'linewidth', 2,...
  'color', 'r'),...
  legend ('QoQ_ER_depr.', 'QoQ_ER_depr.tar', 'interpreter', 'none','Fontsize',10);
zeroline;
grid on
highlight(HighRange) %,'EdgeColor','m','LineWidth',1.5);
title('Exchange rate depreciation: Actual vs. Target, Q-on-Q %', 'FontSize',12); %,'interpreter', 'none');
exportgraphics(gcf, 'graphs/ER & ER target depr.emf');
%===========================================================================================================================================================================================================
%% RER (real exchange rate) % YoY vs RER gap, %
% RER (l_z_gap) goes to final dem thru rmci_cons, rmci_inv, rmci_exp
% RER equals nom ER + diff btn foreign inflation and dom. core inflation
figure("visible", "off");
plot(plotRange, db.d4l_z,...
  'linewidth', 2);
hold on
plot(plotRange, db.l_z_gap,...
  'linewidth', 2);
zeroline;
grid on
highlight(HighRange); %,'EdgeColor','m','LineWidth',1.5);
legend ('RER, % YoY','RER gap, %','interpreter', 'none','Fontsize',10);
title('Real exchange rate and RER gap, Y-on-Y %','interpreter', 'none','FontSize',12);
exportgraphics(gcf, 'graphs/RER_yoy.emf');
%==========================================================================================================================================================================================================
% RER components
% Generate RER components per model eq.: l_z = l_s + l_cpistar - l_cpi_core;
figure("visible", "off");
RER_compon = [db.dl_s,...
  + db.dl_cpistar,...
  - db.dl_cpi_core];
barcon(plotRange,RER_compon,'colormap', parula)
hold on
grid on
%plot(plotRange, dbFcast.dl_z, 'linewidth', 3, 'color', 'w');
plot(plotRange, db.dl_z, 'linewidth', 2, 'color', 'r');
legend ('Nom_ER', 'CPI_star','CPI_core', 'interpreter','none',...
  'location', 'southoutside',...
  'orientation', 'horizontal', ...
  'fontsize', 12);
highlight(HighRange)
title('RER components, Q-on-Q % (dl_z)', 'fontsize', 12,...
  'interpreter','none');
exportgraphics(gcf, 'graphs/RER_decomp.emf');
%======================================================================================================================================================================================================================
% Nominal ER (l_s) equation decomposition
ls_decomp = dbDecomp.l_s;
figure("visible", "off");
barcon(plotRange,ls_decomp.decompContribs{1}, ...
  'colormap', parula);
hold on
plot(plotRange,ls_decomp.decompSeries{1}, ...
  'linewidth', 3, ...
  'color',    'w');
plot(plotRange,ls_decomp.decompSeries{1}, ...
  'linewidth', 2, ...
  'color', 'k');
grid on
legend(ls_decomp.legendEntries, ...
  'location', 'southoutside', ...
  'orientation', 'horizontal');
highlight(HighRange);
title(ls_decomp.figureName, 'FontSize',12,...
  'interpreter', 'none');
exportgraphics(gcf, 'graphs/ER_decomp.emf');
%=======================================================================================================================================================================================================================
% Interbank (IB) rate and IB rate trend
% IB trend (i_tnd) is neutral interest rate, i.e. when IB rate equals
% foreign ss real interest rate plus domestic core inflation
figure("visible", "off");
plot(plotRange, db.i,...
  'linewidth', 2,...
  'color', 'b');
hold on
plot(plotRange, db.i_tnd,...
  'linewidth', 2,...
  'color', 'r');
hold on
plot(plotRange, dbObsTrans.obs_i_pol,...
  'linewidth', 2,...
  'color', 'k');
legend ('IB rate', 'IB rate trend', 'CBR', 'interpreter', 'none','Fontsize',12,...
  'location', 'southoutside',...
  'orientation', 'horizontal');
zeroline;
grid on
highlight(HighRange) %,'EdgeColor','m','LineWidth',1.5);
title('Interbank (IB) rate, its trend and CBR', 'FontSize',12); %,'interpreter', 'none');
exportgraphics(gcf, 'graphs/IB_rate_trend.emf');
%===========================================================================================================================================================================================================================
% IB rate (i) equation decomposition
i_decomp = dbDecomp.i;
figure("visible", "off");
barcon(plotRange,i_decomp.decompContribs{1}, ...
  'colormap', parula);
hold on
plot(plotRange,i_decomp.decompSeries{1}, ...
  'linewidth', 3, ...
  'color',    'w');
plot(plotRange, i_decomp.decompSeries{1}, ...
  'linewidth', 2, ...
  'color',    'k');
grid on
legend(i_decomp.legendEntries, ...
  'location', 'southoutside', ...
  'orientation', 'horizontal');
highlight(HighRange);
title(i_decomp.figureName, 'FontSize',12,...
  'interpreter', 'none');
exportgraphics(gcf, 'graphs/IB rate decomp.emf');
%===================================================================================================================================
% RIR components: IB rate minus Exp.CPI_core{+1} gives RIR(IB)
% RIR affects final demand thru r4_gap incl. rmci_cons, rmci_inv & rmci_exp
figure("visible", "off");
plot(plotRange, db.i,...
  'linewidth', 2,...
  'color', 'k');
hold on
plot(plotRange, db.e_dl_cpi_core,...
  'linewidth', 2,...
  'color', 'r');
hold on
plot(plotRange, db.r,...
  'linewidth', 2,...
  'color', 'b');
legend ('IB rate', 'Exp.CPI_core{+1}','RIR', 'interpreter', 'none','Fontsize',12,...
  'location', 'southoutside',...
  'orientation', 'horizontal');
zeroline;
grid on
highlight(HighRange) %,'EdgeColor','m','LineWidth',1.5);
title('Interbank (IB) rate, Exp.CPI_core{+1} and RIR, %', 'FontSize',12,...
  'interpreter', 'none');
exportgraphics(gcf, 'graphs/IB_core_RIR.emf');
%==========================================================================================
% AK 10/31 RIR components: generate compon per model eq. r = i - e_dl_cpi_core{+1}
figure("visible", "off");
RIR_compon = [db.i,...
  - db.e_dl_cpi_core{+1}];
barcon(plotRange,RIR_compon,'colormap', parula)
hold on
grid on
plot(plotRange, db.r, 'linewidth', 2, 'color', 'b');
legend ('Interbank (IB) rate', 'Exp.CPI_core{+1}', 'interpreter','none',...
  'location', 'southoutside',...
  'orientation', 'horizontal', ...
  'fontsize', 12);
highlight(HighRange)
title('RIR components, % (r)', 'fontsize', 12,...
  'interpreter','none');
exportgraphics(gcf, 'graphs/RIR_decomp.emf');
%==========================================================================================
% Real market interest rates
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
legend ('real lending rate', 'lending rate trend','RIR (IB)', 'RIR trend');

title('real lending rate and trend, RIR (IB) rate and trend, %', 'FontSize',12,...
  'interpreter', 'none');
exportgraphics(gcf, 'graphs/real_int.ratesF.emf');
%================================================================================================================================================================================
%% Output gap vs fiscal impulse (fisc_imp)
% Outputgap, govt demand, fiscal impulse, govt demand domestic * share GDP
figure("visible", "off");
plot(plotRange, db.l_y_gap,...
  'linewidth', 2,...
  'color', 'k');
hold on
plot(plotRange, (db.l_gdem_gap * db.w_y_gdem),...
  'linewidth', 2,...
  'color', 'r');
hold on
plot(plotRange, db.fisc_imp,...
  'linewidth', 2,...
  'color', 'b');
hold on
% plot share of gdem in GDP * Domestic share in Govt dem
plot(plotRange, db.w_y_gdem *(1-db.lam_imp_gdem)*db.l_gdem_gap,...
  'linewidth', 2,...
  'color', 'g');
legend ('output gap', 'govt demand gap,% GDP', 'fiscal impulse', 'direct effect of govt demand',...
  'interpreter', 'none','Fontsize',10,...
  'location', 'southoutside',...
  'orientation', 'horizontal');
zeroline;
grid on
highlight(HighRange) %,'EdgeColor','m','LineWidth',1.5);
title('Output gap, govt demand gap and fiscal impulse, % GDP', 'FontSize',12 ,'interpreter', 'none');
exportgraphics(gcf, 'graphs/outputgap_gdem_fiscimp.emf');
%============================================================================================================================================================================================================================
%% some ad-hoc charts generated (AK)
%(real) exchange and interest rates
figure("visible", "off");
plot(plotRange, [db.dl_s/4,db.dl_s_tar/4],'linewidth',2);
highlight(HighRange);
legend 'QQ ER depr.' 'QQ target ER depr.'

plot(plotRange, [db.dl_z, db.dl_s db.dl_cpi_core]);
highlight(HighRange)
legend 'QQ RER depr. %' 'QQ NER depr. %' 'Q-on-Q CPI_core %'

% strictly speaking, interest shown must be calculated back: exp(i/100)*100-100
plot(plotRange, [db.r db.i,db.dl_cpi_core{+1} ],'linewidth', 2);
highlight(HighRange);
legend 'RIR' 'IB interest' 'CPI-core(+1)';

plot(plotRange, [db.i db.i_tnd], 'linewidth', 2);
legend 'IB interest' 'trend';

plot(plotRange, [db.d4l_cpistar db.d4l_z db.d4l_s db.d4l_cpi_core],'linewidth', 2);
highlight(HighRange);
legend 'CPIstar' 'RER Y-on-Y %' 'ER' 'CPI core';
%================================
% Foreign GDP and demand (trading partners, WEO-GAS)
figure("visible", "off");
help=db.l_ystar_gap+dbObsTrans.obs_l_ystar_tnd;
d4l_ystar = help-help{-4};
help=dbObsTrans.obs_l_ystar_tnd;
d4l_ystar_tnd=help-help{-4};
plotRange = qq(2017,1) : qq(2027,4);
HighRange = qq(2017,1) : qq(2023,1);
plot(plotRange, d4l_ystar,...
  'linewidth', 2);
hold on
plot(plotRange, d4l_ystar_tnd,...
  'linewidth', 2);
zeroline;
grid on
highlight(HighRange); %,'EdgeColor','m','LineWidth',1.5);
legend ('Foreign demand Y-on-Y %', 'trend', 'interpreter', 'none','Fontsize',10);
title('Trading partner demand, Y-on-Y %','interpreter', 'none','FontSize',12);
exportgraphics(gcf, 'graphs/growth_ystar.emf');

close all

%end