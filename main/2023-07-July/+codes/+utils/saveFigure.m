function saveFigure(hf, figureName)

% Get outer position
oldPos = hf.OuterPosition;

% Check if theres a legend which extends outside of the figure, and adjust
% the figure size

hl = findobj(hf, 'type', 'legend');

if ~isempty(hl)
  
  legWidth  = (hl.Position(3) - hl.Position(1));
  
  if legWidth > 1
    
    newPos      = oldPos;
    newPos(3:4) = newPos(3:4) * legWidth;
    newPos(1:2) = oldPos(1:2) - (newPos(3:4) - oldPos(3:4));
    
    hf.OuterPosition = newPos;

  end
  
end

% Save the figure
exportgraphics(hf, figureName);

end