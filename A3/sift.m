function [descriptors, kpt_loc, kpt_matched] = sift(img_1, img_2, scale)
%SIFT Finds SIFT detectors and descriptors between two image files
%   Detailed explanation goes here
% Inputs:
%   file_1 = Image 1 file name
%   file_2 = Image 2 file name
%   scale = Downsamples the image
% Outputs:
%   descriptors = 128 dimension vector for each keypoint
%   kpt_locations = Keypoint locations

    num_scales = 3; % Scales per octave.
    num_octaves = 5; % Number of octaves.
    sigma = 1.6; % Gaussian smoothening factor.
    contrast_threshold = 0.02; % Threshold to invalidate noisy keypoints.
   
    images = {processImage(img_1, scale), processImage(img_2, scale)};

    kpt_loc = cell(1, 2); % Locations of the keypoints.
    descriptors = cell(1, 2); % 128 dimension descriptors of the keypoints.
    kpt_matched = cell(1,2); % Matching keypoints.
    
    % Create Pyramid of octaves containing blurred images and DoGs. Finding
    % keypoints and descriptors.
    for img_idx = 1:2
        pyramid = createPyramid(num_octaves, cell2mat(images(img_idx)));
        blur = createBlurOctaves(pyramid, num_scales, sigma);
        dog = createDogOctaves(blur);
        keypts = createKeypoints(dog, contrast_threshold);
        [descriptors(img_idx), kpt_loc(img_idx)] = ...
            genDescriptors(keypts, blur);
    end
    
    % Show matched keypoints
    
    indexPairs = matchFeatures(descriptors{1}, descriptors{2},...
        'MatchThreshold', 100, 'MaxRatio', 0.45, 'Unique', true);
    
    % Flip row and column to change to image coordinate system.
    kpt_match_1 = fliplr(kpt_loc{1}(indexPairs(:,1), :));
    kpt_match_2 = fliplr(kpt_loc{2}(indexPairs(:,2), :));

    kpt_matched{1} = kpt_match_1;
    kpt_matched{2} = kpt_match_2;
    
    
    
end

