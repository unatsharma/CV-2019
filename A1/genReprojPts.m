function genPts2D = genReprojPts(P, pts_3D)
%GENREPROJPTS Obtain image points using Projection matrix and world points
% Inputs:
%   P = Projection Matrix
%   pts_3D = World Points
% Output:
%   genPts2D = Reprojected image points
    
    genPts2D = (P * pts_3D')';
    genPts2D = genPts2D./genPts2D(:,3);
    
end

