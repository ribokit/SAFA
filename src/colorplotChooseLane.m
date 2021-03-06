function [picklane] = colorplotChooseLane(data,whichpeaks,handles);
% imagex_color = easycolorplot(data, normbins, titles);
%
% data     = name of text file with GelQuant output peak areas; or .mat file with data.
% normbins = residues which are constant across the titration. 
% titles   = titles for the lanes (default 1,2,3, ...)
%

if exist('handles') axes(handles.axes1); end
contrastscale=1.1;

% Basic set up.
numres   = size(data,1);
numlanes = size(data,2);

% For mutants, shift sequence to match ribozyme sequencing.
if ~exist('resequence') resequence=1:1000;end;
whichpeaks = resequence(whichpeaks)';
bckgdnum = 0;
endlane = 0;

data_orig = data;
titles = num2str([1:numlanes]');

% Bins for normalizing 
normbins = whichpeaks;
invresiduespicked=0;

normbins_indata = intersect(whichpeaks, normbins);
for k=1:length(normbins_indata) 
    invariantresidues(k) = find(normbins_indata(k) == whichpeaks);
end;

maxplot = 1;
whichlanes = 1:numlanes; normlane=[];endlane=[];

data_norm =[];
for k=1:numlanes
    if (bckgdnum >0)
        data_norm(:,k)= data(:,k)- data(:,bckgdnum);
        data_norm(:,k) = data_norm(:,k)/ mean(data_norm(invariantresidues,k),1);
    else
        data_norm(:,k)= data(:,k)/ mean(data(invariantresidues,k),1);
    end    
end    

% All residues relative to picked lane?
if ~isempty(normlane)
    if ~isempty(endlane)
        for j=1:numres
            data_norm(j,:) = (data_norm(j,:) - mean(data_norm(j,normlane),2)) / ...
                (mean(data_norm(j,endlane),2) - mean(data_norm(j,normlane),2));
        end    
    else
        for j=1:numres
            data_norm(j,:) = data_norm(j,:) / mean(data_norm(j,normlane),2);
        end    
    end
end;

% Make the plot
imagex_color = ones(numres,numlanes,3);
for k=1:numlanes
    for j=1:numres
        colorplotval = getcolor(data_norm(j,k)-1,maxplot,maxplot);
        for n=1:3
            imagex_color(j,k,n) = colorplotval(n);
        end
    end
end
plot(0,0,'w'); hold on; 
image(1:length(whichlanes), whichpeaks,imagex_color(:,whichlanes,:));

% Draw markers for normalizing lanes and standardizing residues.
if ~isempty(normlane)
    for k=normlane
        h=text(find(k==whichlanes),max(whichpeaks)+4,'N');
    end
end
if ~isempty(endlane)
    for k=endlane
        h=text(find(k==whichlanes),max(whichpeaks)+4,'F');
    end
end
if invresiduespicked
    lanes_to_add = 2;
    if(length(whichlanes) < 11) lanes_to_add = 1.5; end
    if(length(whichlanes) < 4) lanes_to_add = 1.2; end
    for k=invariantresidues
        h=text(length(whichlanes)+lanes_to_add,whichpeaks(k),'X');
    end
end
hold off
if exist('handles') set(handles.text_contrastscale,'string',['Contrast scale: ',num2str(maxplot,3)]);;end;
axis([0 length(whichlanes)+1 min(whichpeaks)-1 max(whichpeaks)+1]);
yaxislabels =    5:5:400;
set(gca,'xtick',1:length(whichlanes),'xticklabel',titles(whichlanes',:),...
    'ytick',yaxislabels,'yticklabel',resequence(yaxislabels),'ygrid','on','tickdir','out');
%    title([titleplot,' max prot/enhance: ', num2str(maxplot)]);

title('Please Choose Your Data Lane');

[x,y,button] = ginput(1);
picklane = min(max(round(x),1),length(whichlanes));
title(['Picked Lane ' num2str(picklane) '. CLICK TO CONTINUE...']);
[x,y,button] = ginput(1);
return;


function  colorplotval = getcolor(colorvalue, maxplot,maxplot2);
if (colorvalue>0)
    colorplotval = [1, max(1-colorvalue/maxplot,0), max(1-colorvalue/maxplot,0)] ;
else  
    colorplotval = [max(1+colorvalue/abs(maxplot2),0),  max(1+colorvalue/abs(maxplot2),0),1 ] ;
end


