function  [linelabels, textlabels, linelabelsT1,textlabelsT1] = redraw(profiles_align,POS_Array,xsel,xsel_T1,numfinebins,t7num,sequence,Offset);

linelabels = [];textlabels = [];
linelabelsT1 = [];textlabelsT1 = [];

labelpos = t7num*(numfinebins-1) + 1;
numprofiles_fine = size(profiles_align,2);
%image(sqrt(profiles_align)); hold on
hold on
for k=1:length(xsel)
    if (xsel(k)>0)
        yselpick = xsel(k);
        linelabels(k) = plot( [0 numprofiles_fine],[yselpick yselpick]); 
        letter = sequence(k-Offset); nucleotidecolor = getnucleotidecolor( letter);
        textlabels(k)=text( labelpos, yselpick, [letter,num2str( k)]);
        set(linelabels(k),'color',  nucleotidecolor);
        set(textlabels(k),'color',  nucleotidecolor);
    end
end

for k=1:length(xsel_T1)
    if (xsel_T1(k)>0)
        yselpick = xsel_T1(k);
        linelabelsT1(k) = plot( [0 numprofiles_fine],[yselpick yselpick]); 
        letter = sequence(POS_Array(k)-Offset); nucleotidecolor = getnucleotidecolor( letter);
        textlabelsT1(k)=text( labelpos, yselpick, num2str([letter, num2str(POS_Array(k))]));
        set(linelabelsT1(k),'color',  nucleotidecolor);
       set(textlabelsT1(k),'color',  nucleotidecolor);
        set(linelabels(POS_Array(k)), 'visible','off');
        set(textlabels(POS_Array(k)), 'visible','off');
    end
end