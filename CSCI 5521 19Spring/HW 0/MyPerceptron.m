% CSCI 5521 Introduction to Machine Learning
% Rui Kuang(Some modifications done by Tao Ni)
% Perceptron function 


function [w step] = MyPerceptron(X,Y,w_init)

w = w_init;
N = size(X,2);
pos_idx = (Y==1);
neg_idx = (Y==-1);
mxx = max(X(1,:));
mnx=-1*mxx;%for visualization %mnx = min(X(1,:));
mxy = max(X(2,:));
mny=-1*mxy; % for visualization %mny = min(X(2,:));

figure;
ginput(1);
err = 1;
step = 0;
while err > 0  
  for ii = 1 : N         %cycle through training set
    if sign(w'*X(:,ii)) ~= Y(ii)       
        %wrong decision?
        w = w + X(:,ii) * Y(ii);   %then add (or subtract) this point to w
        x1=mnx:0.01:mxx;
        x2=-(w(1)*x1+w(3))/w(2);
        %figure;
        clf;
        hold on
        plot(X(1,pos_idx),X(2,pos_idx),'b*','MarkerSize',10);
        plot(X(1,neg_idx),X(2,neg_idx),'r+','MarkerSize',10);
        plot(X(1,ii),X(2,ii),'ko','MarkerSize',15);
        plot(x1,x2);
        xlim([mnx mxx]);
        ylim([mny mxy]);
        %ginput(1);
        pause(1); %change the delay
    end
  end
  step = step + 1
  err = sum(sign(w'*X)~=Y)/N   %show misclassification rate
end