
clear, clc, close all

%% ------------ Load the model and the data -------------

opts = mainSettings();

tmp1 = codes.utils.loadResult(opts, "model");
m = tmp1.m;

tmp2 = codes.utils.loadResult(opts, "filter");
dbObs = tmp2.dbObs;

% Set the estimation range
estimRange = opts.filter.range;

%% ------------- Evaluate and plot the log-likelihood -------------

% % -------- Demonstrate the need for the implementation of the Kalman likelihood --------
% 
% tic
% % m = sstate(m);
% m = solve(m);
% filter(m, dbObs, estimRange, "relative", false)
% toc
% 
% tic
% % m = sstate(m);
% m = solve(m);
% inp = codes.estim.prepareLogLikInputs(m, dbObs, estimRange);
% codes.estim.kalmanLogLik(m, inp);
% toc

% % -------- Plot the likelihood for selected model parameters --------
% 
% inp = codes.estim.prepareLogLikInputs(m, dbObs, estimRange);
% N = 100;
% x = linspace(0.1, 0.9, 100);
% parameterName = "b1";
% m1 = alter(m, N);
% m1.(parameterName) = x;
% 
% tic
% m1 = solve(m1);
% llh = codes.estim.kalmanLogLik(m1, inp);
% toc
% 
% plot(x,llh);
% grid on
% title("Log-likelihood");
% xlabel(parameterName);
% set(gca, "fontsize", 16)
% 
% return

%% ----------- Set priors ------------

priors.b1 = distribution.Beta.fromMeanStd(m.b1, 0.1);
priors.b2 = distribution.Beta.fromMeanStd(m.b2, 0.1);
priors.b3 = distribution.Beta.fromMeanStd(m.b3, 0.02);
priors.b4 = distribution.Beta.fromMeanStd(m.b4, 0.1);
% codes.estim.plotPriors(priors, m);
% return

%% ------------- Run the sample -------------

numDraws    = 10000;
propSigma   = 1;
propCov     = diag([0.01, 0.005, 0.01, 0.01]);

tic
[chain, acceptRatio] = codes.estim.mhSampler(m, dbObs, estimRange, priors, numDraws, ...
  propSigma, propCov);
toc

codes.estim.plotChain(chain)
codes.estim.histChain(chain, m, priors)

%% ------------- Create a setparam file for a new parametrization
% -------------

m2 = m;
m2.b1 = 0.5041;
m2.b2 = 0.1603;
m2.b3 = 0.0363;
m2.b4 = 0.8687;

codes.utils.writeSetparam(opts, "setparam_estimated", m2);



