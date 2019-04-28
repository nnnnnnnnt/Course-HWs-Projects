load face_train_data_960.txt
load face_test_data_960.txt
d=size(face_train_data_960,2)-1;
[PC eigenvalues]=myPCA(face_train_data_960(:,1:end-1),d);
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
mu = mean(face_train_data_960(:,1:end-1));
z = w'*(face_train_data_960(:,1:end-1)'-mu');
projected_train = z';
mu = mean(face_test_data_960(:,1:end-1));
z = w'*(face_test_data_960(:,1:end-1)'-mu');
projected_test = z';

projected_train=[projected_train face_train_data_960(:,end)];
projected_test=[projected_test face_test_data_960(:,end)];


for k = 1:2:7
    prediction = myKNN(projected_train,projected_test,k);
    err_rate=sum(prediction~=face_test_data_960(:,end))/length(face_test_data_960);
    disp(sprintf('Error rate when k = %d',k));disp(err_rate);
end