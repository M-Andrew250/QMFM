
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
% Empty starting value means use the value from the model object
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

% -------- Run the Metropolis-Hastings posterior simulation to get a sample --------
% -------- from the posterior distribution --------

% Lenght of the chain. 1000 is the minimum, 5000 or 10000 would be the optimal
N = 5000;

% One reason why the results of estimate are unreliable is that the estimated standard deviations of
% the parameters are way too small. Since these std-are are then used for the porposal dsitribution
% in the MH simulations, too low values wil result in very slow convergence of the chain. Here you
% can adjust these proposal standard deviations manually.
post.InitProposalCov = diag([0.2, 0.05, 0.05, 0.2, 1.5].^2);

% You can also experiment with various initial values of the chain, usually with extreme values to
% test if the chain converges even from these very unlikely initial values.
% post.InitParam = [0.9, 0.3, 0.15, 0.25, 4];

[chain, logPost, accRat] = arwm(post, N, ...
   'progress',          true, ...
   'initScale',         0.1, ...
   'adaptScale',        1/2, ...
   'adaptProposalCov',  1/2, ...
   'gamma',             0.51, ...
   'burnIn',            0.00 ...
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

% Always inspect the acceptance ratio to make sure it converges to an acceptabe value
% between 0.2 and 0.4. Similarly, the graphs of the values of the chain for each paraemter must be
% close to the plot of a iid series, i.e. must not exhibit visible trend, and must not contain
% excessively long flat sections.
codes.estim.plotChain(specEstim, chain, accRat, logPost)

% This plots the prior PDF-s and the posterior histograms. You can control the number of bins in the
% histogram by providing a third argument, either a scalar, or seperately for each estimated
% parameter in a vector.
codes.estim.plotPriorPosterior(specEstim, chain)

