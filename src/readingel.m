function [imagey, gelbounds] = readingel(filename,pointertoaxis,gelbounds);
%imagey = readingel(filename);
% Reads in the image quant format and allows
% the user to crop it to the useful region, usually.
% right above the main (uncleaved) band and down to the last band.
%   Rhiju Das, August 29 2003.
ContrastScale = sqrt(2);
global maxprof;
global grayscaleon;
global renderSqrt;

hold off
x=imread(filename);

y = 2^16 - double(x);
y=y/256; %matlab only likes to plot values from 0 to 256, 16-bit goes to 65536!
y= y.^2 /4;

%Special case if gel image is a regular tiff.
if ( ~isempty(regexp(filename, '.tif')) |   ~isempty(regexp(filename, '.TIF')))
    y = double(x);
    if max(max(y))<256 %Looks like an 8-bit image rather than 16-bit
        y=256*y;
    end
end

%figure(1);subplot(1,1,1);hold off; 
if (nargin>1) axes(pointertoaxis);end;
if(renderSqrt == 1)
    image(sqrt(y));
else
    image(y);
end
maxprof = squeeze(max(max(y)))/80;
grayscaleon = 1;
setcolormap(grayscaleon, maxprof);    

havegelbounds = 0;
if (nargin>2)    if length(gelbounds)==4 havegelbounds = 1;    end; end;

[numypixels,numxpixels] = size(y);
if havegelbounds
    leftx   = gelbounds(1);
    topy    = gelbounds(2);
    rightx  = gelbounds(3);
    bottomy = gelbounds(4);
else
    cropchosen = 0;
    while (cropchosen == 0)    
        title(['Define rectangle to crop Gel. Hit Q/Z to accept. \newline'...
                '1,2,C: change colorscale.'] )
        [xpick,ypick,button]=ginput(1); point1 = [xpick,ypick];
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
            case {'q','Q','z','Z'}
                cropchosen = 1;
        end
        switch button
            case {1,2,3}
                if exist('h') set(h,'visible','off'); end;
                finalRect = rbbox;                   % return figure units
                point2 = get(gca,'CurrentPoint');    % button up detected
                point1 = point1(1,1:2);              % extract x and y
                point2 = point2(1,1:2);
                p1 = min(point1,point2);             % calculate locations
                offset = abs(point1-point2);         % and dimensions
                leftx = p1(1);
                topy  = p1(2);
                rightx= p1(1) + offset(1);
                bottomy=p1(2) + offset(2);
                
                leftx = max(min(leftx,numxpixels),1);
                rightx = max(min(rightx,numxpixels),1);
                topy = max(min(topy,numypixels),1);
                bottomy = max(min(bottomy,numypixels),1);
                if (rightx-leftx >0 & bottomy-topy>0)
                    h = rectangle('position',[leftx topy rightx-leftx bottomy-topy]);
                    set(h,'edgecolor','r');          % draw box around selected region    title('Define bottom right corner of gel:')
                end    
            end
        end
    end
    
    imagey = y(round(topy): round(bottomy),...
        round(leftx):round(rightx));

    if(renderSqrt == 1)
        image(sqrt(imagey));
    else
        image(imagey);
    end
    
    gelbounds(1)=    leftx;
    gelbounds(2)=    topy  ;
    gelbounds(3)=    rightx;
    gelbounds(4)=    bottomy;
