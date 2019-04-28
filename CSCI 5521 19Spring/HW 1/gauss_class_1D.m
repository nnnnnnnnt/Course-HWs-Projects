% CSCI 5521 Introduction to Machine Learning
% Rui Kuang
% Demonstration of Classification by 1-D Gaussians 

%mean and standard deviation of class blue
mu1 = -2;sd1 = 2;

%mean and standard deviation of class red
mu2 = 2;sd2 = 4;

%generate x-axis
sd = max(sd1,sd2);
ix = -6*sd-1:1e-1:6*sd+1; %covers more than 99% of the curve

iy1 = pdf('normal', ix, mu1, sd1);
iy2 = pdf('normal', ix, mu2, sd2);

subplot(1,2,1);
plot(ix,iy1,'b'); hold on;
plot(ix,iy2,'r');
title('PDF P(X)');

%prior 
p1=0.8;
p2=1-p1;

%calculate the posteriors
iy1_n = p1*iy1 ./ (p1*iy1+p2*iy2);
iy2_n = p2*iy2 ./ (p1*iy1+p2*iy2);
subplot(1,2,2);
plot(ix,iy1_n,'b'); hold on;
plot(ix,iy2_n,'r');
title('Posteriors P(C | x)');