function [xsel,ysel,pickedpeak, grayscaleon,maxprof] = quickpolyyline(imx,dontplotthegel,xselpick,plottheline,grayscaleon,maxprof,ContrastScale)
% [xsel,ysel] = quickpolyyline(imx,dontplotthegel)
% allows user to defines a polyline moving down through the gel.
%   If any number for dontplotthegel is inputed, routine doesn't
%   replot the gel.
%    Rhiju Das, August 29 2003.

pickedpeak = 0;
if (nargin<1) hold off;figure(1);image(imx);end;
if (nargin<5) grayscaleon = 1; maxprof = 1;end;
hold on;
numypixels=size(imx,1);
numxpixels=size(imx,2);
title([...
        'left                : next point of anchorline \newline',...
        'middle (shift-click)  : undo point \newline',...
        'right  (ctrl-click): finished']);
count=1;button=0;
if (nargin>2) ysel(1) = 0; xsel(1) = xselpick; count=2; firstsymbol=plot(xsel(1),2,'ro');end;

finishedline = 0;
while (finishedline == 0)
    [xsel(count),ysel(count),button]=ginput(1);
    if(button==2) 
        count=count-1; count = max(count,1);
        if (count>1) set(h{count},'Visible','off');end
    end;
    
    if count==1; ysel(1)=0; plot(xsel(1),ysel(1),'ro');
    elseif (button==1)
        h{count}= plot([xsel(count-1) xsel(count)],[ysel(count-1) ysel(count)],'r'); 
        if ysel(count) == ysel(count-1) ysel(count) = ysel(count-1)+0.5;    end;
        pickedpeak=1;  count=count+1;
    end    

    if (button == 3) finishedline = 1; end;
        
    if (nargin>5)
           switch char(button)
            case '1'
                maxprof = maxprof/ContrastScale;
                setcolormap(grayscaleon, maxprof);    
            case '2'
                maxprof = maxprof*ContrastScale;
                setcolormap(grayscaleon, maxprof);    
            case {'c','C'}
                grayscaleon = 1 - grayscaleon;
                setcolormap(grayscaleon, maxprof);    
        end
    end
end

count=count-1; count = max(count,1);
ysel(count)=numypixels;
lastsymbol = plot(xsel(count),ysel(count),'ro');

if (count>1) 
    set(h{count},'visible','off');
    h{count}= plot([xsel(count-1) xsel(count)],[ysel(count-1) ysel(count)],'r'); 
    if (plottheline == 0) 
        for i=1:count
            set(h{i},'visible','off');
            set(firstsymbol,'visible','off');
            set(lastsymbol,'visible','off');
        end
    end
end;


if (count<2) pickedpeak=0; set(firstsymbol,'visible','off');set(lastsymbol,'visible','off');end;

xsel=xsel(1:count);    ysel=ysel(1:count);
hold off

