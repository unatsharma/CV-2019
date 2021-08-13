function I = stichImages(I1, I2, H21)
%STICHIMAGES Summary of this function goes here
%   Detailed explanation goes here

    r = size(I1,1); c = size(I1,2);
    I = I2;
    I = padarray(I, [r c], 'both');

    for row = 1:size(I,1)
        for col = 1:size(I,2)
            x = H21 * [col-c; row-r; 1];
            x = floor(x/x(3));       
            if (1 <= x(2) && x(2) <= r && 1 <= x(1) && x(1) <= c)
                    I(row,col,:) = I1(x(2), x(1), :);
            end
        end
    end


    % Post process stitched image to remove dark regions.
    gI = rgb2gray(I);
    [r,c] = find(gI~=0);
    t = [r,c];
    minR = min(t(:,1));    maxR = max(t(:,1));
    minC = min(t(:,2));    maxC = max(t(:,2));
    
    I = I(minR:maxR,minC:maxC,:);
    
end

