function SegoutRGB = addOutlinesRGB(I, outlines)
SegoutR = I;
SegoutG = I;
SegoutB = I;
for i=1:5
	curr_outline = squeeze(outlines(i, :, :));
	BWoutlineThin = bwperim(curr_outline);
	BWoutline = imdilate(BWoutlineThin, true(3));
	switch i 
		case 1
			SegoutR(BWoutline) = 255;
			SegoutG(BWoutline) = 0;
			SegoutB(BWoutline) = 0;
			SegoutRGB = cat(3, SegoutR, SegoutG, SegoutB);		
		case 2
			SegoutR(BWoutline) = 0;
			SegoutG(BWoutline) = 255;
			SegoutB(BWoutline) = 0;
			SegoutRGB = cat(3, SegoutR, SegoutG, SegoutB);		
		case 3
			SegoutR(BWoutline) = 0;
			SegoutG(BWoutline) = 255;
			SegoutB(BWoutline) = 255;
			SegoutRGB = cat(3, SegoutR, SegoutG, SegoutB);		
		case 4
			SegoutR(BWoutline) = 255;
			SegoutG(BWoutline) = 0;
			SegoutB(BWoutline) = 255;
			SegoutRGB = cat(3, SegoutR, SegoutG, SegoutB);		
		case 5
			SegoutR(BWoutline) = 255;
			SegoutG(BWoutline) = 255;
			SegoutB(BWoutline) = 0;
			SegoutRGB = cat(3, SegoutR, SegoutG, SegoutB);
	end
end