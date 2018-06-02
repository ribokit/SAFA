function    predlorentz = getlorentzian(pixels,xpeak, width,amp); 

predlorentz = amp./(1+((pixels-xpeak)./width).^2);
