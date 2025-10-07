
clear, clc, close all

% -------- Load data --------

db = databank.fromCSV("data.csv");

T = length(db.y.Range);

rngY      = db.y.Range;
rngFilt   = rngY(1:T);
y        = db.y(rngFilt);

% -------- Strutural parameters --------

phi   = 0.7;
rho   = 0.9;
delta = 100*log(1 + 7.5/100)/4;

sigma2_gap  = 1.0;
sigma2_dtnd = 0.1;

% -------- Create IRIS model --------

m = Model.fromFile("extHP.model", ...
  "linear", true, "growth", true);

m.phi     = phi;
m.rho     = rho;
m.delta   = delta;

m.std_shock_y_gap   = sqrt(sigma2_gap);
m.std_shock_dy_tnd  = sqrt(sigma2_dtnd);

m = solve(m);
m = steady(m);

% -------- Filter with the IRIS model --------

[~, dbFilt] = filter(m, db, rngFilt, "output", ["pred", "filter", "smooth"], ...
  "relative", false);

% -------- Create the state space parameter matrices --------

c = [
  0
  (1 - rho)*delta
  (1 - rho)*delta
  ];

F = [
  phi 0 0
  0 rho 0
  0 rho 1
  ];

H = [1 0 1];

Q = [
  sigma2_gap 0 0
  0 sigma2_dtnd sigma2_dtnd
  0 sigma2_dtnd sigma2_dtnd
  ];

R = 0;

% -------- Initial 1|0 guesses --------

initGap     = 0;
initDYtnd   = delta;
initYtnd    = dbFilt.pred.mean.y_tnd(rngFilt(1));

initVarGap    = sigma2_gap / (1 - phi^2);
initVarDYtnd  = sigma2_dtnd / (1 - rho^2);

% -------- Run Kalman filter recursions --------

initPred = [
  initGap
  initDYtnd
  initYtnd
  ];

initPredP = [
  initVarGap 0 0
  0 initVarDYtnd initVarDYtnd
  0 initVarDYtnd initVarDYtnd
  ];

[llh, pred, filt, smooth] = kalmanFilter(y, c, F, H, Q, R, initPred, initPredP);

predYtnd    = Series(rngFilt, pred(:, 3));
filtYtnd    = Series(rngFilt, filt(:, 3));
smoothYtnd  = Series(rngFilt, smooth(:, 3));

% -------- Compare smoothed trend estimates --------

maxabs(dbFilt.smooth.mean.y_tnd - smoothYtnd)

% -------- Plot results --------

plot([y, predYtnd, filtYtnd, smoothYtnd])
legend 'Actual' 'Predicted' 'Filtered' 'Smoothed'
grid
set(gca, "fontsize", 16)
