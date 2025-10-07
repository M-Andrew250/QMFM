function newtonDemo
%
% Newton-Raphson algorithm to find the optimum of a function
%

% -------- Settings --------

% Maximum number of iterations
maxIter = 100;

% Convergence criteria: the algorith mstops if the derivative of the objective function is less than
% this in absolute value
tol = 1e-12;

% Initial guess
xInit = 0.79;

% THe objective function
objFun = @(x) (1 + x) ./ (1 + x.^2);
% objFun = @(x) -x.^7 .* (1 - x).^3;
% objFun = @(x) -x.^2;


% -------- Initialize the output --------

x     = nan(maxIter, 1);
fx    = nan(maxIter, 1);
dfx   = nan(maxIter, 1);
d2fx  = nan(maxIter, 1);
step  = nan(maxIter, 1);

% -------- Run the Newton-Raphson algorithm --------

runNRalgo()

% Remove NaN-s from the end (in case the algorithm converged before maxIter)
ind = isnan(x);
x(ind)      = [];
fx(ind)     = [];
dfx(ind)    = [];
d2fx(ind)   = [];
step(ind)   = [];

maxIter = numel(x);

% -------- Visualize how the iterations proceeds --------

plotNRIterations()

% -------- End of main function --------

  function runNRalgo

    done = false;
    iter = 0;

    x(1) = xInit;

    while ~done

      iter = iter + 1;

      fx(iter) = objFun(x(iter));

      h = sqrt(eps)*x(iter);
      dfx(iter)  = (objFun(x(iter) + h) - fx(iter)) / h;

      h = eps^(1/3);
      d2fx(iter) = (objFun(x(iter) + h) - 2*fx(iter) + objFun(x(iter) - h)) / h^2;

      step(iter) = -dfx(iter) / d2fx(iter);

      if iter == maxIter || abs(step(iter)) <= tol
        done = true;
      else
        x(iter+1) = x(iter) + step(iter);
      end

    end

  end

  function plotNRIterations()

    close all

    % Create the figrue window
    ss = get(0, "screenSize"); % Screen size
    wdFig = round(ss(3)/2); % Figure width
    htFig = round(ss(4)/2); % Figure height
    hFig = figure( ...
      "visible", "off", ...
      "position", [25, 25, wdFig, htFig], ...
      "menuBar", "none", ...
      "numberTitle", "off" ...
      );

    % Create the axis
    htAx = round(htFig - 50);
    wdAx = wdFig - 200;
    hAx = axes(hFig, ...
      "units", "pixels", ...
      "position", [25, 25, wdAx, htAx] ...
      );

    % Create the info display boxe
    hInfo = uicontrol(hFig, ...
      "style", "text", ...
      "position", [wdAx + 37.5, htAx - 225, 150, 250], ...
      "fontName", "Courier", ...
      "horizontalAlignment", "left", ...
      "string", "" ...
      );

    % Create the buttons

    hBack = uicontrol(hFig, ...
      "style", "pushbutton", ...
      "position", [wdAx + 35, 75, 75, 25], ...
      "string", "Back", ...
      "enable", "off", ...
      "callback", @backIter ...
      );

    hNext = uicontrol(hFig, ...
      "style", "pushbutton", ...
      "position", [wdAx + 115, 75, 75, 25], ...
      "string", "Next", ...
      "enable", "on", ...
      "callback", @nextIter ...
      );

    % Plot the objective function

    clrs = lines();

    xxmin = -20; % max(floor(min(x)), -20);
    xxmax = 20; % min(ceil(max(x)), 20);
    xx = linspace(xxmin, xxmax, 1000);
    %     xx = linspace(-10, 10, 1000);
    yy = objFun(xx);
    plot(hAx, xx, yy, "color", clrs(1, :), "LineWidth", 2);
    yline(0);
    grid on
    hold on
    set(hAx,  "yLimMode", "manual", "xLimMode", "manual");

    % Finalize figure setup
    movegui(hFig, "center");
    set(hFig, "visible", "on")

    % Initialize handles
    hIter = nan(maxIter, 2);

    iter = 1;

    plotIteration()

    function plotIteration()

      hIter(iter, 1) = plot(x(iter), fx(iter), "*", "markerSize", 12, "color", clrs(2, :));

      a = d2fx(iter) / 2;
      b = dfx(iter);
      c = fx(iter);

      if iter < maxIter
        xxmin   = x(iter) - 2*step(iter);
        xxmax   = x(iter) + 2*step(iter);
        xx      = linspace(xxmin, xxmax, 100);
        yy      = a*(xx - x(iter)).^2 + b*(xx - x(iter)) + c;
        hIter(iter, 2) = plot(xx, yy, "color", clrs(2, :));
      end

      writeIter()

    end

    function writeIter()

      hInfo.String = [
        "  Iter: " + compose("%8.0f/%3.0f", iter, maxIter), ...
        "     x: " + compose("%12.4e", x(iter)), ...
        "  f(x): " + compose("%12.4e", fx(iter)), ...
        " df(x): " + compose("%12.4e", dfx(iter)), ...
        "d2f(x): " + compose("%12.4e", d2fx(iter)), ...
        "  step: " + compose("%12.4e", step(iter)) ...
        ];

    end

    function nextIter(~, ~)

      iter = iter  + 1;

      hBack.Enable  = "on";
      if iter == maxIter
        hNext.Enable  = "off";
      end

      plotIteration()

    end

    function backIter(~, ~)

      h = hIter(iter, :);
      delete(h(~isnan(h)))

      iter = iter - 1;

      writeIter()

      hNext.Enable  = "on";
      if iter == 1
        hBack.Enable  = "off";
      end

    end

  end


end