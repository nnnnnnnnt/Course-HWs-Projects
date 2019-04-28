function [pc1 pc2 mu_c1 mu_c2 S1 S2 err_rate]=MultiGaussian(training_data,testing_data,Model)
    training=load(training_data);
    testing=load(testing_data); % load training and test data
    
    pc1=sum((training(:,end)==1))/length(training);
    pc2=1-pc1; % get prior
    
    training_c1=training((training(:,end)==1),:);
    training_c2=training((training(:,end)==2),:);
    mu_c1=mean(training_c1(:,1:end-1));
    mu_c2=mean(training_c2(:,1:end-1)); % get mean
    
    disp('P(C1)=');disp(pc1);
    disp('P(C2)=');disp(pc2);
    disp('mu1=');disp(mu_c1);
    disp('mu2=');disp(mu_c2);
    
    if (Model==1)
        S1=cov(training_c1(:,1:end-1));
        S2=cov(training_c2(:,1:end-1)); % get cov matrix
        
        l_c1=mvnpdf(testing(:,1:end-1),mu_c1,S1);
        l_c2=mvnpdf(testing(:,1:end-1),mu_c2,S2); 
        
    elseif(Model==2)
        s1=cov(training_c1(:,1:end-1));
        s2=cov(training_c2(:,1:end-1)); % get cov matrix
        S=s1*pc1+s2*pc2;
        S1=S;S2=S;
        
        l_c1=mvnpdf(testing(:,1:end-1),mu_c1,S1);
        l_c2=mvnpdf(testing(:,1:end-1),mu_c2,S2); 
        
    elseif(Model==3)
        S1=0;S2=0;
        for i=1:length(training_c1)
            S1=S1+(training_c1(i,1:end-1)-mu_c1)*(training_c1(i,1:end-1)-mu_c1)';
        end
        for i=1:length(training_c2)
            S2=S2+(training_c2(i,1:end-1)-mu_c2)*(training_c2(i,1:end-1)-mu_c2)';
        end
        
        S1=S1/(size(training,2)-1)/length(training_c1);
        S2=S2/(size(training,2)-1)/length(training_c2);
        
        l_c1=mvnpdf(testing(:,1:end-1),mu_c1,S1*eye(size(training,2)-1));
        l_c2=mvnpdf(testing(:,1:end-1),mu_c2,S2*eye(size(training,2)-1));
    end
    
    discriminant_c1=l_c1*pc1;
    discriminant_c2=l_c2*pc2;
    
    err_counter = 0;
    for i = 1:length(testing)
        if testing(i,end)==1 && (discriminant_c1(i,1)<discriminant_c2(i,1))
            err_counter=err_counter+1;
        elseif testing(i,end)==2 && (discriminant_c1(i,1)>discriminant_c2(i,1))
            err_counter=err_counter+1;
        end
    end
    err_rate = err_counter/length(testing);
    
    if(Model==1 | Model==2)
        disp('S1:');disp(S1);
        disp('S2:');disp(S2);
    elseif(Model==3)
        disp('alpha1=');disp(S1);
        disp('alpha2=');disp(S2);
    end
    
    disp('error rate=');disp(err_rate);




    
    