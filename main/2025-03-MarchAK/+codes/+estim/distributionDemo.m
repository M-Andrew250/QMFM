
clear, clc, close all

h = distribution.Beta.fromMeanStd(0.6, 0.125);

x = linspace(0, 1, 100);
y = h.pdf(x);

plot(x, y, '.-');
grid on
