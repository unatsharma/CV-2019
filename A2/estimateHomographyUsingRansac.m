function H = estimateHomographyUsingRansac(pts1, pts2)
%ESTIMATEHOMOGRAPHYUSINGRANSAC Applies RANSAC to estimate best homography
%matrix between the two set of image points.
% Inputs:
%   pts1 = Points of image 1. Size (len X 2)
%   pts2 = Points of image 2. Size (len X 2)

    % RANSAC
    itrs = 100;
    n = 4;
    errThr = 0.05;
    h = ones(itrs, 3, 3);
    inliers = ones(itrs, 1);
    len = length(pts1);
    
    for itr = 1:itrs
        % Select points randomly
        idx = randperm(numel(1:size(pts1, 1)));
        pts = idx(1:n);
        
        % Calculate projection matrix
        h(itr, :, :) = calcHomographyMatrix(pts1(pts,:), pts2(pts,:));   
        
        % Calculate reprojection error
        gen_pts1 = reshape(h(itr,:,:), 3, 3) * [pts2, ones(len,1)]';
        gen_pts1 = gen_pts1./gen_pts1(3,:);
        err = pts1 - gen_pts1(1:2,:)';
        err = err.^2;
        err = sqrt(sum(err(:,1:2), 2));
        
        inliers(itr) = size(find(err < errThr),1);
    end
    
    % Find best intrinsic and extrinsic parameters
    [~, max_index] = max(inliers);
    
    H = reshape(h(max_index, :, :), 3, 3);

end

