%Q2.d
load optdigits_train.txt
load optdigits_test.txt

L = [2 4 9];

for i = L
    [matrix eigenvalues] = myLDA(optdigits_train,i);
    training_z = (matrix'*optdigits_train(:,1:end-1)')';
    test_z = (matrix'*optdigits_test(:,1:end-1)')';
    training_z = [training_z optdigits_train(:,end)];
    test_z = [test_z optdigits_test(:,end)];
    for k = 1:2:5
        prediction = myKNN(training_z,test_z,k);
        err_rate = sum(prediction~=optdigits_test(:,end))/length(optdigits_test);
        disp(sprintf('Error rate when L = %d and k = %d is',i,k));disp(err_rate);
    end
end

%Q2.e
[matrix eigenvalues] = myLDA(optdigits_train,2);
w = matrix;
mu = mean(optdigits_train(:,1:end-1));
z = w'*(optdigits_train(:,1:end-1)'-mu');
projected_train = z';
mu = mean(optdigits_test(:,1:end-1));
z = w'*(optdigits_test(:,1:end-1)'-mu');
projected_test = z';

projected_train=[projected_train optdigits_train(:,end)];
projected_test=[projected_test optdigits_test(:,end)];
projected = [projected_train;projected_test];
class = projected(:,end);

color = [1,1,10; 1,10,0; 1,0,0; 1,0,1; 0,1,1; 0,0,1; 0,0,0; 0,1,0; 0.5,0.5,0.5; 0,0.5,1];
scatter(projected(:,1),projected(:,2),10,color(class+1),'filled');
text(projected(:,1),projected(:,2),num2str(class));
xlabel('LDA Projection 1');
ylabel('LDA Projection 2');
