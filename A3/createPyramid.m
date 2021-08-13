function [pyramid] = createPyramid(num_octaves, I)
%CREATEPYRAMID Creates pyramid for the SIFT
% Inputs:
%   num_octaves = Number of octaves in the pyramid
%   I = Image for which octaves must be created
% Output:
%   pyramid = Pyramid of original image and sampled version of the image

    pyramid = cell(1, num_octaves);
    for oct_idx = 1:num_octaves
        % Downsample the images by 2^o where o = [0,..., num_octaves-1]
        J = imresize(I, 0.5^(oct_idx-1));
        pyramid(oct_idx) = {J};
    end

end

