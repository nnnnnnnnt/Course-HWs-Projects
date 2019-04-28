load face_train_data_960.txt
mu = mean(face_train_data_960(:,1:end-1));
K = [10 50 100];
pos=1;
for i = 1:3
    [PC eigenvalues]=myPCA(face_train_data_960(:,1:end-1),K(i));
    z = PC'*(face_train_data_960(:,1:end-1)'-mu');
    projected_train = z';
    
    reconstructed = (PC*projected_train'+mu')';
 
    for j = 1:5
        subplot(3,5,pos);
        pos = pos + 1;
        imagesc(reshape(reconstructed(j,:),32,30)');
        title("Image: " + j + "; k=" + K(i));
    end
end