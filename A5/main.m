close all;
clear all;
clc;


directory = 'dataset/eval-data-gray/Dumptruck/';
img_file = dir(fullfile(directory, '*.png'));
imgs_names = {img_file.name};


win_size = 15;
threshold = 0.01;

I_prev = imread(string([directory, imgs_names{1}]));
for img_idx = 2:size(imgs_names,2)
    I_curr = imread(string([directory, imgs_names{img_idx}]));
    
    [uv, mag, dir] = myOpticalFlowLK(I_prev, I_curr, win_size, threshold);
    
    [r,c,~]= size(I_curr);
%     mag(mag > 0.2) = 1;
%     mag(mag < 0.2) = 0;
    vx = uv(:,:,1);
    vy = uv(:,:,2);
%     mag(vx < 0.01) = 0;
%     mag(vy < 0.01) = 0;
    coorx = (kron(ones(r, 1), 1:c) + vx) .* mag;
    coory = (kron(ones(c, 1), 1:r) + vy) .* mag;
    coorx(coorx > c) = c; coorx(coorx < 1) = 1;
    coory(coory > r) = r; coory(coory < 1) = 1;
    
    figure(1);
    subplot(1,3,1);
    imshow(I_curr);
    hold on
    plot(floor(coorx), floor(coory),'r.');
    hold off
    
    mag(mag >0) = 1;
    mask = zeros(r,c) + mag;
    mask2 = imclose(mask, strel('square',60));    
    subplot(1,3,2); imshow(mask);
    seg = uint8(double(mask2) .* double(I_curr));
    subplot(1,3,3); imshow(seg);
end