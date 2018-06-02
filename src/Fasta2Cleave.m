function [POS_array,sequence,Offset,cleavage_sites,threeprime,SeqSelectionWindow]=Fasta2Cleave(file, pathname)

fullpath=[pathname file];
if ~isequal(file, 0)
    % prompt={'Enzyme Cleavage Site','Offset (Starting Position of the sequence for full length numbering' };
    %    def={'G','21'};
    %    dlgTitle='Reference Ladder';
    %    lineNo=1;
    %    answer=inputdlg(prompt,dlgTitle,lineNo,def);
    
    filename=fullpath;
    %    Cleave_Site=answer(1,:);
    %    Off_Set=str2num(answer{2});
    
    fid=fopen(filename,'r');
    
    %Cleave_Site=upper(Cleave_Site);
    
    numlines=0; EOF = 0; count=0;
    sequence= '';
    while EOF == 0
        numlines = numlines+1;
        line = fgets(fid);
        
        if (count == 1);
            seq_tmp = deblank(line);
            if (strcmp(seq_tmp,'')~=1)
                sequence = strcat(sequence,seq_tmp);
            end
        end 
        
        if (strcmp(line(1),'>')==1);
            count=1;
        end
        
        EOF=feof(fid);
    end
    % End read in Sequence
    %U C G A T
    
    sequence=upper(sequence);
    %[cleavage_sites,threeprime,Offset]=SeqSelection(sequence, [0; 0; 1; 1; 0;], 22, 1);
    [cleavage_sites,threeprime,Offset,SeqSelectionWindow]=SeqSelection(sequence);
    char_string='UCGAT';
    cleave_pattern=char_string(find(cleavage_sites));
    POS_array=find_positions(sequence,cleave_pattern);
    POS_array=POS_array+Offset;
    
    if threeprime==1;
        num_pos=max(size(POS_array));
        POS_array=POS_array(num_pos:-1:1);
    end
else
    warndlg('No Sequence File Read in.','Error in Opening Sequence');
end


function POS_array=find_positions(sequence,cleave_pattern)
num_letters=max(size(cleave_pattern));
POS_array=[];
for i=1:num_letters
    POS_array = cat(2,POS_array,find(sequence==cleave_pattern(i)));
end
POS_array=sort(POS_array);
