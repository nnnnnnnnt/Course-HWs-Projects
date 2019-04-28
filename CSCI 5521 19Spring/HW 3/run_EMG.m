% Question 2.a and 2.b
for k = 4:4:12
    [h,m,q] = EMG(0,'stadium.bmp',k)
end

% Question 2.c
[img,cmap] = imread('goldy.bmp');
img_rgb = ind2rgb(img,cmap);
img_double = im2double(img_rgb);
X=reshape(img_double,[],3);
N=size(X,1);
row=size(img_rgb,1);
col=size(img_rgb,2);
[idx, mu]=kmeans(X,7,'MaxIter',200,'EmptyAction','singleton');

image=zeros(N,3);
for i = 1:N
    image(i,:) = mu(idx(i),:);
end
image=reshape(image,row,col,3);        
figure;
imagesc(image);
