% CSCI 5521 Introduction to Machine Learning
% Rui Kuang
% Demonstration of Classification by 2-D Gaussians 

mu1 = [-1 -1];
mu2 = [1 1];

% Equal diagnoal covariance matrix
 Sigma1 = [1 0; 0 1];
 Sigma2 = [1 0; 0 1];

% Diagnoal covariance matrix
% Sigma1 = [1 0; 0 0.5];
% Sigma2 = [1 0; 0 0.5];

% Shared covariance matrix
% Sigma1 = [1 0.3; 0.3 0.5];
% Sigma2 = [1 0.3; 0.3 0.5];

 x1 = -10:.1:10; x2 = -10:.1:10;

% covariance matrix (increase the range for visualization)
% Sigma1 = [1 0.1; 0.1 0.5];
% Sigma2 = [0.5 0.3; 0.3 1];
% x1 = -40:.1:40; x2 = -40:.1:40;

[X1,X2] = meshgrid(x1,x2);
%pdf1
F1 = mvnpdf([X1(:) X2(:)],mu1,Sigma1);
F1 = reshape(F1,length(x2),length(x1));
subplot(1,2,1);
surf(x1,x2,F1); hold on;

%pdf2
F2 = mvnpdf([X1(:) X2(:)],mu2,Sigma2);
F2 = reshape(F2,length(x2),length(x1));
surf(x1,x2,F2);
caxis([min(F2(:))-.5*range(F2(:)),max(F2(:))]);
axis([-4 4 -4 4 0 .4])
xlabel('x1'); ylabel('x2'); zlabel('Probability Density');

%decosopm boundary
%F1 = mvnpdf([X1(:) X2(:)],mu1,Sigma1);
%F1 = reshape(F1,length(x2),length(x1));
%F2 = mvnpdf([X1(:) X2(:)],mu2,Sigma2);
%F2 = reshape(F2,length(x2),length(x1));

cmp = F1 > F2;
subplot(1,2,2);
imagesc(X1(:),X2(:),cmp);

xlabel('x1'); ylabel('x2');
