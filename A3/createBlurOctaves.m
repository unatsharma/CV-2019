function [blur] = createBlurOctaves(pyramid, num_scales, sigma)
%CREATEBLUROCTAVES Creates blurred images within each octave
% Inputs:
%   pyramid = Pyramid of original image and down-sampled images
%   num_scales = Number of scales
%   sigma = Gaussian smoothening parameter
% Output:
%   blur = Blurred images in the SIFT pyramid in each octave

    num_octaves = numel(pyramid);
    blur = cell(1, num_octaves);
    for oct_idx = 1:num_octaves
        I = cell2mat(pyramid(oct_idx));
        [r,c] = size(I);
        blurs_octave = zeros(r, c, num_scales+3);
        
        for blur_idx = 1:num_scales+3
            s = blur_idx - 2;
            blurs_octave(:,:,blur_idx) = imgaussfilt(I, (2 ^ (s/num_scales)) * sigma);
        end
        
        blur{1, oct_idx} = blurs_octave;
    end

end

