load face_train_data_960.txt
load face_test_data_960.txt
combined = [face_train_data_960; face_test_data_960];
labels = combined(:,end);

[PC, eigenvalues] = myPCA(combined(:,1:end-1), 5);
w = PC';

for i = 1:5
    subplot(2,3,i);
    imagesc(reshape(w(i,:),32,30)');
    title("Eigen-face "+i);
end