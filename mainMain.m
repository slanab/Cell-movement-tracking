%% Commonly used elements
seD01 = strel('disk', 1);
seD03 = strel('disk', 3);
seD05 = strel('disk', 5);
seD10 = strel('disk', 10);
seD15 = strel('disk', 15);
seD20 = strel('disk', 20);
seD25 = strel('disk', 25);
se290 = strel('line', 2, 90);
se200 = strel('line', 2, 0);
se390 = strel('line', 3, 90);
se300 = strel('line', 3, 0);
se590 = strel('line', 5, 90);
se500 = strel('line', 5, 0);

%% Get original outlines
x_Directory = uigetdir;
x_Files_Tif = dir([x_Directory, '\*.tif']);
x_Filename_Tif = {x_Files_Tif.name}';
fnRefOl = fullfile (x_Directory, x_Filename_Tif{1});
[outlines, outline_pts] = getOutlines(fnRefOl);

%% Get JPG images
x_Files_Jpg = dir([x_Directory, '\*.jpg']);
x_Filename_Jpg = {x_Files_Jpg.name}';
fnRef = fullfile (x_Directory, x_Filename_Jpg{1});
IRef = imread(fnRef);

for file_num = 2:size(x_Filename_Jpg,1)
    fnTest = fullfile (x_Directory, x_Filename_Jpg{file_num});
    ITest = imread(fnTest);
    ITestBlur = imgaussfilt(ITest, 0.8);
    
    %%% Perform edge detection
    IEg = edge(ITestBlur, 'canny');
    
    %%% Threshold the image
    [counts,x] = imhist(ITest,255);
    T2 = otsuthresh(counts);
    ITh = imbinarize(ITest,T2);
    
    %%% Get difference between images
    IRefBlur = imgaussfilt(IRef, 0.8);
    IDiff1 = ITestBlur - IRefBlur;
    [counts,x] = imhist(IDiff1,255);
    IDT = otsuthresh(counts);
    IDiffTh1 = imbinarize(IDiff1,IDT);
    IDiff2 = IRefBlur - ITestBlur;
    [counts,x] = imhist(IDiff2,255);
    IDT = otsuthresh(counts);
    IDiffTh2 = imbinarize(IDiff2,IDT);
    %figure, imshow([IRef,ITest]); title('Current and previous img');
    IDiffTh = or(IDiffTh1,IDiffTh2);
    %figure, imshow([ITh, IEg,IDiffTh]);
    %figure, imshow(IDiffTh);
    %figure, imshow([ITh]);
    %%% Go over all outlines: R=1 G=2 C=3 M=4 Y=5
    out_outlines = zeros(5, 500, 500, 'logical');
    for cell_num=1:5
        if (outline_pts(cell_num) > 10)
            MInit = squeeze(outlines(cell_num, :, :));
            MDil = imdilate(MInit, seD10);
            MFillLarge = imfill(MDil, 'holes');
            MFillOrigSize = imerode(MFillLarge, seD10);
            MFillDil = imdilate(MFillOrigSize, seD05);
            MDiffOrig = or(MFillDil, IDiffTh);
            MDiffOrigOne = getConnPxs(MDiffOrig);
            MDiffOrigOneOpen = imopen(MDiffOrigOne, seD05);
            MDiffOrigOneDil = imdilate(MDiffOrigOneOpen, seD05);
            IDiffCurrCell = and(MFillLarge, IDiffTh);
            Temp = or(IDiffCurrCell, MFillDil);
            MClose = imclose(Temp, seD10);
            IMaskMoved = imdilate(MClose, seD05);
            %figure, imshow(uint8(IMaskMoved).*ITest); title('Move search space');
            
            %%% Set search space
            SearchSpace = or(IDiffTh, MDil);
            SearchDilate = imdilate(SearchSpace, [se300 se390]);
            SearchDilate = imdilate(SearchDilate, seD05);
            SearchOpen = imopen(SearchDilate, seD15);
            SearchOne = getConnPxs(SearchOpen);
            SearchDilate2 = imdilate(SearchOne, [se300 se390]);
            SearchMask = imdilate(SearchDilate2, [se300 se390]);
            
            %%% Add all pixels that did not move more than 1 px
            %%% Get cell part from edge detection
            IEgOneCell = IEg.*SearchMask;
            IOneCellNormals = getNormals(IEgOneCell);
            MNormals = getNormals(MInit);
            [i_row, i_col] = find(IEgOneCell(:,:) == 1);
            [o_row, o_col] = find(MInit(:,:) == 1);
            num_pts = size(i_row, 1);
            IStatic = zeros(500, 500, 'logical');
            search_size = 3;
            for pt=1:num_pts
                normal = IOneCellNormals(i_row(pt),i_col(pt));
                for i=-search_size:search_size
                    for j=-search_size:search_size
                        x_search = i_row(pt)+i;
                        y_search = i_col(pt)+j;
                        if (MInit(x_search, y_search) == 1 && ...
                                MNormals(x_search, y_search) < normal + 0.3 &&...
                                MNormals(x_search, y_search) > normal - 0.3 && ...
                                MNormals(x_search, y_search) ~= -5)
                            IStatic(i_row(pt), i_col(pt)) = 1;
                        end
                    end
                end
            end
            IKept = bwareaopen(IStatic,20);
            %showOutline(ITest, IKept); title('Pixels that did not move');
            
            %%% Look for long chains of connected pixels in thresholded img
            IThEg = edge(ITh, 'canny');
            IMaskMovedHollow = xor(IMaskMoved, imerode(IMaskMoved, seD25));
            IEgMoved = IThEg .* IMaskMovedHollow;
            %figure, imshow([IThEg]); title('Search space Otsu');
            IThConn = zeros(500,500,'logical');
            IProccessed = zeros(500,500,'logical');
            for iterations=1:2
                CC = getConnPxs(IEgMoved);
                [rows, cols] = find(CC(:,:) == 1);
                sz = size(rows,1);
                CcInMask = and(CC, IMaskMovedHollow);
                [rows1, cols1] = find(CcInMask(:,:) == 1);
                IThConn = IThConn + CcInMask;
                IEgMoved = IEgMoved - CC;
                IProccessed = IProccessed + CC;
                %figure, imshow([CC, CcInMask, IConn]); title('Loop');
            end
            %showOutline(ITest, IThConn); title('Otsu thresholding');
            
            %%% Look for long chains of connected pixels
            IEgMoved = IMaskMoved .* IEg;
            MDil = imdilate(MInit, seD05);
            IEgConn = zeros(500,500,'logical');
            IProccessed = zeros(500,500,'logical');
            %figure, imshow(IEgMoved);, title('Search space edge detection');
            for iterations=1:5
                CC = getConnPxs(IEgMoved);
                [rows, cols] = find(CC(:,:) == 1);
                sz = size(rows,1);
                CcInMask = and(CC, IMaskMoved);
                [rows1, cols1] = find(CcInMask(:,:) == 1);
                IEgConn = IEgConn + CcInMask;
                IEgMoved = IEgMoved - CC;
                IProccessed = IProccessed + CC;
                %figure, imshow([CC, CcInMask, IConn]); title('Loop');
            end
            IFinal = IKept + IEgConn + IThConn;
           % showOutline(ITest, IEgConn); title('Edge detection');
            %showOutline(ITest, IFinal); title('Pre final');
            IConv = bwconvhull(IFinal);
            %showOutline(ITest, IConv); title('Conv');
            [y, x] = find(IConv(:,:) == 1);
            sz_x = max(x) - min(x);
            sz_y = max(y) - min(y);
            sz_disk = round(min(sz_x, sz_y)/3);
            sDFinal = strel('disk', sz_disk, 0);
            IFinalSmooth = imopen(IConv, sDFinal);
            %showOutline(ITest, IFinalSmooth); title('Final');
            out_outlines(cell_num,:,:) = IFinalSmooth;
        end
    end
    outlinedImage = addOutlinesRGB(ITest,out_outlines);
    fn_out = strcat(fnTest(1, 1:end-4), 'Out', '.tif');
    %figure, imshow(outlinedImage), title('Final outline');
    imwrite(outlinedImage, fn_out);
    outlines = out_outlines;
    IRef = ITest;
end