function [theta, J_history] = gradientDescentMulti(X, y, theta, alpha, num_iters)
%GRADIENTDESCENTMULTI Performs gradient descent to learn theta
%   theta = GRADIENTDESCENTMULTI(x, y, theta, alpha, num_iters) updates theta by
%   taking num_iters gradient steps with learning rate alpha

% Initialize some useful values
m = length(y); % number of training examples
J_history = zeros(num_iters, 1);

for iter = 1:num_iters

    % ====================== YOUR CODE HERE ======================
    % Instructions: Perform a single gradient step on the parameter vector
    %               theta. 
    %
    % Hint: While debugging, it can be useful to print out the values
    %       of the cost function (computeCostMulti) and gradient here.
    %



    predict1 = theta(1) - alpha*sum(((X*theta)-y).*X(:,1))/m;
    predict2 = theta(2) - alpha*sum(((X*theta)-y).*X(:,2))/m;
    predict3 = theta(3) - alpha*sum(((X*theta)-y).*X(:,3))/m;

    theta(1) = predict1;
    theta(2) = predict2;
    theta(3) = predict3;







    % ============================================================

    % Save the cost J in every iteration    
    J_history(iter) = computeCostMulti(X, y, theta);

end

end
