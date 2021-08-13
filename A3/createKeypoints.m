function [keypts] = createKeypoints(dog, contrast_threshold)
%CREATEKEYPOINTS Summary of this function goes here
%   Detailed explanation goes here
% Inputs:
%   dog = Octaves containing DoGs {1,octaves -> (r,c,scale)}
%   contrast_threshold = Keypoints below this threshold are rejected
% Output:
%   keypts = Keypoints detected (r,c,scale,oct_idx)

    keypts = {};
    for oct_idx = 1:length(dog)
        oct_dog = dog{oct_idx};
        
        max_mat = imdilate(oct_dog,ones(3,3,3));
        max_mat(max_mat ~= oct_dog) = 0;
        max_mat(max_mat == oct_dog & max_mat >= contrast_threshold) = 1;
        max_mat(:,:,1) = 0;
        max_mat(:,:,end) = 0;
        
        [r,c,scale] = ind2sub(size(max_mat),find(max_mat==1));
        keypts = vertcat(keypts,[r,c,scale,oct_idx*ones(length(r),1)]);
    end
    
    keypts = cell2mat(keypts);

end

