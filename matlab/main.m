clear variables
% setup
img = imread('../res/house.tif');
img_w = width(img);

min_time = 0;
max_time = 2*img_w;
x01 = [0; 0; 0];
x02 = [10; 10; 0];
ode_options = odeset('RelTol', 1.0e-6, 'AbsTol', 1.0e-6, 'MaxStep', 1e-3);

N = 5; % approximating line count

% fig1 = figure(1); % phase portrait
% set(fig1,'Position',[0 0 1280 720]);

for k = 1:1
    
    disp("Computing first...")
    [t, var1] = ode45(@(t, var) calc_derivatives(t, var, N), [min_time, max_time], x01, ode_options);
    x01 = [var1(length(var1(:,1)),1), var1(length(var1(:,2)),2), var1(length(var1(:,3)),3)];
    disp("Computing second...")
    [t, var2] = ode45(@(t, var) calc_derivatives(t, var, N), [min_time, max_time], x02, ode_options);
    x02 = [var2(length(var2(:,1)),1), var2(length(var2(:,2)),2), var2(length(var2(:,3)),3)];
    
    disp("Comparing")
    compare_x = downsample(var1((1:4000*img_w),1) > var2((1:4000*img_w),1), 1000);
    
    disp(['Progress: ' num2str(k/img_w*100) '%'])
end



%extract_comparison


% x_raw = int32(csvread('../components/vilnius_oscillator/sim/test_out_x.csv'));
% y_raw = int32(csvread('../components/vilnius_oscillator/sim/test_out_y.csv'));
% z_raw = int32(csvread('../components/vilnius_oscillator/sim/test_out_z.csv'));
% 
% x_int = bitshift(x_raw, -16);
% y_int = bitshift(y_raw, -16);
% z_int = bitshift(z_raw, -16);
% 
% x_frac = bitand(x_raw, 65535);
% y_frac = bitand(y_raw, 65535);
% z_frac = bitand(z_raw, 65535);
% 
% x_fpga = double(x_int) + double(x_frac) .* 2^(-16);
% y_fpga = double(y_int) + double(y_frac) .* 2^(-16);
% z_fpga = double(z_int) + double(z_frac) .* 2^(-16);
% 
% plot3(x_fpga, y_fpga, z_fpga);
