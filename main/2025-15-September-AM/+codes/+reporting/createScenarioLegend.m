function legend = createScenarioLegend(opts)
% codes.reporting.createScenarioLegend creates legends for the various forecast scenarios.
%
% Usage: legend = codes.reporting.createScenarioLegend(opts)
%

numscen = length(opts.forecast.scenarioNames);

if numscen > 1
  
  if isfield(opts.forecast, "scenarioLegends")
    
    legend = opts.forecast.scenarioLegends;
    
  else
    
    legend = "scenario" + num2str((1:numscen)');
    
  end
  
else
  
  legend = "";
  
end

end