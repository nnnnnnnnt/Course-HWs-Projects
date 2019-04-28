function [PC eigenvalues]=myPCA(data,num_principal_components)
    S=cov(data);
    [V D]=eig(S);
    [d ind]= sort(diag(D),'descend');
    eigenvectors = V(:,ind);
    PC = eigenvectors(:,1:num_principal_components);
    eigenvalues = d(1:num_principal_components);
end