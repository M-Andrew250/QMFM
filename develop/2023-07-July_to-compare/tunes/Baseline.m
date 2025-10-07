function [dbTunes, pln, m] = Baseline(opts, m)

% -------- Read the tunes and create the simulation plan --------

[dbTunes, pln] = codes.utils.readTunes(opts, "Baseline", m);

% -------- Reset model parameters --------

% Change model para, here for interest policy rule response to output gap
m.c3 = 0.2; % was 0.5, seems NBR less responsive to y_gap; IMF-NBR had 0.5 (for same persistence as we)

end
