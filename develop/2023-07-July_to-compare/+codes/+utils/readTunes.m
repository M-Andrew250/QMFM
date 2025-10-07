function [dbTunes, pln] = readTunes(opts, fileName, m)

% ------------- Read the tunes from the CSV file ------------

fileName = fullfile(opts.tunesDir, fileName + ".csv");
c = readcell(fileName, "texttype", "string");

% ------------- Initialize the simulation plan and the database ------------

rngFcast = opts.forecast.range;
pln = Plan.forModel(m, rngFcast);

dbTunes = struct();

% ------------- Update the database and the plan ------------

% Sztarting date of the sereis in the database
startDate = str2dat(c{3,1});

for i = 2 : size(c, 2)

  seriesName    = c{1, i};
  shockName     = c{2, i};
  seriesValues  = [c{3:end, i}]';

  newSeries = Series(startDate, seriesValues);
  newSeries.comment = shockName; % Store variables/shock pairs

  % Combine the new series with an existing one (necessary to handle the
  % case of one variable exogenized on different ranges by different shocks)
  if isfield(dbTunes, seriesName)
    dbTunes.(seriesName) = [dbTunes.(seriesName); newSeries];
  else
    dbTunes.(seriesName) = newSeries;
  end

  % Update the plan if a shock name is specified
  if ~ismissing(shockName)
    rngExog = newSeries.Range;
    pln = exogenize(pln,  rngExog, seriesName);
    pln = endogenize(pln, rngExog, shockName);
  end

end

end