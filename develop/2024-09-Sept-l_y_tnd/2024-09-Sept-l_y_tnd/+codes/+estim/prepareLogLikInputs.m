function loglikInputs = prepareLogLikInputs(m, dbObs, estimRange)

arrayObs    = datarequest('yg*', m, dbObs, estimRange);
estimRange  = double(estimRange);
kalmanOpts  = prepareKalmanOptions(m, estimRange);

loglikInputs.FilterRange         = estimRange;
loglikInputs.InputData           = arrayObs;
loglikInputs.OutputData          = struct();
loglikInputs.InternalAssignFunc  = @hdataassign;
loglikInputs.Options             = kalmanOpts;


end