
clear, clc, close all

% -------- Load data --------

db = databank.fromCSV("data.csv");

y = db.y;

T = length(y);

rngY = y.Range;
rngFilt = rngY(1:T);
yv = y(rngFilt);

% -------- Create the stacked time projection matrix --------

sigma2gap = 16;
sigma2tnd = 0.01;

phi1 =  2;
phi2 = -1;

L = zeros(T-2, T);

for t = 1 : T-2
  L(t, t : t+2) = [-phi2, -phi1, 1];
end

P = inv((eye(T) + sigma2gap / sigma2tnd * (L'*L)));

% -------- Calculate the linear projection and compare to IRIS hpf --------

% HP by linear projection
ytnd = P * yv;
ytnd = Series(rngFilt, ytnd);

% IRIS HP filter
lambda = sigma2gap / sigma2tnd;
yhp = hpf(y, "lambda", lambda);

% Compare the two
plot([y, ytnd, yhp], "lineWidth", 2);
legend 'Actual' 'KF trend' 'HP trend'
grid
set(gca, "fontsize", 16)



