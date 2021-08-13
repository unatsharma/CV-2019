clear all;
close all;
clc;

% Take input image
I = imread('Stereo_Pair3.jpg');
% Divide the image into two equal halves
L = I(1:size(I,1), 1:size(I,2)/2, 1:size(I,3)); 
R = I(1:size(I,1), 1+size(I,2)/2:size(I,2), 1:size(I,3));

scale = 0.5; % Downsamples the image to increase speed

scaled_L = imresize(L,scale);
scaled_R = imresize(R,scale);

run('/home/user/Downloads/softwares/vlfeat-0.9.21/toolbox/vl_setup');

%% SIFT implemented by me
[~, ~, matched_kpts] = sift(L, R, scale);
figure(1); ax = axes;
showMatchedFeatures(scaled_L, scaled_R,...
    matched_kpts{1}, matched_kpts{2}, 'montage','Parent',ax);
title(ax, 'Point matches using my SIFT (Image scaled down to one-fourth)');
legend(ax, 'Matched points 1','Matched points 2');

%% Using vl-feat SIFT
[f1, d1] = vl_dsift(single(rgb2gray(scaled_L)));
[f2, d2] = vl_dsift(single(rgb2gray(scaled_R)));
[matches, ~] = vl_ubcmatch(d1, d2);
pts1 = f1(1:2,matches(1,:));
pts2 = f2(1:2,matches(2,:));
figure(2); ax = axes;
showMatchedFeatures(scaled_L, scaled_R,...
    pts1', pts2', 'montage', 'Parent',ax);
title(ax, 'Point matches using vl-feat dense-SIFT (Scaled down to one-fourth)');
legend(ax, 'Matched points 1','Matched points 2');

%% Every pixel window matching
win_size = 3;
match_lambda = 0.85;

rows = size(scaled_L, 1); cols = size(scaled_R, 1);
buff = (win_size - 1) / 2;

matches = {};
for r = 1+win_size:rows-win_size
    
    R_vect = {};
    vect_idx = 0;
    for c = 1+win_size:cols-win_size
        vect_idx = vect_idx + 1;
        w = scaled_R(r-buff:r+buff, c-buff:c+buff);
        R_vect{vect_idx,1} = w(:)';
    end    
    R_vect = cell2mat(R_vect);
    
    for c = 1+win_size:cols-win_size
        w = scaled_L(r-buff:r+buff, c-buff:c+buff);
        L_vect = w(:)';
        
        correlation = sum(L_vect .* R_vect, 2) ./ ...
            (sqrt(sum(L_vect .^ 2, 2)) * sqrt(sum(R_vect .^ 2, 2)));
        [max_corr, corr_idx] = max(correlation);        
        if ~isempty(max_corr)
            if (max_corr > match_lambda)
                matches = vertcat(matches,...
                    [r, c, r, corr_idx+win_size]);
            end
        end
        
    end
    
end

matches = cell2mat(matches);
figure(3); ax = axes;
showMatchedFeatures(scaled_L, scaled_R,...
    fliplr(matches(:,1:2)), fliplr(matches(:,3:4)),...
     'montage', 'Parent',ax);
title(ax, 'Point matches using window matching (Scaled down to half)');
legend(ax, 'Matched points 1','Matched points 2');
%% Using window matching
win_size = 3;
match_lambda = 0.85;
win_matches = corrMatchImages(L, R, scale, win_size, match_lambda);

figure(4); ax = axes;
showMatchedFeatures(scaled_L, scaled_R,...
    fliplr(win_matches(:,1:2)), fliplr(win_matches(:,3:4)),...
     'montage', 'Parent',ax);
title(ax, 'Point matches using window matching (Scaled down to one-fourth)');
legend(ax, 'Matched points 1','Matched points 2');

%% Rectification of the images after matching using above methods

% Estimate Fundamental Matrices for three methods
F_my_sift = estimateFundamentalMatrix(matched_kpts{1}, matched_kpts{2});
F_vl_sift = estimateFundamentalMatrix(pts1', pts2');
F_win = estimateFundamentalMatrix(fliplr(win_matches(:,1:2)),...
    fliplr(win_matches(:,3:4)));
F_gw = estimateFundamentalMatrix(fliplr(matches(:,1:2)),...
    fliplr(matches(:,3:4)));

% Rectified images
[t1_my_sift, t2_my_sift] = estimateUncalibratedRectification(F_my_sift,...
    matched_kpts{1}, matched_kpts{2}, size(R));
[rectL_mysift, rectR_mysift] = rectifyStereoImages(...
    scaled_L, scaled_R, t1_my_sift, t2_my_sift);
[t1_vl_sift, t2_vl_sift] = estimateUncalibratedRectification(F_vl_sift,...
    pts1', pts2', size(R));
[rectL_vlsift, rectR_vlsift] = rectifyStereoImages(...
    scaled_L, scaled_R, t1_vl_sift, t2_vl_sift);
[t1_win, t2_win] = estimateUncalibratedRectification(F_win,...
    fliplr(win_matches(:,1:2)), fliplr(win_matches(:,3:4)), size(R));
[rectL_win, rectR_win] = rectifyStereoImages(...
    scaled_L, scaled_R, t1_win, t2_win);
[t1_gw, t2_gw] = estimateUncalibratedRectification(F_gw,...
    fliplr(matches(:,1:2)), fliplr(matches(:,3:4)), size(R));
[rectL_gw, rectR_gw] = rectifyStereoImages(...
    scaled_L, scaled_R, t1_gw, t2_gw);

% Show rectified images
figure(5); imshow([rectL_mysift, rectR_mysift]);
title('Rectified images using F matrix of MY SIFT');
figure(6); imshow([rectL_vlsift, rectR_vlsift]);
title('Rectified images using F matrix of VL-DSIFT');
figure(7); imshow([rectL_win, rectR_win]);
title('Rectified images using F matrix of WINDOW MATCHING(Using Harris)');
figure(8); imshow([rectL_gw, rectR_gw]);
title('Rectified images using F matrix of WINDOW MATCHING');

%% Greedy matching
rows = size(rectL_vlsift,1); cols = size(rectL_vlsift,2);

gmatches = {};
midx = 0;
for rl = 1:rows
    for cl = 1:cols
        has_match = false;
        rr = 0; cr = 0;
        while(~has_match && rr<=rows && cr<=cols)
            rr = 1+rr; cr = 1+cr;
            if rectL_vlsift(rl,cl) == rectR_vlsift(rr,cr)
                midx = midx + 1; 
                gmatches{midx,1} = [rl,cl,rr,cr];
                has_match = true;
            end
        end
    end
end
gmatches = cell2mat(gmatches);

figure(9); ax = axes;
showMatchedFeatures(rectL_vlsift, rectR_vlsift,...
    fliplr(gmatches(:,1:2)), fliplr(gmatches(:,3:4)),...
     'montage', 'Parent',ax);
title(ax, 'Point matches using greedy matching between rectified images');
legend(ax, 'Matched points 1','Matched points 2');

%% DTW error
[dtw_dist,~,~] = dtw(double(rgb2gray(rectL_vlsift)), ...
    double(rgb2gray(rectR_vlsift)));

%% Greedy error
greedy_dist = sum(sum(sum(abs(rectL_vlsift - rectR_vlsift))));
