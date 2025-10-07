
clear, clc, close all

% -------- Setup model --------

m = Model.fromFile("extHP.model", ...
  "linear", true, "growth", true);

m.phi     = 0.7;
m.rho     = 0.9;
m.delta   = 100*log(1 + 7.5/100/4);

m.std_shock_y_gap   = 4;
m.std_shock_dy_tnd  = 0.1;

m = solve(m);
m = steady(m);

% -------- Read data --------

db = databank.fromCSV("data.csv");

% -------- Estimate the parameters --------

rngEstim = db.y.Range;

specEstim.std_shock_y_gap   = {[], 1, 10};
specEstim.rho               = {[], 0.1, 0.99};
specEstim.delta             = {[], 1, 5};
specEstim.phi               = {[], 0.1, 0.99};
% specEstim.std_shock_dy_tnd   = {1.5, 1, 2};

[summ, post, ~, ~, mEst] = estimate(m, db, rngEstim, specEstim);
disp(summ)

% Plot the log-likelihood function to check if the maximum has been correctly found
plotLLH(post)

% -------- Compare the calibrated/estimated models --------

m1 = [m, mEst];

[~, dbf] = filter(m1, db, rngEstim);

figure

subplot(2,3,1)
plot([dbf.mean.y_tnd, db.y], "lineWidth", 2)
grid on
title('Actual/trend')
legend 'Calibr' 'Estim' 'Actual'
set(gca, "fontsize", 12)

subplot(2,3,2)
plot(dbf.mean.y_gap, "lineWidth", 2)
yline(0)
grid on
title('Output gap')
legend 'Calibr' 'Estim'
set(gca, "fontsize", 12)

subplot(2,3,3)
plot(dbf.mean.dy_tnd, "lineWidth", 2)
yline(m.delta)
grid on
title('Trend growth rate')
legend 'Calibr' 'Estim'
set(gca, "fontsize", 12)

subplot(2,3,5)
plot(dbf.mean.shock_y_gap, "lineWidth", 2)
yline(0)
grid on
title('Gap shocks')
legend 'Calibr' 'Estim'
set(gca, "fontsize", 12)

subplot(2,3,6)
plot(dbf.mean.shock_dy_tnd, "lineWidth", 2)
yline(0)
grid on
title('Trend growth shocks')
legend 'Calibr' 'Estim'
set(gca, "fontsize", 12)





