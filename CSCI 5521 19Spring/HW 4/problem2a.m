train_path = 'optdigits_train.txt';
valid_path = 'optdigits_valid.txt';
global train_error
train_error = zeros(1,6);
global val_error  
val_error = zeros(1,6);
for m = 3:3:18
    [z w v] = mlptrain(train_path,valid_path,m,10);
end
plot(3:3:18,train_error);
hold on;
plot(3:3:18,val_error);


%Use 18 hidden units on the test set
%
test_path = 'optdigits_test.txt';
z = mlptest(test_path,w,v);
