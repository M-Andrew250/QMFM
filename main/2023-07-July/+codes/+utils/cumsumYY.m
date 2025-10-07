function y = cumsumYY(x, init)

y = Series();
fd = x.StartAsDate-4;
y(fd:fd+3) = init;
for t = x.Range
  y(t) = y(t-4) * x(t);
end

plot(pct(y))
% keyboard

end