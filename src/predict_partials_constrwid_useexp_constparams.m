function prt = predict_partials(pixels,f,params,dp,F,const_params)
numpeaks  = length(params);
%Function assumes you are submitting log of the amplitudes!
amppeak   = exp(params(  1 : numpeaks ));
xpeak     = const_params( 1 : numpeaks );
propconst = const_params(numpeaks+1);
minwidth  = const_params(numpeaks+2);

distpeak = getdistpeak(xpeak');
widthpeak = distpeak'*propconst + minwidth;

[x,xpeak_grid]     = meshgrid(pixels,xpeak);
[x,widthpeak_grid] = meshgrid(pixels,widthpeak);
[x,amppeak_grid]   = meshgrid(pixels,amppeak);

%Partial derivatives of a Lorentzian.
%The basis functions:
lorentzian = 1./(1+((x-xpeak_grid)./widthpeak_grid).^2);
%Partial derivatives with respect to x (peak positions).
%%%prt(1:numpeaks,             :) = -2*amppeak_grid.*(lorentzian.^2).*(xpeak_grid-x)./widthpeak_grid.^2;
%Partial derivatives with respect to amplitudes -- actually log(zeta)!
%prt(numpeaks+1:2*numpeaks,  :) = amppeak_grid.*lorentzian;
prt(1:numpeaks,  :) = amppeak_grid.*lorentzian;

%Partial derivatives with respect to widths. 
%%%widthprt = +2*amppeak_grid.*(lorentzian.^2).*((xpeak_grid-x).^2) ./widthpeak_grid.^3;
%%%dwid_dpropconst = distpeak'; 
%%%dwid_dminwid    = ones(1,numpeaks); 

%%%size(dwid_dpropconst)
%%%size(widthprt)
%%%size(prt)
%%%prt(2*numpeaks+1,:) = dwid_dpropconst' *widthprt;
%%%prt(2*numpeaks+2,:) =    dwid_dminwid  *widthprt;

prt = prt';
