function    nucleotidecolor = getnucleotidecolor(  letter);

char_string='UCGAT';
site_colors = [0 1 0; 0 0 1;1 0.5 0.2;1 0 0; 0 1 0];

nucleotidecolor = [1 0 1];
for i=1: max(size(char_string))
    if char_string(i) == letter
        nucleotidecolor = site_colors(i,:);
    end
end
