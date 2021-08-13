function [dog] = createDogOctaves(blur)
%CREATEDOGOCTAVES Summary of this function goes here
%   Detailed explanation goes here
% Inputs:
%   blur = Octaves containing blur images at different scales (r,c,scale)
    num_octaves = numel(blur);
    dog = cell(1, num_octaves);
    for oct_idx = 1:num_octaves
        blurs_octave = cell2mat(blur(1, oct_idx));
        
        [r,c,s] = size(blurs_octave);
        dog_octave = zeros(r, c, s-1);
        
        for blur_idx = 2:s
            dog_octave(:, :, blur_idx-1) = ...
                abs(blurs_octave(:, :, blur_idx - 1)...
                - blurs_octave(:, :, blur_idx));
        end
        
        dog{1, oct_idx} = dog_octave;
    end

end

