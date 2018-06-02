function fitprofile = predict_profile(pixels,params)
numpeaks = (length(params)-2)/2;
xpeak    = params(  1         : numpeaks);
%Function assumes you are submitting log of the amplitudes!
amppeak  = exp(params(  numpeaks+1: 2*numpeaks));
propconst= params(2*numpeaks+1);
minwidth = params(2*numpeaks+2);

distpeak = getdistpeak(xpeak');
widthpeak = distpeak'*propconst + minwidth;

[x,xpeak_grid]    = meshgrid(pixels,xpeak);
[x,widthpeak_grid]= meshgrid(pixels,widthpeak);

basisfunction = 1./(1+((x-xpeak_grid)./widthpeak_grid).^2);


fitprofile=basisfunction'*amppeak;
