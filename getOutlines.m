function [outlines, num_pts] = getOutlines(fn)
I_0 = imread(fn); % Read image
I_h = 500;
I_w = 500;
ch_R = I_0(:,:,1); % Red channel
ch_G = I_0(:,:,2); % Green channel
ch_B = I_0(:,:,3); % Blue channel
num_pts = [0, 0, 0, 0, 0];
outlines = zeros(5, I_h, I_w, 'logical');
for x = 1:I_h
    for y = 1:I_w
        if (ch_R(x,y) > 100) && (ch_G(x,y) < 100) && (ch_B (x,y) < 100)
            outlines(1, x, y) = 1;
            num_pts(1) = num_pts(1) + 1;
        elseif (ch_R(x,y) < 150) && (ch_G(x,y) > 150) && (ch_B (x,y) < 150)
            outlines(2, x, y) = 1;
            num_pts(2) = num_pts(2) + 1;
        elseif (ch_R(x,y) < 100) && (ch_G(x,y) > 100) && (ch_B (x,y) > 100)
            outlines(3, x, y) = 1;
            num_pts(3) = num_pts(3) + 1;
        elseif (ch_R(x,y) > 150) && (ch_G(x,y) < 150) && (ch_B (x,y) > 150)
            outlines(4, x, y) = 1;
            num_pts(4) = num_pts(4) + 1;
        elseif (ch_R(x,y) > 120) && (ch_G(x,y) > 120) && (ch_B (x,y) < 120)
            outlines(5, x, y) = 1;
            num_pts(5) = num_pts(5) + 1;
        end
    end
end

end