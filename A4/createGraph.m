function G = createGraph(nodes, t_wt, n_wt)
%CREATEGRAPH Creates a graph
% Inputs:
%   nodes = Number of nodes in the image
%   t_wt = Weights of terminal edges
%   n_wt = Weights of neighboring edges
% Outputs:
%   G = G<nodes,{t_wt,n_wt}>

    bg = 1; fg = nodes + 2; pix_nodes = 2:nodes + 1;
        
    % Create graph according to U and V
    G = graph(n_wt,'upper','omitselfloops');
    G = addedge(G, bg*ones(1,nodes), pix_nodes, t_wt(1,:));
    G = addedge(G, fg*ones(1,nodes), pix_nodes, t_wt(2,:));

end

