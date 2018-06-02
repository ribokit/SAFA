function [xpeak_fit,widthpeak,amppeak,areapeak,propconst_fit,minwidth_fit] = fitsetoflorentzians_constrwid(Profile_tofit,numres,xsel,propconst,minwidth)
figure(2);
subplot(3,1,1);
hold off;
numpeaks = length(numres);

xpeak = xsel(numres);
amppeak = Profile_tofit(round(xpeak))';

% Provide default Lorentzian coefficients if not passed in as arguments
if (nargin<4) propconst=0.1; minwidth = 3; end;
distpeak = getdistpeak(xpeak);
widthpeak = distpeak'*propconst + minwidth;

minbin = round(min(xpeak));
maxbin = min( round(max(xpeak)+max(widthpeak)), length(Profile_tofit)) ;
profiles = Profile_tofit(minbin:maxbin)';
pixels   = [minbin:maxbin]';

pin=[xpeak log(amppeak) propconst minwidth];

if (length(pixels) < length(pin)) %bad situation : more parameters than data to fit!
    pixelsnew = [1:length(pin)+1]*(max(pixels)-min(pixels))/(length(pin)+1) +  min(pixels);
    profiles = interp1(pixels,profiles,pixelsnew);
    pixels = pixelsnew';
end

stol=0.01;
niter=5;
wt=0*pixels+1;
dp=0*pin+1;

options = [0*pin; widthpeak'/100, Inf*amppeak, Inf,Inf]';
%options = [0*pin; widthpeak/10, widthpeak/10, Inf*amppeak]';
%options = [widthpeak/100, widthpeak/100, amppeak/100; Inf*pin]';
%params = pin;

[f,params,kvg,iter,corp,covp,covr,stdresid,Z,r2]= ...
      leasqr(pixels, profiles,pin,'predict_profile_constrwid_useexp',stol,niter,wt,dp,'predict_partials_constrwid_useexp',options);

% Extract the peak positions, their amplitudes and the 
% two Lorentzian coefficients from params
xpeak_fit=params(  1         : numpeaks)';
% Now take the exponential of the fitted peak amplitudes
amppeak  = exp(params( numpeaks+1: 2*numpeaks))';
propconst_fit = params(2*numpeaks+1);
minwidth_fit  = params(2*numpeaks+2);

% Get the distance between peaks
distpeak = getdistpeak(xpeak);
% Use our Lorentzian coefficients and the distances 
% betweeen peaks to get our Lorentzian widths
widthpeak = distpeak'*propconst_fit + minwidth_fit;

% Plot all the Lorentzians
hold on
for k=1:numpeaks
    predlorentz = getlorentzian(pixels,xpeak_fit(k), widthpeak(k),amppeak(k)); 
    plot(pixels, predlorentz,'r');
end

%hold on
%for k=1:numpeaks; plot([xpeak(k) xpeak(k)],[0 amppeak(k)],'k'); hold on; end;
hold off

areapeak = pi*amppeak.*widthpeak'; 
subplot(3,1,2);
plot(numres,areapeak,'color','k');
axis([min(numres) max(numres) 0 max(areapeak)]);
shg
