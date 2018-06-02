function  [xsel,linelabels,textlabels] =...
    fillinpeaks(xsel_T1,xsel,POS_Array,prevG,currentG,numprofiles_fine,labelpos,linelabels,textlabels,whichdirection,sequence,Offset);

startpeak =    prevG+ whichdirection*1;
countpeak = currentG- whichdirection*1;

for k=startpeak:whichdirection:countpeak;
    yselpick = xsel(prevG) -   (k-prevG) * (xsel(prevG)- xsel(currentG))/(currentG-prevG);
    xsel(k) = yselpick;
    linelabels(k) = plot( [0 numprofiles_fine],[yselpick yselpick]); 
    letter = sequence(k-Offset); nucleotidecolor = getnucleotidecolor( letter);
    textlabels(k)=text( labelpos, yselpick, [letter,num2str( k)]); 
    set(linelabels(k),'color',  nucleotidecolor);
    set(textlabels(k),'color',  nucleotidecolor);
    
end
