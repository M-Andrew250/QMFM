function closeFigures()

h = findobj('visible', 'off');   % Invisible object
h = findobj(h, 'type', 'figure'); % Invisible figure windows
close(h)

end