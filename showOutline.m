function showOutline(I, I_outline) 
BWoutlineThin = bwperim(I_outline);
BWoutline = imdilate(BWoutlineThin, true(3));
Segout = I; 
Segout(BWoutline) = 255; 

SegoutR = I;
SegoutG = I;
SegoutB = I;
%now set yellow, [255 255 0]

SegoutR(BWoutline) = 255;
SegoutG(BWoutline) = 255;
SegoutB(BWoutline) = 0;
SegoutRGB = cat(3, SegoutR, SegoutG, SegoutB);

figure, imshow(SegoutRGB), title('outlined original image');