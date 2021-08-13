function keypoints = selectKeypoints(scores, r)
% Selects the num best scores as keypoints and performs non-maximum 
% supression of a (2r + 1)*(2r + 1) box around the current maximum.

    [i,j] = find(scores > 0);
    indices = [i,j];
    
    scorePadded = zeros(size(scores,1) + 2*r, size(scores,2) + 2*r);
    scorePadded(r+1:size(scores,1) + r, r+1:size(scores,2) + r) = scores;
    
    % Suppress neighbouring maximum values
    for i = 1:length(indices)
        idx = indices(i,:); u = idx(1) + r; v = idx(2) + r;
        s = scores(idx(1),idx(2));

        w = scorePadded(u-r:u+r, v-r:v+r);
        m = max(max(w));
        f = zeros(size(w)); f(r+1,r+1) = 1;

        if s == m 
            scorePadded(u-r:u+r, v-r:v+r) = w.*f;
        elseif s <= m
            scorePadded(u,v) = 0;
        end
    end
    
    maxScores = scorePadded(r+1:size(scores,1) + r, r+1:size(scores,2) + r);
    [i,j] = find(maxScores > 0);
    A = [i,j,maxScores(maxScores > 0)];
    A = sortrows(A, 3);
    A = fliplr(A')';
    
    if length(A) > 200
        A = A(1:200,:);
    end
    
    keypoints = A(:,1:2)';
end
    
    
            
        
