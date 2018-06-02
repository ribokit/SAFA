function exportgel(exportimage,pointertoaxes)
% Exports to the image quant format
% Sam Pearlman, June 14, 2004
% Allowed 8-bit or 16-bit export... Rhiju, July 16, 2004.
% Allow user to set contrast and invert -- basically a total rewrite,
%   Rhiju, July 17, 2004.

axes(pointertoaxes); hold off
ContrastScale = sqrt(2);

image(abs(exportimage))
maxprof = max(max(exportimage))/16;
[Profile_Size,numprofiles_fine] = size(exportimage);
currentaxis = [1 numprofiles_fine 2 Profile_Size]; 
axis(currentaxis);


title(['Set the desired contrast scale using 1 and 2. \newline','Hit z when finished.'])

button = 1; setcontrast = 1;
while setcontrast
    grayscale = 1-gray(maxprof);
    colormap(grayscale)    

    [x,y,button] =ginput(1);
    switch char(button) 
        case '1'
            maxprof = maxprof/ContrastScale;
        case '2'
            maxprof = maxprof*ContrastScale;
        case {'q','Q','z','Z'}
            setcontrast = 0
    end
end


exportimage = 256 * exportimage/maxprof;

invertimage = questdlg('Invert? No for ImageQuant; yes for most other image-viewing applications.',...
    'Invert','Yes',' No',' No');
switch invertimage
    case 'Yes'
        exportimage = 256 - exportimage;
end    

whatres = questdlg('What grayscale resolution would you like for outputted tiff? 16-bit saves more information, but early versions of ImageQuant can only handle 8-bit.',...
    'Tiff Resolution',' 8-bit','16-bit',' 8-bit');
switch whatres
    case ' 8-bit'
        exportimage = uint8(exportimage);
    case '16-bit'
        exportimage = uint16(256*exportimage);
end    

[file,pathname] = uiputfile('*.tif','Save Gel');
if file ~= 0
    % Make this our current dir
    cd(pathname);

    fullpath=[pathname file];
    imwrite(exportimage, fullpath, 'tiff', 'Compression', 'none', 'Resolution', [127 127]);
end

%imwrite(exportimage, filename, 'TIFF');

%x =imread(filename);
%y = 2^16 - double(x);
%y=y/256; %matlab only likes to plot values from 0 to 256, 16-bit goes to 65536!
%y= y.^2 /4;

%save(fullpath,'-ASCII','-TABS','datamatrix');
