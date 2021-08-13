function [T, norm_pts] = normalizePts(pts2D)
%NORMALIZEPTS Returns the 2D points in homogeneous form and
% transformation used to normalize them
%   Inputs:
%   pts2D: 2D points
%   Outputs:
%   norm_pts: Normalized points in homogeneous coordinates
%   T: Transformation applied to the points.

x = pts2D(:,1);
y = pts2D(:,2);

mu = mean(pts2D);
d = sum(sqrt(x.^2 + y.^2)/length(x));
scale = sqrt(2)/d;

T = [scale,0,-scale*mu(1);0,scale,-scale*mu(2);0,0,1];
norm_pts = (T * [pts2D ones(length(x),1)]')';

