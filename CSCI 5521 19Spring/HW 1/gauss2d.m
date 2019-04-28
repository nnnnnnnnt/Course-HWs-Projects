% CSCI 5521 Introduction to Machine Learning 
% Rui Kuang
% Demonstration of 2-D Gaussians 

%Try Sigma = [0.5, 0;0, 0.5];Sigma = [0.7, 0;0, 0.3];Sigma = [0.7, 0.2;0.2, 0.3]

mu = [0 0];
Sigma = [0.7, 0.2;0.2, 0.3];
x1 = -3:.2:3; x2 = -3:.2:3;
[X1,X2] = meshgrid(x1,x2);
%pdf
F = mvnpdf([X1(:) X2(:)],mu,Sigma);
F = reshape(F,length(x2),length(x1));
subplot(1,2,1);
surf(x1,x2,F);
caxis([min(F(:))-.5*range(F(:)),max(F(:))]);
axis([-3 3 -3 3 0 .4])
xlabel('x1'); ylabel('x2'); zlabel('Probability Density');
subplot(1,2,2);
contour(x1,x2,F,[.0001 .001 .01 .05:.1:.95 .99 .999 .9999],'ShowText','on');

%contour
figure
i=1;
for rho = -0.8:0.4:0.8
    Sigma(1,2)=rho*sqrt(Sigma(1,1)*Sigma(2,2));
    Sigma(2,1)=Sigma(1,2);
    F = mvnpdf([X1(:) X2(:)],mu,Sigma);
    F = reshape(F,length(x2),length(x1));
    subplot(1,5,i);
    i=i+1;
    contour(x1,x2,F,[.0001 .001 .01 .05:.1:.95 .99 .999 .9999]);
    title (sprintf('rho = %f',rho));
    xlabel('x1'); ylabel('x2');
end