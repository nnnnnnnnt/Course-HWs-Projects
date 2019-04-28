complete_path = 'optdigits_complete.txt';
train_path = 'optdigits_train.txt';
valid_path = 'optdigits_valid.txt';
complete = load(complete_path);
y = complete(:,end);
N = size(complete,1);

[z w v] = mlptrain(train_path,valid_path,18,10);
z = mlptest(complete_path,w,v);
sample_to_text = randsample(N,fix(N/20));

score = pca(z');
pc = score(:,1:2);
pc = log(pc+1);
figure
scatter(pc(:,1),pc(:,2),8,y+1,'filled');
text(pc(sample_to_text,1),pc(sample_to_text,2),num2str(y(sample_to_text)));
xlabel('Principal Components 1');
ylabel('Principal Components 2');

figure
pc = score(:,1:3);
pc = log(pc+1);
scatter3(pc(:,1),pc(:,2),pc(:,3),8,y+1,'filled');

text(pc(sample_to_text,1),pc(sample_to_text,2),pc(sample_to_text,3),num2str(y(sample_to_text)));
xlabel('Principal Components 1');
ylabel('Principal Components 2');
zlabel('Principal Components 3');



