function result = getConnPxs(I)
CC = bwconncomp(I);
numPixels = cellfun(@numel,CC.PixelIdxList);
[biggest,idx] = max(numPixels);
result = zeros(500,500,'logical');
if (numPixels > 0)
result(CC.PixelIdxList{idx}) = 1;
end