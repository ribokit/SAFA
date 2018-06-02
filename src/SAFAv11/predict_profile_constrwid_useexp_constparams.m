function fitprofile = predict_profile(pixels,params,const_params)
numpeaks  = length(params);
%Function assumes you are submitting log of the amplitudes!
amppeak   = exp(params(  1 : numpeaks ));
xpeak     = const_params( 1 : numpeaks );
propconst = const_params(numpeaks+1);
minwidth  = const_params(numpeaks+2);

distpeak  = getdistpeak(xpeak');
widthpeak = distpeak'*propconst + minwidth;

[x,xpeak_grid]    = meshgrid(pixels,xpeak);
[x,widthpeak_grid]= meshgrid(pixels,widthpeak);

basisfunction = 1./(1+((x-xpeak_grid)./widthpeak_grid).^2);


fitprofile=basisfunction'*amppeak;
