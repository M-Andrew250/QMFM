
% ------------- Setup -------------

clear, clc, close all

opts = mainSettings();

tmp = codes.utils.loadResult(opts, "model");
m = tmp.m(1); % In case there are multiple parametrizations in m, use the first

tmp = codes.utils.loadResult(opts, "data");
dbObs = tmp.dbObs;

rngEstim = qq(2006, 1) : qq(2023, 2);

% -------- Define time varying shock multipliers (not necessary) -------

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

% ------------- Estimation -------------

% -------- Core Phillips curve --------

% Create estimation specifications for b1

% Beta prior with mean and std as given
prB1 = distribution.Beta.fromMeanStd(0.35, 0.125);

% Syntax: {starting_value, lower_bound, upper_bound, prior}
% Empty startin value means use the value from the model object
% The prior can also be omitted, which is equivalent to a uniform prior between
% the lower/upper bounds
specEstim.b1 = {[], 0.01, 0.99, prB1}; 

% Create estimation specifications for b2
prB2 = distribution.Beta.fromMeanStd(0.2, 0.125);
specEstim.b2 = {[], 0.05, 0.60, prB2};

% Create estimation specifications for b3
prB3 = distribution.Beta.fromMeanStd(0.05, 0.03);
specEstim.b3 = {[], 0.01, 0.20, prB3};

% Create estimation specifications for b4
prB4 = distribution.Beta.fromMeanStd(0.60, 0.125);
specEstim.b4 = {[], 0.10, 0.90, prB4};

% Create estimation specifications for std_shock_dl_cpi_core
specEstim.std_shock_dl_cpi_core = {[], 1, 5};

% -------- Run estimation routine--------

% Turn of warning about missing series
estimOpts.Filter = {'WhenMissing', 'silent'};

% Get the point estimate (this step is only necessary to start the Monte-Carlo simulations)
[summ, post, ~, ~, mEst] = estimate(m, dbObs, rngEstim, specEstim, estimOpts);
disp(summ)

% Run the Metropolis-Hastings posterior simulation to get a sample from the posterior distribution

N = 1000; % This is is minimum, 5000 or 10000 would be the optimal

[chain, logPost, accRat] = arwm(post, N, ...
   'progress',          true, ...
   'initScale',         0.1, ...
   'adaptScale',        1/2, ...
   'adaptProposalCov',  1/2, ...
   'gamma',             0.51, ...
   'burnIn',            0.20 ...
   );

% Calculate statistics from the simulated sample
chainStats = stats(post, chain, logPost, ...
  "mean", true, ...     % Could also specify mode or median
  "std", true ...       % Include the std calcualted from the sample
  );

% Create the setparam file combining the calibrated (in m) and the estimated (in chainStats)
% parameters
codes.utils.writeSetparam(opts, "setparamEstim", m, chainStats.mean)

% ----- Plot the prior/posterior distributions function -----

codes.estim.plotPriorPosterior(post, chain, 100)

