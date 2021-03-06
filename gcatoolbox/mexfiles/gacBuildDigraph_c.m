function [graphW, NNIndex] = gacBuildDigraph_c(distance_matrix, K, a)
%% Build directed graph
% Input:
%   - distance_matrix: pairwise distances, d_{i -> j}
%   - K: the number of nearest neighbors for KNN graph
%   - a: for covariance estimation
%       sigma^2 = (\sum_{i=1}^n \sum_{j \in N_i^3} d_{ij}^2) * a
% Output:
%   - graphW: asymmetric weighted adjacency matrix, 
%               w_{ij} = exp(- d_{ij}^2 / sig2), if j \in N_i^K
%	- NNIndex: (2K) nearest neighbors, N x (2K+1) matrix
% by Wei Zhang (wzhang009 at gmail.com), June, 8, 2011
%
% Please cite the following paper, if you find the code is helpful
%
% W. Zhang, X. Wang, D. Zhao, and X. Tang. 
% Graph Degree Linkage: Agglomerative Clustering on a Directed Graph.
% in Proceedings of European Conference on Computer Vision (ECCV), 2012.


%% NN indices
N = size(distance_matrix,1);
% find 2*K NNs in the sense of given distances
[sortedDist,NNIndex] = gacMink(distance_matrix,max(K+1,4),2);

%% estimate derivation
sig2 = mean(mean(sortedDist(:,2:max(K+1,4)))) * a;
%%%%%%%%%
tmpNNDist = min(sortedDist(:,2:end),[],2);
while any(exp(- tmpNNDist / sig2) < 1e-5) % check sig2 and magnify it if it is too small
    sig2 = 2*sig2;
end
%%%%%%%%%
% disp(['  sigma = ' num2str(sqrt(sig2))]);

%% build graph
ND = sortedDist(:, 2:K+1);
NI = NNIndex(:, 2:K+1);
XI = repmat([1:N]', 1, K);
graphW = full(sparse(XI(:),NI(:),exp(-ND(:)*(1/sig2)), N, N));
graphW(1:N+1:end) = 1;

end