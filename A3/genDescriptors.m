function [descriptors, loc] = genDescriptors(keypts, blur)
%GENDESCRIPTORS Summary of this function goes here
%   Detailed explanation goes here
% Inputs:
%   keypts = Keypoints in the format (row, col, scale, octave)
%   blur   = Blur images in octaves (1, octaves -> (row, col, scale))

    num_keypts = size(keypts,1);
    keypt_descriptors = zeros(num_keypts, 128);
    keypt_loc = zeros(num_keypts, 2);
    
    for kp_idx = 1:num_keypts
        blur_octave = cell2mat(blur(1, keypts(kp_idx,4)));
        % Blurred image to be used to compute gradients
        blur_img = blur_octave(:, :, keypts(kp_idx,3));
        
        
        [norm, orientation] = imgradient(blur_img);
        norm_pad = padarray(norm, [7,7], 'pre');
        norm_pad = padarray(norm_pad, [8,8], 'post');
        orientation_pad = padarray(orientation, [7,7], 'pre');
        orientation_pad = padarray(orientation_pad, [8,8], 'post');

        row = keypts(kp_idx,1) + 7; col = keypts(kp_idx,2) + 7;
        norm_w = norm_pad(row - 7 : row + 8, col - 7 : col + 8);
        orientation_w = orientation_pad(row-7:row+8, col-7:col+8);

        sigma_w = 1.5 * 16;
        norm_w = imgaussfilt(norm_w, sigma_w);

        % Calculate 8 bin orientation histogram
        k = 1;
        for y = 1:4:16
            for x = 1:4:16
                wh = weightedhistc(reshape(norm_w(y:y+3,x:x+3),...
                    [1, 16]), reshape(orientation_w(y:y+3,x:x+3),...
                    [1, 16]), -180:45:180);
                keypt_descriptors(kp_idx, k:k+7) = wh(1,1:8);
                k = k+8;
            end
        end
        
        keypt_loc(kp_idx,:) = [row,col] .* 2^(keypts(kp_idx,4)-1);
    end    
    descriptors = {normalize(keypt_descriptors, 2, 'norm', 2)};
    loc = {keypt_loc};
end

