function dt = addDataTip(h, dataTipDate, dataTipLocation)

x = datetime(dataTipDate);
y = h.YData(h.XData == x);

dt0 = datatip(h, x, y);
dt0.Location = dataTipLocation;

if nargout > 0
  dt = dt0;
end

end