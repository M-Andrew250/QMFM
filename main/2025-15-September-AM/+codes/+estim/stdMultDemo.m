
% -------- Setup --------

clear, clc, close all

opts = mainSettings();

tmp = codes.utils.loadResult(opts, "model");
m = tmp.m(1); % In case there are multiple parametrizations, use the first model for this demo

tmp = codes.utils.loadResult(opts, "data");
dbObs = tmp.dbObs;

rngFilter = qq(2006, 1) : qq(2023, 2);

% -------- Run filter with/without multipliers --------

% ----- No multipliers -----

[~, dbFilt0]  = filter(m, dbObs, rngFilter, 'relative', false);

% ----- Define std multipliers -----

stdMult = struct();

stdMult.std_shock_dl_cpi_core = Series();
stdMult.std_shock_dl_cpi_core(qq(2020, 2)) = 5;
stdMult.std_shock_dl_cpi_core(qq(2020, 4)) = 3;
stdMult.std_shock_dl_cpi_core(qq(2021, 4)) = 5;
stdMult.std_shock_dl_cpi_core(qq(2022, 1)) = 5;
stdMult.std_shock_dl_cpi_core(qq(2022, 2)) = 5;
stdMult.std_shock_dl_cpi_core(qq(2022, 4)) = 5;
stdMult.std_shock_dl_cpi_core(qq(2023, 2)) = 3;
stdMult.std_shock_dl_cpi_core(qq(2024, 1)) = 5;

% ----- Filter with multipliers -----

[~, dbFilt1] = filter(m, dbObs, rngFilter, 'multiply', stdMult, 'relative', false);

% -------- Plot the filtered CPI corfe shocks --------

h = plot([dbFilt0.mean.shock_dl_cpi_core, dbFilt1.mean.shock_dl_cpi_core]);
yline(0)
title("Core inflation shock")

 % Specifying the handle of the lines explicitely prevents showing a legend for the
 % constant line created by yline(0)
legend(h, ["With multiplier", "Without multiplier"]);

grid on
set(gca, "fontsize", 16)

