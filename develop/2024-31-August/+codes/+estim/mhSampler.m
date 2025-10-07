function [chainOut, acceptRatio, propSigma, finalPropCov] = mhSampler(m, dbObs, estimRange, priors, numDraws, ...
  initPropSigma, initPropCov, targetAccRat, adaptDecay, adaptScale, adaptShape)

% !!! -------- Temporarily disable adaptation --------

targetAccRat  = 0.3;
adaptDecay    = 0.5;
adaptScale    = 0;
adaptShape    = 0;

% !!! -------- Temporarily disable adaptation --------

paramNames = string(fieldnames(priors));
numParams = numel(paramNames);

logLikInputs = codes.estim.prepareLogLikInputs(m, dbObs, estimRange);

initChain = nan(numParams, 1);
for i = 1 : numParams
  %   initChain(i) = priors.(paramNames(i)).Mean;
  initChain(i) = m.(paramNames(i));
end

prevAccepted = initChain;
m = updateModel(m, initChain);
prevLogPOst = calcLogPrior(initChain) + calcLogLik(m);

numAccepted = 0;
currPropSigma = initPropSigma;

initPropChol = chol(initPropCov)';
currPropChol = initPropChol;

chain = nan(numParams, numDraws);
acceptRatio = nan(1, numDraws);
propSigma = nan(1, numDraws);

for iDraw = 1 : numDraws

  remainingIterations = numDraws - iDraw;
  if rem(remainingIterations, 10) == 0
    fprintf("%6.0f iterations remaining\n", remainingIterations)
  end

  u = randn(numParams, 1);
  
  candidateValues = prevAccepted + currPropSigma * currPropChol * u;

  logPrior = calcLogPrior(candidateValues);

  if -Inf < logPrior
    candidateModel = updateModel(m, candidateValues); % !!! 
    logLik = calcLogLik(candidateModel);
    candidateLogPost = logLik + logPrior;
    alpha = min(1, exp(candidateLogPost - prevLogPOst));
  else
    alpha = 0;
  end

  accepted = rand() < alpha;

  if accepted
    chain(:, iDraw) = candidateValues;
    prevAccepted = candidateValues;
    numAccepted = numAccepted + 1;
  else
    chain(:, iDraw) = prevAccepted;
  end

  acceptRatio(iDraw) = numAccepted / iDraw;
  propSigma(iDraw) = currPropSigma;

  [currPropSigma, currPropChol] = adaptPropSigmaChol(currPropSigma, currPropChol);

end

for i = 1 : numParams
  chainOut.(paramNames(i)) = chain(i, :)';
end
acceptRatio = acceptRatio';
propSigma = propSigma';
finalPropCov = currPropChol*currPropChol';

  function m = updateModel(m, paramValues)
    for j = 1 : numParams
      m.(paramNames(j)) = paramValues(j);
    end
    m = solve(m);
  end

  function logLik = calcLogLik(m)
    logLik = codes.estim.kalmanLogLik(m, logLikInputs);
  end

  function logPrior = calcLogPrior(x)
    logPrior = 0;
    for j = 1 : numParams
      logPrior = logPrior + priors.(paramNames(j)).logPdf(x(j));
    end
  end

  function [newSigma, newChol] = adaptPropSigmaChol(oldSigma, oldChol)

    adaptFactor = iDraw^(-adaptDecay) * (alpha - targetAccRat);

    phiScale = adaptScale * adaptFactor;
    newSigma = exp(log(oldSigma) + phiScale);

    phiShape = adaptShape * adaptFactor;
    z = u / sqrt(u'*u);
    w = sqrt(phiShape) * z;

    newChol = cholupdate(oldChol', oldChol * w)';

  end

end