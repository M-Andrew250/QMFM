function [nllh, pred, filt, smooth, predP, filtP] = kalmanFilter(y, c, F, H, Q, R, initPred, initPredP)

% -------- Process inputs --------

y = y';

T = size(y, 2);
n = size(F, 1);

% -------- Initialize output --------

pred = nan(n, T);
filt = nan(n, T);
smooth = nan(n, T);

predP = nan(n, n, T);
filtP = nan(n, n, T);

pred(:, 1)      = initPred;
predP(:, :, 1)  = initPredP;

logDetVarYerr   = nan(1, T);
yerrVarYerrYerr = nan(1, T);

% -------- Forward iterations --------

for t = 1 : T

  % Predicted observation error
  yerr = y(t) - H * pred(:, t);

  % Observation prediction variance
  VarYerr = H * predP(:, :, t) * H' + R;

  % Update step
  filt(:, t) = pred(:, t) + predP(:, :, t) * H' * (VarYerr \ yerr);

  % Filter variance
  filtP(:, :, t) = predP(:, :, t) - predP(:, :, t) * H' * (VarYerr \ H) * predP(:, :, t);

  if t < T

    % Prediction step
    pred(:, t+1) = c + F * filt(:, t);

    % Predition variance
    predP(:, :, t+1) = F * filtP(:, :, t) * F' + Q;

  end

  logDetVarYerr(t)   = log(det(VarYerr));
  yerrVarYerrYerr(t) = yerr' * (VarYerr \ yerr);

end

nllh = (n*T*log(2*pi) + sum(logDetVarYerr) + sum(yerrVarYerrYerr)) / 2;

assignin("base", "logDetVarYerr", logDetVarYerr)
assignin("base", "yerrVarYerrYerr", yerrVarYerrYerr)

% -------- Backward iterations --------

smooth(:, T) = filt(:, T);

for t = T-1 : -1 : 1

  smooth(:, t) = filt(:, t) + filtP(:, :, t) * F' * inv(predP(:, :, t+1)) * (smooth(:, t+1) - pred(:, t+1));

end

% -------- Process output --------

pred = pred';
filt = filt';
smooth = smooth';

end