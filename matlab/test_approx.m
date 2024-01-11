
x = -10:0.1:10;
y_approx = zeros(size(x));
y = exp(x);

x_tb = -10:0.1:10-0.1;
y_tb = csvread('../components/exponent_approx/sim/output.csv');
y_tb = y_tb(:,1);

for i = 1:length(x)
    y_approx(i) = exp_approx(x(i), 5, -10, 10);
end

f1 = figure(1);
set(f1, 'Position', [0 0 1280 720]);
subplot(2,1,1);

semilogy(x, y_approx); hold on
%semilogy(x_tb, y_tb); 
semilogy(x, y);
legend({
    "Approximated"
    "Original"
},'location', 'southeast');
xlabel('{\itx}');
ylabel('e^{\itx}');
set(gca, 'FontSize', 12);
grid on; grid minor;

subplot(2,1,2);
semilogy(x, y_approx-y); grid on; grid minor;
xlabel('{\itx}');
set(gca, 'FontSize', 12);
legend("Difference")