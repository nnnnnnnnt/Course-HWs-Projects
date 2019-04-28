function [matrix eigenvalues] = myLDA(data,num_principal_components)
    d = size(data,2);
    class = unique(data(:,end));
    n_class = length(class);
    Sw = zeros(d-1,d-1);
    Sb = zeros(d-1,d-1);
    m = zeros(n_class,d-1);
    n = zeros(1,n_class);
    
    for i = 1:n_class
        Xi = data(data(:,end)==class(i),1:end-1);
        mi = mean(Xi);
        Si = (Xi' -mi')*(Xi' -mi')';
        Sw = Sw + Si;
        m(i,:) = mi;
        n(i) = size(Xi,1);
    end
    M = mean(m);
    for i = 1:n_class
        Sb = Sb + (n(i).*(m(i,:)'-M')*(m(i,:)'-M')');
    end
    
    S = pinv(Sw)*Sb;
    [V D]=eig(S);
    [d,ind] = sort(diag(D),'descend');
    DMatrix = D(ind,ind);
    VPC = V(:,ind);
    matrix = VPC(:,1:num_principal_components);
    eigenvalues = diag(DMatrix);
    eigenvalues = eigenvalues(1:num_principal_components);
end
