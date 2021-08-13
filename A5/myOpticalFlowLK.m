function [uv, mag, dir] = myOpticalFlowLK(I1, I2, win_size, thrs)
%MYOPTICALFLOWLK Summary of this function goes here
%   Detailed explanation goes here
    
    [r,c,ch] = size(I1);
    if ch == 3
        I1_g = double(rgb2gray(I1))/255;
        I2_g = double(rgb2gray(I2))/255;
    else
        I1_g = double(I1)/255;
        I2_g = double(I2)/255;
    end
    
    del = (win_size - 1)/2;
    
    uv = zeros(r,c,2);
    mag = zeros(r,c);
    dir = zeros(r,c);
    
    Ix = conv2(1, [1 0 -1], I1_g(2:end-1, :), 'valid');
    Iy = conv2([1 0 -1], 1, I1_g(:, 2:end-1), 'valid');
    It = I2_g - I1_g;
       
    for r_idx = 1+del:r-del
        for c_idx = 1+del:c-del
            Ix_win = Ix(r_idx - del: r_idx + del);
            Iy_win = Iy(r_idx - del: r_idx + del);
            It_win = It(r_idx - del: r_idx + del);
            
            A = [Ix_win(:), Iy_win(:)];
            b = -It_win(:);            
            AA = A'*A;
            
            if thrs > min(eig(AA))
                uv(r_idx, c_idx,:) = 0;
                mag(r_idx, c_idx) = 0;
                dir(r_idx, c_idx) = 0;
            else
                u = pinv(A) * b;
                uv(r_idx, c_idx, 1) = u(1);
                uv(r_idx, c_idx, 2) = u(2);
                mag(r_idx, c_idx) = sqrt(sum(u.^2));
                dir(r_idx, c_idx) = atand(u(2)/u(1));
            end
        end
    end
    

end

