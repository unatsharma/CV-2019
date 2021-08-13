clear all;
close all;
clc;

% Include vlfeat
run('C:/Users/TANU/Documents/Softwares added/vlfeat-0.9.21-bin/vlfeat-0.9.21/toolbox/vl_setup');

% Name of the directory containing input images. Image types considered are
% either "*.png" or "*.jpg".
dirName = 'set_3/';
inpI = dir([dirName, '*.png']);

if isempty(inpI)
    inpI = dir([dirName, '*.jpg']);
end

I_2 = imread(inpI(1).name);

for i = 1:length(inpI)-1
    I_1 = imread(inpI(i+1).name);
    
    % Find matching points
    I1 = single(rgb2gray(I_1));
    I2 = single(rgb2gray(I_2));
    [f1, d1] = vl_sift(single(I1));
    [f2, d2] = vl_sift(single(I2));
    [matches, scores] = vl_ubcmatch(d1, d2);
    pts1 = f1(1:2,matches(1,:));
    pts2 = f2(1:2,matches(2,:));
    
    % Find Homography matrix
    H21 = estimateHomographyUsingRansac(pts1', pts2');
    
    % Stitch the two images
    Istitch = stichImages(I_1, I_2, H21);    
    I_2 = Istitch;
end

% Show the stitched image
imshow(I_2); title('Stitched Image');
