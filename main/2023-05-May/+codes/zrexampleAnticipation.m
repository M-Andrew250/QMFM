
clear, clc, close all

% Adjust this line to match your main directory, i.e. where your
% mainSettings.m and mainDriver.m are located
%mainDir = "C:\svn\Countries\Rwanda\giz_minecofin\Workshop_2022_02_Dec\mfci";
mainDir= "C:\Users\arino\OneDrive\Documents\Matlabfiles\zr policy brief Dec 16 2022";

tmp = load(fullfile(mainDir, "results", "model.mat"));
m = tmp.m;

tmp = load(fullfile(mainDir, "results", "filter.mat"));
dbFilt = tmp.dbFilt;

tmp = load(fullfile(mainDir, "results", "data.mat"));
dbObs = tmp.dbObs;

rangeSimul = qq(2022,3) : qq(2027,2);

% Simulate with no shocks
dbInit = dbFilt.mean;
dbBase = simulate(m, dbInit, rangeSimul);

% With a CPI core shock in the first period 2023
dbInit = dbFilt.mean;
dbInit.shock_dl_cpi_core(qq(2023,1)) = 1;
dbSimul1 = simulate(m, dbInit, rangeSimul, ...
  'anticipate', false);
dbDiff1 = databank.minusControl(m, dbSimul1, dbBase);

% With a CPI core shock in the third period 2022
dbInit = dbFilt.mean;
dbInit.shock_dl_cpi_core(qq(2022,3)) = 1;
dbSimul2 = simulate(m, dbInit, rangeSimul, ...
  'anticipate', false);
dbDiff2 = databank.minusControl(m, dbSimul2, dbBase);

% Simulation with surprise hard tuning
dbInit = dbFilt.mean;
pln = Plan(m, rangeSimul, 'anticipate', true);
tuneRange = qq(2022,3) : qq(2026,4);
pln =  exogenize(pln, tuneRange, "l_rp_enerstar_gap");
pln = endogenize(pln, tuneRange, "shock_l_rp_enerstar_gap");
dbInit.l_rp_enerstar_gap = dbObs.obs_l_rp_enerstar_gap;
dbSimul3 = simulate(m, dbInit, rangeSimul, ...
  'plan', pln);
dbDiff3 = databank.minusControl(m, dbSimul3, dbBase);

% Simluation with anticipated hard tuning
dbInit = dbFilt.mean;
pln = Plan(m, rangeSimul);
pln = anticipate(pln, true,   ["l_rp_enerstar_gap", "shock_l_rp_enerstar_gap"]);
pln = anticipate(pln, false,  "shock_dl_cpi_core");
pln = anticipate(pln, true,   "shock_l_y_gap");
tuneRange = qq(2022,3) : qq(2026,4);
% pln =  exogenize(pln, tuneRange, "l_rp_enerstar_gap");
% pln = endogenize(pln, tuneRange, "shock_l_rp_enerstar_gap");
pln =  swap(pln, tuneRange, ["l_rp_enerstar_gap", "shock_l_rp_enerstar_gap"]);
dbInit.l_rp_enerstar_gap = dbObs.obs_l_rp_enerstar_gap;
dbInit.shock_dl_cpi_core(qq(2023,1)) = 1;
dbInit.shock_l_y_gap(qq(2023,1)) = 1;
dbSimul4 = simulate(m, dbInit, rangeSimul, ...
  'plan', pln);
dbDiff4 = databank.minusControl(m, dbSimul4, dbBase);

% Plotting

figure();

rangePlot = rangeSimul(1)-1 : rangeSimul(end);

subplot(2,2,1)
plot(rangePlot, [dbSimul3.l_rp_enerstar_gap, dbSimul4.l_rp_enerstar_gap, dbBase.l_rp_enerstar_gap], ...
  'linewidth', 2);
title('External variable')
set(gca, 'fontsize', 16)
grid on

subplot(2,2,2)
plot(rangePlot, [dbSimul3.shock_l_rp_enerstar_gap, dbSimul4.shock_l_rp_enerstar_gap, dbBase.shock_l_rp_enerstar_gap], ...
  'linewidth', 2);
title('External Shock')
set(gca, 'fontsize', 16)
grid on

subplot(2,2,3)
plot(rangePlot, [dbDiff3.dl_cpi_core, dbDiff4.dl_cpi_core], ...
  'linewidth', 2);
title('CPI core, ann. q-on-q growth (diff. from base)')
legend(["Surprise shocks", "Anticipated shocks"])
yline(0)
grid on
set(gca, 'fontsize', 16)