function distpeak = getdistpeak(xsel)
xpeak = xsel; numpeaks = length(xsel);    
%distpeak = abs(xpeak(1:numpeaks-1) - xpeak(2:numpeaks));
%distpeak = ([distpeak 0] + [0 distpeak] )/2;
%distpeak(1)        = abs(xpeak(1)          - xpeak(2));
%distpeak(numpeaks) = abs(xpeak(numpeaks-1) - xpeak(numpeaks));

distpeak           = abs(xpeak(1:numpeaks-1) - xpeak(2:numpeaks));
distpeak(1)        = abs(xpeak(1)          - xpeak(2));
distpeak(numpeaks) = abs(xpeak(numpeaks-1) - xpeak(numpeaks));