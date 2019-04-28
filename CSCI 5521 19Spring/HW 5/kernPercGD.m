function [a b] = kernPercGD(train_data, train_label)
    n = size(train_data,1);
    a = zeros(n,1);
    b = 0;
    kernel = zeros(n,n);
    p = 2;
    
    for i = 1:n
        for j = 1:n
            kernel(i,j) = (train_data(i,:)*train_data(j,:)'+1)^p;
        end 
    end
    
    output = zeros(n,1);err=0;pre_err=0;
    err_diff = 100000;
    while err_diff > 0.001
        for t = 1:n
            s = 0;
            for i = 1:n
                s = s + (a(i,1) * train_label(i) * kernel(t,i));
            end
            s = s + b;
            if s * train_label(t) <= 0
               a(t) = a(t) + 1;
               b = b + train_label(t);
            end
            s = 0;
            for i = 1:n
                s = s + (a(i,1) * train_label(i) * kernel(t,i));
            end
            output(t,1) = s * train_label(t);
        end
        err=sum(sign(output)~=train_label);
        err_diff=abs(err-pre_err);
        pre_err=err;
    end
end
            