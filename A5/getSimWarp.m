function W = getSimWarp(delta_x, delta_y, theta_d, lambda)
% GETSIMWARP Generates warp matrix.
% Inputs:
%   delta_x     Translation along x direction.
%   delta_y     Translation along y direction.
%   theta_d     Angle in degrees.
%   lambda      Scalar multiplier.
% Output:
%   W   Warp matrix. Size(2x3).
    R = [cosd(theta_d), -sind(theta_d);...
        sind(theta_d), cosd(theta_d)];
    
    t = [delta_x; delta_y];
    
    W = lambda*([R t]);
end