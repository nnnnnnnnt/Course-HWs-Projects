function [z w v] = mlptrain(train_data,val_data,m,k)
    train = load(train_data);
    validation = load(val_data);
    train_X = train(:,1:end-1);
    train_y = train(:,end);
    validation_X = validation(:,1:end-1);
    validation_y = validation(:,end);
    d = size(train_X,2);
    N = size(train_X,1);
    
    v = random('unif',-0.01,0.01,[k,m+1]);
    w = random('unif', -0.01,0.01,[m,d+1]);
    z = zeros(N,m);
    r = zeros(N,k);
    for t = 1:N
        r(t,train_y(t)+1) = 1;
    end
    ita = 0.001;
    
    train_X=[ones(N,1) train_X];
    err = 1;
    prev_err = -1;
    epoch = 0;
    while abs(err-prev_err) > 0.01
        prev_err = err;
        err = 0;
        if(epoch >= 10)
            ita = 0.0001;
        elseif(epoch >=50)
            ita = 0.00001;
        end
        for t = randperm(N)
            z_t = w * train_X(t,:)';
            z_t(z_t<0) = 0;
            z_t = [1 z_t'];
            
            o_t = (v * z_t')';
            y_t = exp(o_t)/sum(exp(o_t));
            
            delta_v = ita * (r(t,:)-y_t)' * z_t;
            delta_w = ita * ((r(t,:)-y_t) * v(:,2:end))' * train_X(t,:);
            delta_w(w<0) = 0;
            v = v + delta_v;
            w = w + delta_w;
            err = err - r(t,:)*(log(y_t))';
            z(t,:)=z_t(2:end);
        end
        epoch = epoch + 1;
    end
    fprintf('When the number of hidden units is %2d\n',m);
    fprintf('It takes %3d epoches to converge\n',epoch);
    
    global train_error
    global val_error
    % Training error    
    train_z = train_X * w';
    train_z(train_z<0) = 0;
    train_z = [ones(N,1) train_z];
    train_o = train_z * v';
    
    label = zeros(N,1);
    for t = 1:N
        softmax_sum = sum(exp(train_o(t,:)));
        y_t = exp(train_o(t,:))/softmax_sum;
        [~,idx] = max(y_t);
        label(t,1) = idx - 1;
    end
    
    training_err = sum(label~=train_y)/N;
    fprintf('The training error rate is %.4f\n',training_err);
    train_error(m/3) = training_err;
    
    % Validation error
    valid_N = size(validation,1);
    valid_X = validation(:,1:end-1);
    valid_y = validation(:,end);
    valid_X = [ones(valid_N,1) valid_X];
    
    valid_z = valid_X * w';
    valid_z(valid_z<0) = 0;
    valid_z = [ones(valid_N,1) valid_z];
    valid_o = valid_z * v';
    
    label = zeros(valid_N,1);
    for t = 1:valid_N
        softmax_sum = sum(exp(valid_o(t,:)));
        y_t = exp(valid_o(t,:))/softmax_sum;
        [~,idx] = max(y_t);
        label(t,1) = idx - 1;
    end
    
    validation_err = sum(label~=valid_y)/valid_N;
    fprintf('The validation error rate is %.4f\n',validation_err);
    val_error(m/3) = validation_err;
    
end