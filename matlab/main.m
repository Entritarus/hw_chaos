% setup
min_time = 0;
max_time = 200;
x0 = [0; 0; 0];
ode_options = odeset('RelTol', 1.0e-6, 'AbsTol', 1.0e-6, 'MaxStep', 1e-3);

N = 5;

C1 = 1e-9; % 1e-9 
C2 = 150e-12; % 150e-12

L1 = 1e-3; % 1e-3
tau = sqrt(L1*C1);

f1 = figure(1); hold on; % phase portrait
set(f1,'Position',[0 0 1280 720]);

for n = 1:N
    
    
    %tic;
    [t, var] = ode45(@(t, var) calc_derivatives(t, var, n), [min_time, max_time], x0, ode_options);
    %toc;
    x = var(:,1);
    y = var(:,2);
    z = var(:,3);
    figure(1);
    hold on
    plot3(x, y, z);
    
end

figure(1);
grid on; grid minor;
set(gca,'FontSize',16);
xlabel('x');
ylabel('y');
