function [matches] = corrMatchDescriptors(...
    descriptors_L, descriptors_R, kpt_L, kpt_R, match_lambda)
%CORRMATCHDESCRIPTORS Summary of this function goes here
%   Detailed explanation goes here
% Inputs:
%   descriptors_L = Descriptors in left image(num_kpts,dimensions)
%   descriptors_R = Descriptors in right image(num_kpts,dimensions)
%   kpt_L = Keypoints in left image
%   kpt_R = Keypoints in right image
%   match_lambda = Correlation threshold for matching
% Output:
%   matches = (rL,cL,rR,cR)

    matches = {};
    
    for desc_idx = 1:size(descriptors_L,1)
        L_vect = descriptors_L(desc_idx,:);
        
        r = kpt_L(desc_idx,1);
        rows = kpt_R(:,1);
        [idx_1,~]= find(rows <= r + 5);
        [idx_2,~]= find(rows >= r - 5);
        idx = intersect(idx_1,idx_2);
        
        R_vect = descriptors_R(idx,:);
        
        correlation = sum(L_vect .* R_vect, 2) ./ ...
            (sqrt(sum(L_vect .^ 2, 2)) * sqrt(sum(R_vect .^ 2, 2)));
        
        [max_corr, corr_idx] = max(correlation);        
        if ~isempty(max_corr)
            if ((max_corr > match_lambda) && (pdist2(kpt_L(desc_idx,:),...
                    kpt_R(idx(corr_idx),:)) < 50))
                matches = vertcat(matches,...
                    [kpt_L(desc_idx,:), kpt_R(idx(corr_idx),:)]);
            end
        end
        
    end
    
    matches = cell2mat(matches);

end

