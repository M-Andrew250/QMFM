function closeFigures()
% codes.utils.closeFigures() closes invisible figures windows.
%
% Usage: chk = codes.utils.closeFigures()

h = findobj('visible', 'off');   % Invisible object
h = findobj(h, 'type', 'figure'); % Invisible figure windows
close(h)

end