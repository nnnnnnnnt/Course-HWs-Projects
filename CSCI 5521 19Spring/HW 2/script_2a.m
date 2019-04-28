load optdigits_train.txt
load optdigits_test.txt
for k = 1:2:7
    prediction = myKNN(optdigits_train,optdigits_test,k);
    err_rate=sum(prediction~=optdigits_test(:,end))/length(optdigits_test);
    disp(sprintf('Error rate when k = %d',k));disp(err_rate);
end