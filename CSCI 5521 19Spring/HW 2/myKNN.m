function prediction = myKNN(training_data,test_data,k)
    dist_matrix = pdist2(test_data(:,1:end-1),training_data(:,1:end-1));
    sorted_index = zeros(length(test_data),length(training_data));
    for i = 1:length(test_data)
        [~,sorted_index(i,:)]=sort(dist_matrix(i,:));
    end
    sorted_index=sorted_index(:,1:k);
    y=training_data(:,end);
    neighbour_labels=y(sorted_index);
    prediction=mode(neighbour_labels,2);
end