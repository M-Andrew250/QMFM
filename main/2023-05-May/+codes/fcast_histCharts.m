% MINECOFIN Quarterly Macro-Fiscal Outlook 2023-26 QuaMFO, forecast part
% OCE QMFM team consisting of ES, EvM.K SI, and AK, charts prepared in Jan-Feb 2023
%% For forecast charts
% Load data (observed/forecast) set, set plot/highlight ranges
%  Highlighted range represents the past devts. before filtration range 
clear, clc, close all;
load("results/data.mat");
load("results/forecast.mat");
plotRange = qq(2017,1) : qq(2026,2);
HighRange = qq(2017,1) : qq(2022,2);
%% For historical/past devpts. charts 
% Comment out/uncomment section above/below, repectively----Ctrl+shift+R
% Make sure you change dbFcast to dbFilt accross the file
% clear, clc, close all
% load("results/data.mat");
% load("results/Filter.mat");
% plotRange = qq(2015,1) : qq(2022,2);
% HighRange = qq(2015,1) : qq(2019,2); 
%===================================================================================================================================================================================================================================
%% GDP growth decomposition by FD growth components LETS RETHINK SEE ATTEMPT
% output gap discrepancy shocks matter for past (outputgap =/= weighted sum FDgaps) but projected zero
% but output y-on-y growth rate has different discrepancy for past, zero % for projection
% we calculate discrepancy first, then include in barcon decomposition
% (d4ly_discr_shock removed from legends--it is almost zero for past/forecast
figure();
d4ly_discr_shock = dbFcast.d4l_y - (m.w_y_cons * dbFcast.d4l_cons + m.w_y_inv  * dbFcast.d4l_inv + m.w_y_gdem * dbFcast.d4l_gdem + m.w_y_exp  * dbFcast.d4l_exp -  m.w_y_imp * dbFcast.d4l_imp);
d4ly_decomp = [ ...
  m.w_y_cons * dbFcast.d4l_cons, ...
  m.w_y_inv  * dbFcast.d4l_inv, ...
  m.w_y_gdem * dbFcast.d4l_gdem, ...
  m.w_y_exp  * dbFcast.d4l_exp ...
 - m.w_y_imp * dbFcast.d4l_imp,...
   d4ly_discr_shock];
barcon(plotRange,d4ly_decomp,'colormap', parula);
hold on
plot(plotRange, dbFcast.d4l_y, 'linewidth', 3, 'color', 'w');
plot(plotRange, dbFcast.d4l_y, 'linewidth', 1, 'color', 'k');
hold on
legend ('Consumption','Investment','Govt demand', ...
    'Exports','Imports','FontSize',8, ...
    'orientation', 'horizontal', 'location', 'southoutside',...
    'interpreter', 'none');
grid on
highlight(HighRange);
title ('GDP growth, YoY %');
exportgraphics(gcf, 'graphs/GDP_growth.emf'); 
%=======================================================================================================================================================================================================================================
%% Final Demand (FD) 
% Consumption equation decomposition
% dbDecomp is set of equation/variables' contributions (i.e. title,legends,series,independent factors) stored in forecast
% results (read/extract from forecast.mat just to avoid a new generation of equation) 
% dbdecomp stores decompContribs{1}(independent components and decompSeries(dependent var--l_cons_gap)
% legendEntries (all eq. legends),figureName (title of variable) 
cons_decomp = dbDecomp.l_cons_gap;
figure ();
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
figure ();
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
figure ();
plot(plotRange, dbFcast.dl_cpi,...
'linewidth', 2,...
'color', 'r');
hold on
plot(plotRange, dbFcast.dl_cpi_core,...
'linewidth', 2,...
'color', 'b'),...
plot(plotRange, dbFcast.dl_cpi_food,...
'linewidth', 2,...
'color', 'g'),...
plot(plotRange, dbFcast.dl_cpi_ener,...
'linewidth', 2,...
'color', 'y'),...
legend ('Headline','Core','Food', 'Energy','interpreter', 'none','Fontsize',10);
zeroline
grid on
highlight(HighRange) %,'EdgeColor','m','LineWidth',1.5);
title('Inflation (CPI), ann. QQ %', 'FontSize',12);
exportgraphics(gcf, 'graphs/inflation_compon.emf');
%======================================================================================================================================================================================================================
%% CPI decomposition
figure ();
discr_shock = dbFcast.d4l_cpi - (m.w_core * dbFcast.d4l_cpi_core + m.w_food * dbFcast.d4l_cpi_food + m.w_ener * dbFcast.d4l_cpi_ener);
d4l_cpi_decomp = [m.w_core * dbFcast.d4l_cpi_core,...
    m.w_food * dbFcast.d4l_cpi_food,...
    m.w_ener * dbFcast.d4l_cpi_ener,...
    discr_shock];
barcon(plotRange,d4l_cpi_decomp, 'colormap', parula); 
hold on
plot(plotRange, dbFcast.d4l_cpi, 'color', 'w', 'linewidth', 3);
plot(plotRange, dbFcast.d4l_cpi, 'color', 'k', 'linewidth', 2)
legend ('Core', 'Food' ,'Energy', 'Discr_shock',...
    'orientation', 'horizontal', 'location', 'southoutside',...
    'interpreter', 'none')
highlight(HighRange);
title ('Inflation (d4l_cpi) decomposition', 'interpreter', 'none');
grid on 
exportgraphics(gcf, 'graphs/cpi_decomp.png');
%% Core inflation equation decomposition (and similar for food, energy)
% paste 'food' or 'ener' to replace 'core', e.g. replace dbDecomp.dl_cpi_core with dbDecomp.dl_cpi_food
core_decomp = dbDecomp.dl_cpi_core;
figure ();
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
figure ();
plot(plotRange, dbFcast.dl_s,...
'linewidth', 2,...
'color', 'k');
hold on
plot(plotRange, dbFcast.dl_s_tar,...
'linewidth', 2,...
'color', 'r'),...
legend ('QoQ_ER_depr.', 'QoQ_ER_depr.tar', 'interpreter', 'none','Fontsize',10);
zeroline
grid on
highlight(HighRange) %,'EdgeColor','m','LineWidth',1.5);
title('Exchange rate depreciation: Actual vs. Target,q-on-q %', 'FontSize',12); %,'interpreter', 'none');
exportgraphics(gcf, 'graphs/ER & ER target depr.emf'); 
%===========================================================================================================================================================================================================
%% RER (real exchange rate) % YoY vs RER gap, %
% RER (l_z_gap) goes to final dem thru rmci_cons, rmci_inv, rmci_exp
% RER equals nom ER + diff btn foreign inflation and dom. core inflation
figure ();
plot(plotRange, dbFcast.d4l_z,...
'linewidth', 2);
hold on
plot(plotRange, dbFcast.l_z_gap,...
'linewidth', 2);
zeroline
grid on
highlight(HighRange); %,'EdgeColor','m','LineWidth',1.5);
legend ('RER, % YoY','RER gap, %','interpreter', 'none','Fontsize',10);
title('Real exchange rate and RER gap, % YoY','interpreter', 'none','FontSize',12);
exportgraphics(gcf, 'graphs/RER_yoy.emf');
%==========================================================================================================================================================================================================
%% RER components
% Generate RER components per model eq.: l_z = l_s + l_cpistar - l_cpi_core;
figure ();
RER_compon = [dbFcast.dl_s,...
    + dbFcast.dl_cpistar,...
    - dbFcast.dl_cpi_core]; 
barcon(plotRange,RER_compon,'colormap', parula)
hold on
grid on
plot(plotRange, dbFcast.dl_z, 'linewidth', 3, 'color', 'w');
plot(plotRange, dbFcast.dl_z, 'linewidth', 2, 'color', 'b');
legend ('Nom_ER', 'CPI_star','CPI_core', 'interpreter','none',...
    'location', 'southoutside',...
  'orientation', 'horizontal', ...
  'fontsize', 12);
highlight(HighRange)
title('RER components, q-on-q % (dl_z)', 'fontsize', 12,...
    'interpreter','none');
exportgraphics(gcf, 'graphs/RER_decomp.emf');
%======================================================================================================================================================================================================================
%% Nominal ER (l_s) equation decomposition 
ls_decomp = dbDecomp.l_s;
figure ();
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
%% Interbank (IB) rate and IB rate trend
% IB trend (i_tnd) is neutral interest rate, i.e. when IB rate equals
% foreign ss real interest rate plus domestic core inflation 
figure ();
plot(plotRange, dbFcast.i,...
'linewidth', 2);
%'color', 'b');
hold on
plot(plotRange, dbFcast.i_tnd,...
'linewidth', 2);
%'color', 'r'),...
% hold on
% plot(plotRange, dbObs.obs_.i_pol,...
% 'linewidth', 2);
% %'color', 'k'),...
legend ('IB rate', 'IB rate trend', 'interpreter', 'none','Fontsize',12,...
'location', 'southoutside',...
  'orientation', 'horizontal');
zeroline
grid on
highlight(HighRange) %,'EdgeColor','m','LineWidth',1.5);
title('Interbank (IB) rate and trend', 'FontSize',12); %,'interpreter', 'none');
exportgraphics(gcf, 'graphs/IB_rate_trend.emf');
%===========================================================================================================================================================================================================================
%% IB rate (i) equation decomposition
i_decomp = dbDecomp.i;
figure ();
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
%% RIR components: IB rate, Exp.CPI_core{+1} and RIR(IB)
% RIR is determined by nom.int rate (IB) minus exp.core infl (core_cpi){+1}
% RIR thru r4_gap affects final dem incl. rmci_cons, rmci_inv & rmci_exp
figure ();
plot(plotRange, dbFcast.i,...
'linewidth', 2);
%'color', 'b');
hold on
plot(plotRange, dbFcast.e_dl_cpi_core,...
'linewidth', 2);
%'color', 'r');
hold on
plot(plotRange, dbFcast.r,...
'linewidth', 2);
%'color', 'k');
legend ('IB rate', 'Exp.CPI_core{+1}','RIR', 'interpreter', 'none','Fontsize',12,...
'location', 'southoutside',...
  'orientation', 'horizontal');
zeroline
grid on
highlight(HighRange) %,'EdgeColor','m','LineWidth',1.5);
title('Interbank (IB) rate, Exp.CPI_core{+1} and RIR, %', 'FontSize',12,...
    'interpreter', 'none');
exportgraphics(gcf, 'graphs/IB_core_RIR.emf');
%==================================================================================================================================================================
%% Real market interest rates
% real lending rate, RIR trend, RIR lending, lending premium
figure ();
% plot(plotRange, [dbFcast.r4_gap dbFcast.r dbFcast.r_tnd dbFcast.prem_d], 'linewidth', 2); 
% legend ('RIR (r4 gap)', 'RIR (IB)','RIR (IB) trend','lending premium');
% alternative presentation:
plot(plotRange, [(dbFcast.r4_gap + dbFcast.r_tnd + dbFcast.prem_d) dbFcast.r_tnd + dbFcast.ss_prem_d ...
    dbFcast.r  dbFcast.r_tnd], 'linewidth', 2); 
legend ('real lending rate', 'lending rate trend','RIR (IB)', 'RIR(IB) trend');
highlight(HighRange);
title('RIR (IB), real lending rates, and trends, %', 'FontSize',12 ,'interpreter', 'none');
exportgraphics(gcf, 'graphs/real_int.ratesF.emf');
%================================================================================================================================================================================
%% Output gap vs fiscal impulse (fisc_imp)
% Outputgap, govt demand, fiscal impulse, govt demand domestic * share GDP
figure ();
plot(plotRange, dbFcast.l_y_gap,...
'linewidth', 2,...
'color', 'k');
hold on
plot(plotRange, (dbFcast.l_gdem_gap * dbFcast.w_y_gdem),...
'linewidth', 2,...
'color', 'r');
hold on
plot(plotRange, dbFcast.fisc_imp,...  
'linewidth', 2,...
'color', 'b');
hold on
% plot share of gdem in GDP * Domestic share in Govt dem
plot(plotRange, dbFcast.w_y_gdem *(1-dbFcast.lam_imp_gdem)*dbFcast.l_gdem_gap,...
'linewidth', 2,...
'color', 'g');
legend ('output gap', 'govt demand gap,% GDP', 'fiscal impulse', 'direct effect of govt demand',...
'interpreter', 'none','Fontsize',10,...
'location', 'southoutside',...
  'orientation', 'horizontal');
zeroline
grid on
highlight(HighRange) %,'EdgeColor','m','LineWidth',1.5);
title('Output gap, govt demand gap & fiscal impulse, % GDP', 'FontSize',12 ,'interpreter', 'none');
exportgraphics(gcf, 'graphs/outputgap_gdem_fiscimp.emf');
%============================================================================================================================================================================================================================
%% some ad-hoc charts generated (AK)
%(real) exchange and interest rates
plot(plotRange, [dbFcast.dl_s/4,dbFcast.dl_s_tar/4],'linewidth',2); 
highlight(HighRange);
legend 'QQ ER depr.' 'QQ target ER depr.'

plot(plotRange, [dbFcast.dl_z,dbFcast.dl_s dbFcast.dl_cpi_core]); 
highlight(HighRange)
legend 'QQ RER depr.%' 'QQ NER depr.' 'QQ CPI_core'

% strictly speaking, interest shown must be calculated back: exp(i/100)*100-100
plot(plotRange, [dbFcast.r dbFcast.i,dbFcast.dl_cpi_core{+1} ],'linewidth', 2);
highlight(HighRange);
legend 'RIR' 'IB interest' 'CPI-core(+1)';

plot(plotRange, [dbFcast.i dbFcast.i_tnd], 'linewidth', 2); 
legend 'IB interest' 'trend';

plot(plotRange, [dbFcast.d4l_cpistar dbFcast.d4l_z dbFcast.d4l_s dbFcast.d4l_cpi_core],'linewidth', 2); 
highlight(HighRange);
legend 'CPIstar' 'RER YY %' 'ER' 'CPI core';
 figure ();
%================================
% Foreign GDP and demand (trading partners, WEO-GAS)
help=dbFcast.l_ystar_gap+dbObs.obs_l_ystar_tnd;
d4l_ystar = help-help{-3}
help=dbObs.obs_l_ystar_tnd;
d4l_ystar_tnd=help-help{-3};
plotRange = qq(2017,1) : qq(2026,2);
HighRange = qq(2017,1) : qq(2022,2);
plot(plotRange, d4l_ystar,...
'linewidth', 2);
hold on
plot(plotRange, d4l_ystar_tnd,...
'linewidth', 2);
zeroline
grid on
highlight(HighRange); %,'EdgeColor','m','LineWidth',1.5);
legend ('Foreign demand YoY %', 'trend', 'interpreter', 'none','Fontsize',10);
title('Trading partner demand, YY %','interpreter', 'none','FontSize',12);
exportgraphics(gcf, 'graphs/growth_ystar.emf');

%end 