function U = calcU(I, alphas, bg_gmm, fg_gmm, KC)
%CALCU Calculates data term.
% Inputs:
%   I = Image. Size = (r,c,3)
%   alphas = Opacity values. Size = (1,num_pix)
%   bg_gmm = GMM for background pixels
%	fg_gmm = GMM for foreground pixels
%	KC = Surity Cost
% Output:
% 	U = Data term (or t-link cost)
    
        [r,c,~] = size(I);
        num_pix = r*c;
        I = double(I);
        alphas = reshape(alphas,[c,r])';
        
        U = zeros(2,num_pix);
        
        I_fg = I .* alphas;
        D_fg = zeros(num_pix,1);        
        for k = 1:bg_gmm.NumComponents
            pi = fg_gmm.ComponentProportion(k);
            sigma = fg_gmm.Sigma(:,:,k);
            mu = fg_gmm.mu(k,:);
            
            c_1 = pi / det(sigma);
            c_2 = I_fg - cat(3,mu(1),mu(2),mu(3));
            red = c_2(:,:,1)'; green = c_2(:,:,2)'; blue = c_2(:,:,3)';
            c_2 = cat(3,red,green,blue);
            c_2 = reshape(c_2,[num_pix,3]);
            
            D_fg = D_fg + (c_1 * exp(-0.5 * sum((c_2/sigma) .* c_2, 2)));
        end
        D_fg = -log(D_fg);
        D_fg = reshape(D_fg',[c,r])';
        D_fg(alphas ~= 1) = 0;
       
        D_bg = zeros(num_pix,1);       
        for k = 1:bg_gmm.NumComponents
            pi = bg_gmm.ComponentProportion(k);
            sigma = bg_gmm.Sigma(:,:,k);
            mu = bg_gmm.mu(k,:);
            
            c_1 = pi / sqrt(det(sigma));
            c_2 = I_fg - cat(3,mu(1),mu(2),mu(3));
            red = c_2(:,:,1)'; green = c_2(:,:,2)'; blue = c_2(:,:,3)';
            c_2 = cat(3,red,green,blue);
            c_2 = reshape(c_2,[num_pix,3]);
            
            D_bg = D_bg + c_1 * exp(-0.5 * sum((c_2/sigma) .* c_2, 2));            
        end
        D_bg = -log(D_bg);
        D_bg = reshape(D_bg',[c,r])';
        D_bg(alphas ~= 1) = 0;
        
        K_bg = zeros(r,c);
        K_bg(alphas == 0) = KC;
        
        U_bg = D_fg + K_bg;
        U_fg = D_bg;
        
        U(1,:) = reshape(U_bg',[1,num_pix]);
        U(2,:) = reshape(U_fg',[1,num_pix]);
        
%         idx = 1;
%         for r_idx = 1:r
%             for c_idx = 1:c
%                 if alphas(r_idx,c_idx) == 0 % Belongs to bg
%                     U(1,idx) = KC;
%                     U(2,idx) = 0;
%                 elseif alphas(r_idx,c_idx) == 1 % Belongs to unknown region
%                     U(1,idx) = calcD(bg_gmm,...
%                                      reshape(I(r_idx,c_idx,:),[1,3]));
%                     U(2,idx) = calcD(fg_gmm,...
%                                      reshape(I(r_idx,c_idx,:),[1,3]));
%                 end
%                 idx = idx + 1;
%             end
%         end

end

% rgb = (1,3)
function D = calcD(gmm,rgb)
    K = gmm.NumComponents;
    D = 0;    
    
    for k = 1:K
        pi = gmm.ComponentProportion(k);
        sigma = gmm.Sigma(:,:,k);
        mu = gmm.mu(k,:);
        
        D = D + (pi / det(sigma)) * ...
            exp(0.5 * ((rgb - mu)/inv(sigma)) * (rgb - mu)');
    end
end

