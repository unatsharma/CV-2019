function [P, K, R, t] = calibrateCameraRansac(pts2D, pts3D)
%CALIBRATECAMERARANSAC 
% Input: 
%   pts2D = Image points in homogeneous coordinates (len X 3)
%   pts3D = World points in homogeneous coordinates (len X 4)
% Output:
%   P = Projection matrix
%   K = Camera calibration matrix
%   R = Rotation matrix
%   t = Translation

    % RANSAC
    itrs = 250;
    n = 6;
    errThr = 5;
    p = ones(itrs, 3, 4);
    inliers = ones(itrs, 1);

    for itr = 1:itrs
        % Select points randomly
        idx = randperm(numel(1:size(pts2D, 1)));
        pts = idx(1:n);
        
        % Calculate projection matrix
        p(itr, :, :) = calcProjMatrix(pts2D(pts,:), pts3D(pts,:));   
        
        % Calculate reprojection error
        genPts2D = (reshape(p(itr,:,:), [3, 4]) * pts3D')';
        err = pts2D - genPts2D;
        err = err.^2;
        err = sqrt(sum(err(:,1:2), 2));
        
        inliers(itr) = size(find(err < errThr),1);
    end
    
    % Find best intrinsic and extrinsic parameters
    [~, max_index] = max(inliers);
    
    P = reshape(p(max_index, :, :), [3, 4]);
    [K, R, t] = decompose_P(P);

end

