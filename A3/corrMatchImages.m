function [matches] = corrMatchImages(L, R, scale, win_size, match_lambda)
%CORRMATCHIMAGES Finds matches using intensity based correlation
% Inputs:
%   L = Image 1
%   R = Image 2
%   scale = Scale to downsample images
%   win_size = Window size
%   match_lambda = Correlation Threshold
% Outputs:
%   matches = (rL,cL,rR,cR)

    % Both the images must be of same size.
    if isequal(size(L),size(R))
        
        harris_patch_size = 9;
        harris_kappa = 0.08;
        nonmaximum_supression_radius = 8;
        
        imgL = processImage(L,scale); imgR = processImage(R,scale);
        
        % Get keypoints using Harris detector.
        harris_scores_L = harris(imgL, harris_patch_size, harris_kappa);
        keypoints_L = selectKeypoints(...
            harris_scores_L, nonmaximum_supression_radius)';
        harris_scores_R = harris(imgR, harris_patch_size, harris_kappa);
        keypoints_R = selectKeypoints(...
            harris_scores_R, nonmaximum_supression_radius)';
        
        % Generate descriptors for each keypoint.
        descriptors_L = describeKeypoints(imgL, keypoints_L, win_size);
        descriptors_R = describeKeypoints(imgR, keypoints_R, win_size);

        % Match keypoints based on correlation between the descriptors.
        matches = corrMatchDescriptors(descriptors_L, descriptors_R,...
            keypoints_L, keypoints_R, match_lambda);
        
    else
        
        disp('Images must of same size');
        matches = [];
        
    end
    
end
