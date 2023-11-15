function value = exp_approx(x, N, x_min, x_max)
% Approximates the exp function by bitwise linear functions
    
    x_step = (x_max-x_min)/N;

    value = 0;
    for i = 0:N-1
        x1 = x_min + i*x_step;
        x2 = x1 + x_step;

        if x >= x1
            y1 = exp(x1);
            y2 = exp(x2);

            value = (x-x1)/(x2-x1)*(y2-y1) + y1;
        end
    end
    
end

