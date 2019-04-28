classdef myLReLULayer < nnet.layer.Layer

properties (Learnable)
        % Layer learnable parameters
            
        % Scaling coefficient
        %Alpha
    end   
    
    methods
        function layer = myLReLULayer(~, name) 
            % Create an examplePreluLayer with numChannels channels

            % Set layer name
            if nargin == 2
                layer.Name = name;
            end

            % Set layer description
%            layer.Description = ...
 %               ['examplePreluLayer with ', num2str(numChannels), ' channels']; 
        
        end
        
        function Z = predict(layer,X)
            % Forward input data through the layer and output the result
            
            Z = max(0, X) + 0.01 .* min(0, X);
        end
        
        function [dLdX] = backward(layer, X, Z, dLdZ, memory)
            % Backward propagate the derivative of the loss function through 
            % the layer 
            
            dLdX = 0.01 .* dLdZ;
            dLdX(X>0) = dLdZ(X>0);
            
        end
    end
end