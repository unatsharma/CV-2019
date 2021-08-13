function P = calcProjMatrix(x, X)
%CALCPROJMATRIX Calculates the projection matrix using 2D image points and
%3D world points.
% Input:
%   pts2D = Image points in homogeneous coordinates (len X 3)
%   pts3D = World points in homogeneous coordinates (len X 4)
% Output:
%   P = Projection Matrix
    
    len = length(x);
    
    A = [X(:,1), X(:,2), X(:,3), X(:,4),zeros(len,4), -x(:,1).*X(:,1), -x(:,1).*X(:,2), -x(:,1).*X(:,3), -x(:,1);...
         zeros(len,4), X(:,1), X(:,2), X(:,3), X(:,4), -x(:,2).*X(:,1), -x(:,2).*X(:,2), -x(:,2).*X(:,3), -x(:,2)];
    
    [~,~,V] = svd(A);    
    P = reshape(V(:,end),[4,3])';
 
end

