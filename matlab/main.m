clear variables
%% Image loading
img = imread('../res/cameraman_50x50.tif');
img = img(:,:,1);
img_w = width(img);
img_h = height(img);
N_pix = img_w*img_h;

%% cipher
min_time = 0;
max_time = 50; %2*img_w;
x0 = [0; 0; 0];
ode_options = odeset('RelTol', 1.0e-6, 'AbsTol', 1.0e-6, 'MaxStep', 1e-3);

N = 5; % approximating line count

% fig1 = figure(1); % phase portrait
% set(fig1,'Position',[0 0 1280 720]);

%values = uint8(zeros(1, N_vals));

img_encr = uint8(zeros(img_h, img_w));
tic
for i = 1:img_h
    for j = 1:img_w
        [t, var] = ode45(@(t, var) calc_derivatives(t, var, N), [min_time, max_time], x0, ode_options);
        x0 = [var(length(var(:,1)),1), var(length(var(:,2)),2), var(length(var(:,3)),3)];

        y = var(:,2);
        x = var(:,1);

        % get y = 0 line crossings
        y_cross_indices = find(diff(sign(y)) < 0);
        y_cross_indices = y_cross_indices(2:end);

        bits = x(y_cross_indices) < 60;
        if length(bits) >= 8
            bits = 1*(bits(1:8))';
        else
            bits = 1*[bits' zeros(1, 8-length(bits))];
        end
        
        img_bits = de2bi(img(i, j),8);
        img_encr(i, j) = bi2de(xor(bits, img_bits));

        disp(['Progress = ' num2str(((i-1)*img_w + j-1)/N_pix*100)]);
    end
end
toc
y_cross = y(y_cross_indices);
x_cross = x(y_cross_indices);
plot(x, y); hold on;
scatter(x_cross, y_cross);

figure(2);
imshow(img);

%% encrypted
figure(3);
imshow(img_encr);

imwrite(img_encr, '../res/cameraman_50x50_encr.tif', 'TIFF');