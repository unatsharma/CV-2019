function V = calcV(alphas, I, neighborhood, gamma, beta)
%CALCV Calculates Smoothness Term
% Input:
%   alphas = Alpha values related to each pixel. Size = (1,)
    
    [r,c,~] = size(I);
    num_pix = r * c;
    pad_I = double(padarray(I,[1,1],'both'));
    [pad_r,pad_c,~] = size(pad_I);
    
    alphas = reshape(alphas,[c,r])'; % Size = (r,c)
    pad_alphas = padarray(alphas, [1,1], 'both');
    pad_alphas([1,pad_r], 2:pad_c-1) = alphas([1,r],:);
    pad_alphas(2:pad_r-1, [1,pad_c]) = alphas(:,[1,c]);
	pad_alphas([1,1,pad_r,pad_r],[1,pad_c,pad_c,1]) = alphas([1,1,r,r],[1,c,c,1]);
    
	ijv = zeros(3,num_pix);
    
	idx = 1;
	
    for r_idx = 2:pad_r-1
        for c_idx = 2:pad_c-1
            if neighborhood == 4
                m = [0,1,0;1,1,1;0,1,0];
                w = m .* pad_I(r_idx-1:r_idx+1, c_idx-1:c_idx+1,:); % (3,3,3)
                a = m .* pad_alphas(r_idx-1:r_idx+1, c_idx-1:c_idx+1); % (3,3)
                dist = m;
            else
                w = pad_I(r_idx-1:r_idx+1, c_idx-1:c_idx+1,:);
                a = pad_alphas(r_idx-1:r_idx+1, c_idx-1:c_idx+1);
                dist = [sqrt(2),1,sqrt(2);1,0,1;sqrt(2),1,sqrt(2)];
            end
            
            w(2,2,:) = 0; a(2,2) = 0; dist(2,2) = 0;
            
            pix = pad_I(r_idx,c_idx,:).*ones(3); % Pixel color scale
            
            % calculate ||(z_m-z_n)||^2=(R_m-R_n)^2+(G_m-G_n)^2+(B_m-B_n)^2
            cs_dist = sum((w - pix).^2,3);
            
            % Indicator function
            alph = pad_alphas(r_idx,c_idx);
            phi = (a ~= alph);
            
            % Smoothness Term in the neighborhood
            v = (gamma * (phi .* exp(-beta * cs_dist))) ./ dist;
            v(isnan(v)) = 0;
            v = reshape(v',[9,1])';
            
            row = r_idx - 1; col = c_idx-1;
            
            up_pos = ((row - 2) * c) + col;
            cp_pos = ((row - 1) * c) + col;
            lp_pos = (row * c) + col;
            nb_pos = [up_pos - 1, up_pos, up_pos + 1;...
                         cp_pos - 1, cp_pos, cp_pos + 1;...
                         lp_pos - 1, lp_pos, lp_pos + 1];
            nb_pos = reshape(nb_pos',[9,1])';
            nb_pos(nb_pos < 1) = cp_pos;
            v(nb_pos < 1) = 0;
            nb_pos(nb_pos > num_pix) = cp_pos;
            v(nb_pos > num_pix) = 0;            
            
            ijv(1,idx:idx+8) = cp_pos + 1;
            ijv(2,idx:idx+8) = nb_pos + 1;
            ijv(3,idx:idx+8) = v;
            
			idx = idx + 9;
        end
    end

	V = sparse(ijv(1,:), ijv(2,:), ijv(3,:), num_pix+2, num_pix+2);
	
end
