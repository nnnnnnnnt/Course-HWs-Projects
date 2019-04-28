function [p1,p2,pc1,pc2] = Bayes_Learning(training_data,validation_data)
    d = size(training_data,2)-1;
    p1= zeros(d,1);
    p2= zeros(d,1);

    for j = 1:d
        p1(j)=sum(training_data(:,j)==0 & training_data(:,end)==1)/sum(training_data(:,end)==1);
        p2(j)=sum(training_data(:,j)==0 & training_data(:,end)==2)/sum(training_data(:,end)==2);
    end
    
    N=size(validation_data,1);
    err=zeros(11,1);
    sigma = [0.00001 0.0001 0.001 0.01 0.1 1 2 3 4 5 6];
    
    for i = 1:11
        prior_C1 = 1 - exp(-1*sigma(i));
        prior_C2 = 1 - prior_C1;
        posterior = ones(N,3);
        
        for n = 1:N
            for j = 1:d
                posterior(n,1)=posterior(n,1) * p1(j).^(1-validation_data(n,j)) * (1-p1(j)).^(validation_data(n,j));
                posterior(n,2)=posterior(n,2) * p2(j).^(1-validation_data(n,j)) * (1-p2(j)).^(validation_data(n,j));
             %   if posterior(n,1)<power(10,-10);
             %       posterior(n,1)=power(10,-10);
             %   end
             %   if posterior(n,2)<power(10,-10);
             %       posterior(n,2)=power(10,-10);
             %   end
            end
            posterior(n,1)=posterior(n,1) * prior_C1;
            posterior(n,2)=posterior(n,2) * prior_C2;
            if posterior(n,1)>posterior(n,2)
               posterior(n,3)=1;
            else
               posterior(n,3)=2;
            end
        end
        err(i)=sum(posterior(:,3)~=validation_data(:,end))/N;
    end
    
    [min_err min_arg]=min(err);
    pc1 = 1 - exp(-sum(sigma(min_arg)));
    pc2 = 1 - pc1;
    t = sprintf('%0.5e',err);
    
    
    
