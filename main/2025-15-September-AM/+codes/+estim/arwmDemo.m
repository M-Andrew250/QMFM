function arwmDemo
%
% ARWM chain to estimate the mean from a randon normal sample
%

% -------- Settings --------

% Normal target distribution
targetMean  = 2;
targetStd   = 1;

% Initial value and chain length
initChain     = 0;
lengthChain   = 1000;

% Proposal distdribution
initPropStd = 1;

% Adaptation parameters
targetAccRat  = 0.3; % Target acceptance ratio
adaptScale    = 0.1;
adaptDecay    = 0.5;

% Plot range
xmin = targetMean - 10*targetStd;
xmax = targetMean + 10*targetStd;

% -------- Prepare inputs --------

% Create the function to evaluate the log of the target density (type 'doc anonymous functions' in the
% command window to see details)
targetLogPDF = @(x)-0.5*log(2*pi*targetStd^2)-0.5*((x - targetMean).^2 / targetStd^2);

% -------- Initialize the chain --------

chain     = nan(lengthChain, 1);
cand      = nan(lengthChain, 1);
accept    = nan(lengthChain, 1);
accProb   = nan(lengthChain, 1);
accRat    = nan(lengthChain, 1);
propStd   = nan(lengthChain, 1);

% -------- Run the Metropolis-Hastings chain (see below the details in the local function runMTsampler) --------

runMHsampler()

% -------- Visualize the development of the chain --------

plotChain()

% ------------- End of main function -------------

  function runMHsampler

    chain(1)    = initChain;
    accRat(1)   = 1;
    propStd(1)  = initPropStd;

    for i = 1 : lengthChain

      % Current values
      curr      = chain(i);
      numAcc    = accRat(i) * i;
      propStdi  = propStd(i);

      % Draw the candidate value from the proposal distribution
      candi = curr + propStdi * randn;

      % Calculate the acceptance probability
      currLogPost   = targetLogPDF(curr);
      candLogPpost  = targetLogPDF(candi);
      accProbi      = exp(candLogPpost - currLogPost);

      % Decide whether the candiate is accepted or not
      if 1 <= accProbi % Accept if the candiate is more likely the the current
        accepti = true;
      else % Accept with probability accProb if accProb < 1
        u = rand; % Draw a uniform random number u between 0 and 1
        if u <= accProbi % The probability of this is accProb
          accepti = true;
        else
          accepti = false;
        end
      end

      if accepti % The next value in the chain is the candidate, the number of accepted candidates increases by 1
        next    = candi;
        numAcc  = numAcc + 1;
      else % The next value in the chain is the current, the number of accepted candidates stays the same
        next  = curr;
      end

      % Put the values in the chain
      chain(i+1)    = next;
      accRat(i+1)   = numAcc / (i+1);
      accProb(i)    = accProbi;
      cand(i)       = candi;
      accept(i)     = accepti; 

      % Update the propsal std: increase/decrease if the acceptance ratio is too large/small
      propStd(i+1) = propStdi * exp(adaptScale * i^(-adaptDecay) * (accProbi - targetAccRat));

    end

  end

  function plotChain

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
      "position", [25, 25, wdAx, htAx], ...
      "xlimMode", "manual" ...
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

    hRun = uicontrol(hFig, ...
      "style", "pushbutton", ...
      "position", [wdAx + 25, 125, 175, 25], ...
      "string", "Run through", ...
      "callback", @runThrough ...
      );

    hStop = uicontrol(hFig, ...
      "style", "pushbutton", ...
      "position", [wdAx + 35, 75, 75, 25], ...
      "string", "Stop", ...
      "enable", "off", ...
      "callback", @stopChain ...
      );

    hCont = uicontrol(hFig, ...
      "style", "pushbutton", ...
      "position", [wdAx + 115, 75, 75, 25], ...
      "string", "Continue", ...
      "enable", "off", ...
      "callback", @contChain ...
      );

    hNext = uicontrol(hFig, ...
      "style", "pushbutton", ...
      "position", [wdAx + 25, 25, 175, 25], ...
      "string", "Next", ...
      "callback", @plotNext ...
      );

    % Plot the target PDF

    xx = linspace(xmin, xmax, 1000);
    yy = exp(targetLogPDF(xx));

    plot(hAx, xx, yy)
    drawnow
    hold on

    % Make sure the range is not widened when a candidate is outside the range; such candidates will
    % not appear in the plot
    set(hAx,  "yLimMode", "manual", "xLimMode", "manual");

    % Finalize figure setup
    movegui(hFig, "center");
    set(hFig, "visible", "on")

    % Pre-calculate target values
    targetChain = exp(targetLogPDF(chain));
    targetCand  = exp(targetLogPDF(cand));

    % Initialize global variables
    i = 1;
    hCurr = [];
    hCand = [];
    hProp = [];
    ylim = get(hAx, "ylim");
    ymax = ylim(2);
    ifStop = false;

    function plotNext(~,~)

      if 1 < i
        hCurr.Color       = "b";
        hCurr.MarkerSize  = 6;
        delete(hCand)
        delete(hProp)
      end
      
      hCurr = plot(hAx, chain(i), targetChain(i), "g*", "markersize", 12);
      hCand = plot(hAx,  cand(i), targetCand(i),  "r*", "markersize", 12);

      xFill = [ ...
        chain(i) - 2*propStd(i)
        chain(i) + 2*propStd(i)
        chain(i) + 2*propStd(i)
        chain(i) - 2*propStd(i)
        ];

      yFill = [0, 0, ymax, ymax];

      hProp = fill(hAx, xFill, yFill, ...
        "-|", "markerSize", 12, "faceColor", [0.75, 1, 0.75]);

      hAx.Children = circshift(hAx.Children, -1);

      hInfo.String = [
        "Iteration:  " + compose("%3.0f/%4.0f", i, lengthChain), ...
        "Current:    " + compose("%8.4f", chain(i)), ...
        "Candidate:  " + compose("%8.4f", cand(i)), ...
        "Acc. prob.: " + compose("%8.4f", accProb(i)), ...
        "Accepted:   " + compose("%8.4f", accept(i)), ...
        "Acc. rat.:  " + compose("%8.4f", accRat(i)) ...
        ];

      i = i + 1;

    end

    function runThrough(~,~)

      hRun.Enable   = "off";
      hNext.Enable  = "off";
      hStop.Enable  = "on";

      for j = i+1 : lengthChain
        if ~ifStop
          plotNext()
          drawnow()
          pause(0.001)
        end
      end

    end

    function stopChain(~,~)

      ifStop = true;

      hNext.Enable  = "on";
      hCont.Enable  = "on";
      hStop.Enable  = "off";

    end

    function contChain(~,~)

      ifStop = false;

      hNext.Enable  = "off";
      hCont.Enable  = "off";
      hStop.Enable  = "on";

      runThrough()

    end

  end

end