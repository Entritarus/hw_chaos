x_min = -10;
x_max = 10;
N = 3;


x_step = (x_max-x_min)/N;

for i = 0:N-1
    
    x1 = x_min + i*x_step;
    x2 = x1 + x_step;
    y1 = exp(x1);
    y2 = exp(x2);
    
    k = (y2-y1)/(x2-x1);
    b = y1 - x1*(y2-y1)/(x2-x1);
    
    disp(['Breakpoint ' num2str(i) ': x = ' num2str(x1) ', k = ' num2str(k) ', b = ' num2str(b)])
end