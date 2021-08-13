function scores = harris(img, patch_size, kappa)
   
    % Gradients according to the sobel filter
    [Ix,Iy] = imgradientxy(img);
    Ixx = Ix.^2;    Iyy = Iy.^2;    Ixy = Ix.*Iy;

    % Sum of gradients in a given patch
    sIxx = imfilter(Ixx, ones(patch_size));
    sIyy = imfilter(Iyy, ones(patch_size));
    sIxy = imfilter(Ixy, ones(patch_size));
    
    scores = sIxx.*sIyy - sIxy*2 - kappa * ((sIxx + sIyy).^2);

    scores(scores<0) = 0;
end
