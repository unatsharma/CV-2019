function h = weightedhistc(vals, weights, edges)
% WEIGHTEDHISTC Creates histogram

    if ~isvector(vals) || ~isvector(weights) || length(vals)~=length(weights)
        error('vals and weights must be vectors of the same size');
    end
    
    Nedge = length(edges);
    h = zeros(size(edges));
    
    for n = 1:Nedge-1
        ind = find(vals >= edges(n) & vals < edges(n+1));
        if ~isempty(ind)
            h(n) = sum(weights(ind));
        end
    end

    ind = find(vals == edges(end));
    if ~isempty(ind)
        h(Nedge) = sum(weights(ind));
    end
    
end