function angles = getNormals(outline)
img = bwmorph(outline,'skel',Inf);
[row,col] = find(img(:,:) == 1);
sz = size(row,1);
dist = 3;
angles=zeros(500,500,'double');
angles(:,:) = -5;
for pt_ix=1:sz
    % Find 2 points
    Ax = -1;
    Ay = -1;
    Cx = -1;
    Cy = -1;
    img_x = col(pt_ix,1);
    img_y = row(pt_ix,1);
    for ii = -dist:dist
        x_new = img_x + ii;
        y_new = img_y + dist;
        if(img(y_new, x_new) == 1)
            if (Ax == -1 && Ay == -1)
                Ax = x_new;
                Ay = y_new;
            else
                Cx = x_new;
                Cy = y_new;
            end
        end
    end
    for ii = -dist:dist
        x_new = img_x + ii;
        y_new = img_y - dist;
        if(img(y_new, x_new) == 1)
            if (Ax == -1 && Ay == -1)
                Ax = x_new;
                Ay = y_new;
            else
                Cx = x_new;
                Cy = y_new;
            end
        end
    end
    for jj = -dist:dist
        x_new = img_x - dist;
        y_new = img_y + jj;
        if(img(y_new, x_new) == 1)
            if (Ax == -1 && Ay == -1)
                Ax = x_new;
                Ay = y_new;
            else
                Cx = x_new;
                Cy = y_new;
            end
        end
    end
    for jj = -dist:dist
        x_new = img_x + dist;
        y_new = img_y + jj;
        if(img(y_new, x_new) == 1)
            if (Ax == -1 && Ay == -1)
                Ax = x_new;
                Ay = y_new;
            else
                Cx = x_new;
                Cy = y_new;
            end
        end
    end
    angle = atan((Cx-Ax)/(Cy/Ay));
    angles(img_y, img_x) = angle;
end
end