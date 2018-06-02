function [xsel_bound_fine,xsel_center,laneboundaries] = definelanes(imagey,numfinebins,laneboundaries,pointertoaxis);
% [xsel_bound_fine,xsel_center] = definelanes(imagey,numfinebins);
% Allows the user to define the *boundaries* of the lanes on the gel,
% with semi-automated computer assistance, if desired.
%  numfinebins is the number of subdivisions of each lane to define, e.g.  for bootstrapping.
%   Rhiju Das, August 31 2003. COmpletely revamped by R. Das, June 2004.

if (nargin>3)
    axes(pointertoaxis);
end
% Set the amount of change for the contrast
ContrastScale = sqrt(2);
global maxprof;
global grayscaleon;
global renderSqrt;

%axes(pointertoaxes);
hold off;
if(renderSqrt == 1)
    image(sqrt(abs(imagey)));
else
    image(abs(imagey));
end

% No longer setting maxprof every time!
%maxprof = max(max(imagey))/80;
%grayscaleon = 1;
%setcolormap(grayscaleon,maxprof);

[imagesizey,imagesizex] = size(imagey);
currentaxis = [1 imagesizex 1 imagesizey];
axis(currentaxis);zoomedin = 0;
%User may already have some lanebondaries (empty set if not), and have to
%plot them.
count = size(laneboundaries,1);
hold on
for i=1:count
    laneline(i)    = plot(laneboundaries(i,:),        1:imagesizey,'r');
    firstsymbol(i) = plot(laneboundaries(i,1),                  2,'ro');
    lastsymbol(i)  = plot(laneboundaries(i,imagesizey),imagesizey,'ro');
end
hold off

plottitle_usual = [...
    'left button: make a lane boundary  right button (apple-click): zoom in/out \newline',...
    '1,2,C: adjust colorscale  E:erase lane   G: guess the next lane boundary \newline',...
    'R:   refine your line  Z:finished'];
plottitle=plottitle_usual;


pickedpeak = 0;
stopinput = 0;

while (stopinput == 0)
    title(plottitle); plottitle = plottitle_usual;
    [xselpick,yselpick,button] = ginput(1);
    switch(button)
        case 1 %User is starting to make a lane boundary.
            [xsel,ysel,pickedpeak, grayscaleon,maxprof] = quickpolyyline(imagey,0,xselpick,0,grayscaleon,maxprof,ContrastScale);
            if (pickedpeak>0)
                count = count + 1;
                laneboundaries(count,:) = interp1(ysel,xsel,1:imagesizey);
                hold on;
                laneline(count)    = plot(laneboundaries(count,:),        1:imagesizey,'r');
                firstsymbol(count) = plot(laneboundaries(count,1),                  2,'ro');
                lastsymbol(count)  = plot(laneboundaries(count,imagesizey),imagesizey,'ro'); hold off
            end
            %Keep lanes numbered in order.
            [laneboundaries,sortindex] = sortrows(laneboundaries);
            laneline = laneline(sortindex); firstsymbol = firstsymbol(sortindex); lastsymbol = lastsymbol(sortindex);
        case 2 %erase last line..
            button = 'e';
            xselpick = laneboundaries(count,min(max(round(yselpick),1),imagesizey));
            %This will activate the "erase" commands below for the last line...
        case 3  %Zoom in/out
            if (zoomedin == 1)
                currentaxis = [1 imagesizex 1 imagesizey];
                axis(currentaxis);
                zoomedin = 0;
            else
                xselzoom = xselpick;
                xmin = max(round(xselzoom - imagesizex/10),0);
                xmax = min(round(xselzoom + imagesizex/10),imagesizex);
                currentaxis=[xmin xmax 1 imagesizey ];
                axis(currentaxis);
                zoomedin = 1;
            end
    end
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
        case {'q','Q','z','Z'} %Done.
            stopinput = 1;
            stopalign = 1;
        case {'e','E'} %erase line
            %What is the closest lane boundary?
            [dummy,eraseindex] = min(    abs(laneboundaries(:, max(min(round(yselpick),imagesizey),1)) - xselpick) );
            set(   laneline(eraseindex),'visible','off');
            set(firstsymbol(eraseindex),'visible','off');
            set( lastsymbol(eraseindex),'visible','off');
            %Get rid of this laneboundary in memory as well...
            laneboundaries(eraseindex:count-1,:) = laneboundaries(eraseindex+1:count,:) ;
            laneboundaries = laneboundaries(1:count-1,:);
            count = count-1;
        case{'g','G'} %Computer will guess the next lane boundary.
            if (count>1)
                numlaneboundaries = size(laneboundaries,1);
                extwidth = mean(laneboundaries(count,:)  - laneboundaries(count-1,:));
                xsel_temp = laneboundaries(count,:) + extwidth;

                if (max(xsel_temp)< imagesizex)
                    %                xsel_refine = refinelanes(xsel_temp,1:imagesizey,roughwidth,imagey);
                    %To speed things up, do the refinement only for points
                    %spread out by a spacing equal to roughly the width of the
                    %lane.
                    roughwidth = round(extwidth/2);  roughpoints = [1:roughwidth:imagesizey-0.5 imagesizey];
                    xsel_refine = refinelanes(xsel_temp(roughpoints),roughpoints,roughwidth,imagey);
                    xsel_refine = interp1(roughpoints,xsel_refine,1:imagesizey);
                    count=count+1; laneboundaries(count,:) =xsel_refine;
                    hold on
                    laneline(count)    = plot(laneboundaries(count,:),        1:imagesizey,'r');
                    firstsymbol(count) = plot(laneboundaries(count,1),                  2,'ro');
                    lastsymbol(count)  = plot(laneboundaries(count,imagesizey),imagesizey,'ro'); hold off
                else
                    h=errordlg(['All the way at the right of the gel already!'],'Error');
                    uiwait(h);
                end
            else
                h=errordlg(['You need at least two lane boundaries defined before SAFA ',...
                    'can guess the next one. Use mouse-click to define a new lane.'],'Error');
                uiwait(h);
            end
        case {'r','R'} %refine line
            %What is the closest lane boundary?
            [dummy,refineindex] = min(    abs(laneboundaries(:, max(min(round(yselpick),imagesizey),1)) - xselpick) );
            if (count>1)
                set(   laneline(refineindex),'visible','off');
                set(firstsymbol(refineindex),'visible','off');
                set( lastsymbol(refineindex),'visible','off');
                xsel_temp = laneboundaries(refineindex,:);
                extwidth = mean(laneboundaries(2,:)  - laneboundaries(1,:));
                roughwidth = round(extwidth/2);  roughpoints = [1:roughwidth:imagesizey-0.5 imagesizey];
                xsel_refine = refinelanes(xsel_temp(roughpoints),roughpoints,roughwidth,imagey);
                xsel_refine = interp1(roughpoints,xsel_refine,1:imagesizey);
                laneboundaries(refineindex,:) =xsel_refine;
                hold on
                laneline(refineindex)    = plot(laneboundaries(refineindex,:),        1:imagesizey,'r');
                firstsymbol(refineindex) = plot(laneboundaries(refineindex,1),                  2,'ro');
                lastsymbol(refineindex)  = plot(laneboundaries(refineindex,imagesizey),imagesizey,'ro'); hold off
            else
                h=errordlg(['You need at least two lane boundaries defined before SAFA ',...
                    'can refine a line. Use mouse-click to define a new lane...'], 'Error');
                uiwait(h);
            end
    end
end


if (count>1)
    %Defining centers as half-way between lane boundaries.
    xsel_center=(laneboundaries(1:count-1,:) + laneboundaries(2:count,:))/2;

    %Finer subdivisions within each lane, by straightforward linear interpolation.
    xsel_bound = laneboundaries;
    countfine = 0;
    for k=1:count-1
        for j=0:numfinebins-1
            countfine=countfine+1;
            xsel_bound_fine(countfine,:)= ((numfinebins-j)*xsel_bound(k,:) + j*xsel_bound(k+1,:))/numfinebins;
        end
    end
    countfine=countfine+1;
    xsel_bound_fine(countfine,:)= xsel_bound(count,:);

    plotbounds(imagey,1:imagesizey,xsel_bound,xsel_center);
    hold off
else
    xsel_center=[];
    xsel_bound_fine = [];
end

title('Done defining lanes.');

function xsel_refine = refinelanes(xsel_temp,ysel_temp,roughwidth,imagey);
% Takes initial guess for line through gel, and looks in neighborhood
% for minimum -- helps to define lane boundaries.

[numypixels,numxpixels] = size(imagey);
xsel_refine = xsel_temp;

for i = 1:length(ysel_temp)
    y=ysel_temp(i);
    xmiddle= xsel_temp(i);
    xmin = max(round(xmiddle-roughwidth/4), 0) ;
    xmax = min(round(xmiddle+roughwidth/4),numxpixels) ;
    ymin = max(round(y-4*roughwidth),         1);
    ymax = min(round(y+4*roughwidth), numypixels);
    averagepatch = mean(imagey(ymin: ymax, ...
        xmin:xmax), 1);
    averagepatch = averagepatch ;%+ 10*(([xmin:xmax]-xmiddle)/roughwidth).^2;
    [dummy, xsel_refine(i)] = ...
        min(averagepatch);
    xsel_refine(i) = xsel_refine(i)+xmin-1;
end

