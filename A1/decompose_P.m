function [K, R, t] = decompose_P(P)
%DECOMPOSE_P Decomposes Projection matrix into camera intrinsics and
%extrinsics.
% Input:
%   P = Projection Matrix
% Outputs:
%   K = Camera Matrix
%   R = Rotation Matrix
%   t = Translation Vector
    
    KR = [P(:,1), P(:,2), P(:,3)];
    inv_KR = inv(KR);
    
    [R, K] = qr(inv_KR);
    
    R = R';   
    t = K*P(:,4);
    
    % Normalize K matrix
    K = inv(K);
    K = K./K(3,3);
    
end

