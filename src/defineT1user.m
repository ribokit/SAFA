function [xsel,xsel_T1] = defineT1user(profiles_align,POS_Array,numfinebins,t1num,startnum,xsel,xsel_T1,sequence,Offset,pointertoaxis);
%[xsel,xsel_T1] =defineT1user(profiles_align,POS_Array,numfinebins,t1num,startnum,xsel,xsel_T1)
%
% Updated by R. Das and A. Laederach, 16 June,  2004 to 
%   make lines match color.
%
% Although original code was written just to assign G-cleavage sites in a
% T1 ladder, the program is now more flexible -- though we didn't change
% the "T1" and "G" terminology in the code.
%
% Set the amount of change for the contrast -- S. Pearlman
numlanes = size(profiles_align,2);
ContrastScale = sqrt(2);
global maxprof;
global grayscaleon;
global renderSqrt;

if (nargin>9) axes(pointertoaxis); end;
hold off;
if(renderSqrt == 1)
    image(sqrt(abs(profiles_align)));
else
    image(abs(profiles_align));
end
hold on

%maxprof = round(max(max(profiles_align))/80);
%grayscaleon = 1;
%setcolormap(grayscaleon, maxprof);   

set(gca,'xtick',(numfinebins+1)/2:numfinebins:numlanes,'xticklabel',1:numlanes/numfinebins,'xminortick','on');

numprofiles_fine = size(profiles_align,2);
Profile_Size = size(profiles_align,1);
totalGs = length(POS_Array);

plottitle = [...
        'left button: set reference band    middle button (option-click): undo \newline',...
        'right button (ctrl-click): zoom in/out \newline',...
        '1,2,C: adjust colorscale    E,R:erase/refine       Q or Z:finished'];


%5' or 3' labeled?
whichdirection = sign(POS_Array(2) - POS_Array(1));

labelpos = t1num*(numfinebins-1) + 1;
currentaxis = [1 numprofiles_fine 1 Profile_Size];
axis(currentaxis);
stopinput = 0; zoomedin = 0; foundonepeak = 0;

if (nargin<6)
    xsel=[]; xsel_T1 = []; linelabels=[];textlabels=[];linelabelsT1=[];textlabelsT1=[];
    countG = max(find(le(whichdirection*POS_Array,whichdirection*startnum)));
elseif (length(xsel) == 0)
    xsel=[]; xsel_T1 = []; linelabels=[];textlabels=[];linelabelsT1=[];textlabelsT1=[];
    countG = max(find(le(whichdirection*POS_Array,whichdirection*startnum)));
else    
    countG = length(xsel_T1)+1;
    currentG = POS_Array(countG);
    [linelabels, textlabels, linelabelsT1,textlabelsT1] = redraw(profiles_align,POS_Array,xsel,xsel_T1,numfinebins,t1num,sequence,Offset);    
    if (countG>1)
        prevG = POS_Array(countG-1);
        foundonepeak = 1;
    end
end

while (stopinput == 0)
    title( [plottitle,'\newline',num2str(POS_Array(countG: min(countG+10,totalGs) ))]);
    [xselpick,yselpick,button] = ginput(1);
    switch button
        case 1
            if (foundonepeak)                 
                xsel_T1(countG)         = yselpick;
                xsel(POS_Array(countG)) = yselpick;
                currentG = POS_Array(countG);
            else %Special -- it's the first peak
                if (find(POS_Array == startnum)) xsel_T1(countG) = yselpick; end;
                xsel(startnum) = yselpick; currentG = startnum;
            end
            linelabelsT1(countG) =plot( [0 numprofiles_fine],[yselpick yselpick]);
            %what letter is this?
            letter = sequence(currentG-Offset); nucleotidecolor = getnucleotidecolor( letter);
            textlabelsT1(countG) =text( labelpos, yselpick, [letter,num2str(currentG)]);
            set(linelabelsT1(countG),'color',  nucleotidecolor,'clipping','on');
            set(textlabelsT1(countG),'color',  nucleotidecolor,'clipping','on');

            textlabels(currentG) =text( labelpos, yselpick, [letter,num2str(currentG)]);
            linelabels(currentG) =plot( [0 numprofiles_fine],[yselpick yselpick]);
            set(textlabels(currentG),'visible','off');
            set(linelabels(currentG),'visible','off');
            
            if (foundonepeak) 
                [xsel,linelabels,textlabels] = ...
                    fillinpeaks(xsel_T1,xsel,POS_Array,prevG,currentG,...
                    numprofiles_fine,labelpos,linelabels,textlabels,whichdirection,sequence,Offset); 
            end;
            foundonepeak = 1; prevG= currentG;
            countG = countG+1; 
        case 2 %user wants to undo last move...
            if (foundonepeak)
                countG = countG-2; 
                xsel_T1 = xsel_T1 (1:countG);
                if (whichdirection>0) xsel    = xsel    (1:POS_Array(countG));
                else xsel(1: POS_Array(countG)-1) = 0*xsel(1: POS_Array(countG)-1);
                end
                countG = countG + 1;
                
                set(textlabelsT1(countG),'visible','off');
                set(linelabelsT1(countG),'visible','off');
                prevG = POS_Array(countG-1); currentG = POS_Array(countG);
                for k=prevG+whichdirection:whichdirection:currentG-whichdirection
                    set(textlabels(k),'visible','off');
                    set(linelabels(k),'visible','off');
                end
            end            
        case 3        
            if (zoomedin == 1)
                currentaxis = [0 numprofiles_fine 1 Profile_Size]; 
                axis(currentaxis);
                zoomedin = 0;
            else
                yselzoom = yselpick;
                ymin = max(round(yselzoom - Profile_Size/10),0);
                ymax = min(round(yselzoom + Profile_Size/10),Profile_Size);
                currentaxis=[1 numprofiles_fine ymin ymax ];
                axis(currentaxis);
                zoomedin = 1;
            end
    end;
    
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
        case {'e','E'} %erase line
            [dummy, erasepeak] = min( (yselpick - xsel).^2 );
            if (erasepeak>1)
                k=erasepeak;
                set(textlabels(k),'visible','off');
                set(linelabels(k),'visible','off');
                findG = find(POS_Array == k);
                if (findG) %This is a G
                    set(textlabelsT1(findG),'visible','off');
                    set(linelabelsT1(findG),'visible','off');
                end
                [xselpeak,yselpick,button] = ginput(1);
                xsel(k) = yselpick;
                if (findG) 
                    xsel_T1(findG) = yselpick;
                    linelabelsT1(findG) = plot( [0 numprofiles_fine],[yselpick yselpick]); 
                    letter = sequence(k-Offset); nucleotidecolor = getnucleotidecolor( letter);
                    textlabelsT1(findG)=text( labelpos, yselpick, [letter,num2str( k)]); 
                    %what letter is this?
                    set(linelabelsT1(findG),'color',  nucleotidecolor,'clipping','on');
                    set(textlabelsT1(findG),'color',  nucleotidecolor,'clipping','on');
                else
                    linelabels(k) = plot( [0 numprofiles_fine],[yselpick yselpick]); 
                    letter = sequence(k-Offset); nucleotidecolor = getnucleotidecolor( letter);
                    textlabels(k)=text( labelpos, yselpick, [letter,num2str( k)]); 
                    %what letter is this?
                    set(linelabels(k),'color',  nucleotidecolor,'clipping','on');
                    set(textlabels(k),'color',  nucleotidecolor,'clipping','on');
                end
            end    
        case {'r','R'} %erase and refine line
            [dummy, erasepeak] = min( (yselpick - xsel).^2 );
            if (erasepeak>0)
                k=erasepeak;
                set(textlabels(k),'visible','off');
                set(linelabels(k),'visible','off');
                findG = find(POS_Array == k);
                if (findG) %This is a G
                    set(textlabelsT1(findG),'visible','off');
                    set(linelabelsT1(findG),'visible','off');
                end
                [xselpeak,yselpick,button] = ginput(1);
                xsel(k) = yselpick;
                if (findG) xsel_T1(findG) = yselpick;end;
                linelabels(k) = plot( [0 numprofiles_fine],[yselpick yselpick]); 
                letter = sequence(k-Offset); nucleotidecolor = getnucleotidecolor( letter);
                textlabels(k)=text( labelpos, yselpick, [letter,num2str( k)]); 
                set(linelabels(k),'color',  nucleotidecolor,'clipping','on');
                set(textlabels(k),'color',  nucleotidecolor,'clipping','on');
                
                if (isempty(findG)) 
                    %user would like guessed band positions rescaled between this and neighboring G's.
                    loGnum = max(find(POS_Array < k));
                    hiGnum = loGnum + 1;
                    loG = POS_Array(loGnum);
                    hiG = POS_Array(hiGnum);
                    for n = loG+1 : k-1
                        set(textlabels(n),'visible','off');
                        set(linelabels(n),'visible','off');
                        xsel(n) =  xsel(loG) +  ((n-loG)/(k-loG))*(xsel(k)-xsel(loG));
                        linelabels(n) = plot( [0 numprofiles_fine],[xsel(n) xsel(n)]); 
                        letter = sequence(n-Offset); nucleotidecolor = getnucleotidecolor( letter);
                        textlabels(n)=text( labelpos, xsel(n), [letter,num2str( n)]);             
                        set(linelabels(n),'color',  nucleotidecolor,'clipping','on');
                        set(textlabels(n),'color',  nucleotidecolor,'clipping','on');
                    end    
                    for n = k+1: hiG-1
                        set(textlabels(n),'visible','off');
                        set(linelabels(n),'visible','off');
                        xsel(n) =  xsel(hiG) +  ((n-hiG)/(k-hiG))*(xsel(k)-xsel(hiG));
                        linelabels(n) = plot( [0 numprofiles_fine],[xsel(n) xsel(n)]); 
                        letter = sequence(n-Offset); nucleotidecolor = getnucleotidecolor( letter);
                        textlabels(n)=text( labelpos, xsel(n), [letter,num2str( n)]);             
                        set(linelabels(n),'color',  nucleotidecolor,'clipping','on');
                        set(textlabels(n),'color',  nucleotidecolor,'clipping','on');
                        
                    end   
                end
            end    
        case {'t','T'}
            useT1calibration(profiles_align,POS_Array,numfinebins,t1num,xsel,xsel_T1)
        case {'q','Q','z','Z'}
            stopinput = 1;
    end
end

title('Done assigning bands.');    
