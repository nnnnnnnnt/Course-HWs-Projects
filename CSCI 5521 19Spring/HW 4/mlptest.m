function [z] = mlptest(test_path,w,v)
    test_data = load(test_path);
    N = size(test_data,1);
	y = test_data(:,end);
    test_X = [ones(N,1) test_data(:,1:end-1)];
    z = w * test_X';
    z(z<0) = 0;
    z = [ones(N,1) z'];
    o = z * v';
    label = zeros(N,1);
    for t = 1:N
        softmax_sum = sum(exp(o(t,:)));
        y_t = exp(o(t,:))/softmax_sum;
        [~,idx] = max(y_t);
        label(t,1) = idx-1;
    end
    test_error=sum(label~=y)/N;
    fprintf('The test error using 18 hidden units is: %.4f\n',test_error);
    
end