close all;
clear all;
clc;
%% READ IMAGE
% directory = 'dataset/other-gray-twoframes/MiniCooper/';

directory = 'dataset/eval-data-gray/Wooden/';
r_T = 25;
num_iters = 20;

imgs = dir(fullfile(directory, '*.png'));
imgs_names = {imgs.name};

I_R = imresize(imsharpen(imsharpen(imread(string([directory, imgs_names{1}])))),0.5);

%% DETECT FEATURE POINTS
pts = detectKAZEFeatures(I_R);
pts = pts.selectStrongest(800);
keypoints = floor(pts.Location()'); % (x,y)

figure(1);
imshow(I_R);
hold on;
plot(keypoints(1, :), keypoints(2, :), 'r.');
hold off;
title('Features on the reference image');

% OPTICAL FLOW REPRESENTATION
I_prev = I_R;
pause(0.05);

for img_idx = 1:size(imgs_names,2)
    I_curr = imresize(imsharpen(imsharpen(imread(string([directory, imgs_names{img_idx}])))),0.5);
    dkp = zeros(size(keypoints));
    parfor j = 1:size(keypoints, 2)
        W = trackKLT(I_prev, I_curr, keypoints(:,j)', r_T, num_iters);
        dkp(:, j) = W(:, end);
    end
    kpold = keypoints;
    keypoints = keypoints + dkp;
    
    imshow(I_curr);
    hold on;
    plotMatches(1:size(keypoints, 2), flipud(keypoints), flipud(kpold));
    hold off;
    title('Optical Flow');
    legend('Change in feature position');
    I_prev = I_curr;
end
