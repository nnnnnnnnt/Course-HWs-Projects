function[h,mu,q]=EMG(flag,image_name,k)

[img,cmap] = imread(image_name);
img_rgb = ind2rgb(img,cmap);
img_double = im2double(img_rgb);
row=size(img_rgb,1);
col=size(img_rgb,2);
X=reshape(img_double,[],3);
N=size(X,1);
lambda=0.00001;
% initialize
[idx, mu]=kmeans(X,k,'MaxIter',2,'EmptyAction','singleton');
h=zeros(N,k);
for i=1:k
    if flag==0
        S(:,:,i)=cov(X(idx(:)==i,:));
    else
        S(:,:,i)=cov(X(idx(:)==i,:))+lambda*eye(3,3); 
    end
    pi(i)= sum(idx(:)==i)/N;
end
n_iterations = 200;
q=zeros(n_iterations,2);
for m=1:n_iterations
   summ=zeros(N,1);
    for i= 1:k
       p(:,i)=mvnpdf(X,mu(i,:),S(:,:,i));
        h(:,i)=pi(i)*p(:,i);
        summ(:)=summ(:)+h(:,i);
    end
    %oldp=p;
%p=bsxfun(@rdivide, p, sum(p,2));
h=h./summ;
Ni=sum(h);
mu_updated=h'*X;
mu_updated=mu_updated./Ni';
pi_updated=Ni/N;
S_updated=zeros(3,3,k);
for i=1:k
    for j=1:N
        if flag==0
            S_updated(:,:,i)=S_updated(:,:,i)+ h(j,i).*(X(j,:)-mu(i,:))'*(X(j,:)-mu(i,:));
     	else
            S_updated(:,:,i)=S_updated(:,:,i)+ h(j,i).*(X(j,:)-mu(i,:))'*(X(j,:)-mu(i,:))+lambda*eye(3,3);
        end
    end
    S_updated(:,:,i)=S_updated(:,:,i)./Ni(i);
 end

 p(p==0)=0.00000001;
 pi(pi==0)=0.00000001; 
 q(m,1)=sum(h)*transpose(log(pi))+sum(sum(h.*log(p))); 


 S=S_updated;
 mu=mu_updated;
 pi=pi_updated;

 for i=1:k
    p(:,i)=mvnpdf(X,mu(i,:),S(:,:,i));
 end
p(p==0)=0.00000001;
pi(pi==0)=0.00000001; 
q(m,2)=sum(h)*transpose(log(pi))+sum(sum(h.*log(p))); 

end
[~,membership] = max(h,[],2);
image=zeros(N,3);
for j=1:N
    image(j,:)=mu(membership(j),:);
end
image=reshape(image,row,col,3);        
figure;
imagesc(image);
figure;

x=0.5:0.5:n_iterations;
x1=0.5:1:n_iterations-0.5;
x2=1:1:n_iterations;
qt = q'
plot(x,qt(:));
hold all;
scatter(x1,q(:,1),'.','r');
scatter(x2,q(:,2),'.','G');
hold off;