function f = Bayes_Testing(testing_data,p1,p2,pc1,pc2)
    [rows,cols]=size(testing_data);
    
    err=0;
    for row = 1:rows
        c=0;posterior_C1=pc1;posterior_C2=pc2;
        for col = 1:cols-1
            c1 = p1(col).^(1-testing_data(row,col)) * (1-p1(col)).^testing_data(row,col);
            c2 = p2(col).^(1-testing_data(row,col)) * (1-p2(col)).^testing_data(row,col);
            if c1==0
                c1=10^-10;
            end
            if c2==0
                c2=10^-10;
            end
            posterior_C1=posterior_C1*c1;
            posterior_C2=posterior_C2*c2;
        end
        if(posterior_C1>posterior_C2)
            c=1;
        else
            c=2;
        end
        if c~=testing_data(row,end)
            err=err+1;
        end
    end
sprintf('Error rate in percentage: %f', err*100/rows)
                