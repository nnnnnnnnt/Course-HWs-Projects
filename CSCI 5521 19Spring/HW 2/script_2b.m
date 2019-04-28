% Question 2.b

load optdigits_train.txt
load optdigits_test.txt
d=size(optdigits_train,2)-1;
[PC eigenvalues]=myPCA(optdigits_train(:,1:end-1),d);
ratio=zeros(1,d);
ratio(1)=eigenvalues(1);
for i=2:d
    ratio(i)=ratio(i-1)+eigenvalues(i);
end
ratio=ratio/sum(eigenvalues);
plot(1:d,ratio,'-+');
xlabel('Eigen Vectors');
ylabel('Prop. of Variance');

K=find(ratio>0.9,1);
disp('The minimum number of eigenvectors that explains at least 90% of the variance is');
disp(K);

w = PC(:,1:K);
mu = mean(optdigits_train(:,1:end-1));
z = w'*(optdigits_train(:,1:end-1)'-mu');
projected_train = z';
mu = mean(optdigits_test(:,1:end-1));
z = w'*(optdigits_test(:,1:end-1)'-mu');
projected_test = z';

projected_train=[projected_train optdigits_train(:,end)];
projected_test=[projected_test optdigits_test(:,end)];


for k = 1:2:7
    prediction = myKNN(projected_train,projected_test,k);
    err_rate=sum(prediction~=optdigits_test(:,end))/length(optdigits_test);
    disp(sprintf('Error rate when k = %d',k));disp(err_rate);
end

% Question 2.c
K=2;
w = PC(:,1:K);
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
xlabel('Principal Components 1');
ylabel('Principal Components 2');


