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

for n = N:N
    
    
    %tic;
    [t, var] = ode45(@(t, var) calc_derivatives(t, var, n), [min_time, max_time], x0, ode_options);
    %toc;
    x = var(:,1);
    y = var(:,2);
    %z = var(:,3);
    figure(1);
    hold on
    plot(x, y);
    
end

figure(1);
grid on; grid minor;
set(gca,'FontSize',16);
xlabel('x');
ylabel('y');

x_raw = int32(csvread('../components/vilnius_oscillator/sim/test_out_x.csv'));
y_raw = int32(csvread('../components/vilnius_oscillator/sim/test_out_y.csv'));
%z_raw = int32(csvread('../components/vilnius_oscillator/sim/test_out_z.csv'));

x_int = bitshift(x_raw, -16);
y_int = bitshift(y_raw, -16);
%z_int = bitshift(z_raw, -16);

x_frac = bitand(x_raw, 65535);
y_frac = bitand(y_raw, 65535);
%z_frac = bitand(z_raw, 65535);

x_fpga = double(x_int) + double(x_frac) .* 2^(-16);
y_fpga = double(y_int) + double(y_frac) .* 2^(-16);
%z_fpga = double(z_int) + double(z_frac) .* 2^(-16);

plot(x_fpga, y_fpga);
xlabel('{\itx}');
ylabel('{\ity}');
legend('MATLAB', 'Questa Simulation')