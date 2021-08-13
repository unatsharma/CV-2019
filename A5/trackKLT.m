function [W, p_hist] = trackKLT(I_R, I, x_T, r_T, num_iters)
% TRACKKLT Obtains best warping matrix.
% Inputs:
%   I_R         Reference image.
%   I           Image to track point in.
%   x_T         Points to track expressed as [x y]=[col row].
%   r_T         Radius of patch to track.
%   num_iters   Amount of iterations to run.
% Outputs:
%   W       Final W estimate. Size(2x3)
%   p_hist  History of p estimates, including the initial estimate. 
%           Size(6x(num_iters+1)). 
 
    % Initial estimate of warp.
    W = getSimWarp(0, 0, 0, 1); 
    thrs = 0.01;
    
    p_hist = zeros(6, num_iters+1);
    p_hist(:, 1) = W(:);
    
    % Reference template
    I_RP = getWarpedPatch(I_R, W, x_T, r_T);
    i_r = I_RP(:);
    
    % Calculate dw_dx
    xs = -r_T:r_T;
    ys = -r_T:r_T;
    n = numel(xs);
    xy1 = [kron(xs, ones([1 n]))' kron(ones([1 n]), ys)' ones([n*n 1])];
    dw_dx = kron(xy1, eye(2));
    
    
    for iter = 1:num_iters
        % Getting more, for a valid convolution.
        IP = getWarpedPatch(I, W, x_T, r_T + 1);
        IWT = IP(2:end-1, 2:end-1);
        i = IWT(:);
 
        % getting di/dp
        IWTx = conv2(1, [1 0 -1], IP(2:end-1, :), 'valid');
        IWTy = conv2([1 0 -1], 1, IP(:, 2:end-1), 'valid');
        di_dw = [IWTx(:) IWTy(:)]; % as written in the statement
        di_dp = zeros(n*n, 6);
        for pixel_i = 1:n*n
            di_dp(pixel_i, :) = di_dw(pixel_i, :) * ...
                dw_dx(pixel_i*2-1:pixel_i*2, :);
        end
 
        % Hessian
        H = di_dp' * di_dp;
        
        if min(eig(H)) > thrs
            % Putting it together and incrementing
            delta_p = H^-1 * di_dp' * (i_r - i);
            W = W + reshape(delta_p, [2 3]);
        else
            delta_p = zeros(2,3);
        end
        
        p_hist(:, iter + 1) = W(:);
 
        if norm(delta_p) < 1e-3
           p_hist = p_hist(:, 1:iter+1);
           return
        end
    end
 
end

