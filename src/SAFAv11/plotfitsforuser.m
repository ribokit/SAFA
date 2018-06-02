function plotfitsforuser(profiles_combine,profiles_pred,peakarea,xsel_all,widthpeak_all,numplots);
%
% For the user, plots profiles down each lane, with fit to profile,
%   and component Lorentzians
%
% R. Das and S. Pearlman, June 23, 2004
%
figure(3)
subplot(1,1,1);
if (nargin<6) numplots=5;end;

numlanes = size(xsel_all,2);
numpixels = size(profiles_pred,1);
%Find where predicted profiles are greater than zero.

pixels = min(find(sum(profiles_pred,2)>0)) : ...
    max(find(sum(profiles_pred,2)>0));
amppeak_all = (1/pi) * peakarea./widthpeak_all;

for i=1:numlanes
    %Clear screen before every set of plots.
    if (mod(i,numplots)==1)           subplot(1,1,1); 
    end
    
    %Find right place to plot every 10 lanes.
    subplot(numplots,1, mod(i-1,numplots)+1)
    plot(pixels,profiles_combine(pixels,i),'b-');
    hold on
    plot(pixels,profiles_pred(pixels,i),'color',[0 0.5 0]);
    %Make Lorentzians that make up the fit.
    numpeaks = size(xsel_all,1);
    [x,xpeak_grid]    =meshgrid(pixels,     xsel_all(:,i));
    [x,widthpeak_grid]=meshgrid(pixels,widthpeak_all(:,i));
    [x,amppeak_grid]  =meshgrid(pixels,amppeak_all(:,i));
    predlorentz = 1./(1+((x-xpeak_grid)./widthpeak_grid).^2);    
    plot(pixels,amppeak_grid'.*predlorentz' ,'r');
    hold off
    title(['Lane ',num2str(i)]);
    ylabel('Counts');
    shg  
    if (mod(i,numplots) == 1)  
        legend('Data','Fit','Component Lorentzians');
    end;
    if (mod(i,numplots) == 0)  
        xlabel('Distance down gel');
        [xselect,yselect,button] = ginput(1); 
        switch char(button)
            case {'q','Q','z','Z'}
                uiwait(errordlg('Done plotting.','OK','OK'));
                break
        end
    end;    
end
