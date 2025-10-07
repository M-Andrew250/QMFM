function legend = createParamLegend(opts)
% codes.reporting.createParamLegend creates legends for the different model parametrizations.
%
% Usage: legend = codes.reporting.createParamLegend(opts)


numModels = length(opts.parameterNames);

if numModels > 1
  
  if isfield(opts, "parameterLegends")
    
    legend = opts.parameterLegends;
    
  else
    
    legend = "model" + num2str((1:numModels)');
    
  end
  
else
  
  legend = "";
  
end

end