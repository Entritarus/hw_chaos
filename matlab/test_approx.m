
x = -10:0.1:10;
y_approx = zeros(size(x));
y = exp(x);

for i = 1:length(x)
    y_approx(i) = exp_approx(x(i), 3, -10, 10);
end

f1 = figure(1);
set(f1, 'Position', [0 0 1280 720]);
subplot(2,1,1);
hold on
plot(x, y_approx); grid on; grid minor;
plot(x, y);
legend({
    "Approximated"
    "Real"
});

subplot(2,1,2);
plot(x, y_approx-y); grid on; grid minor;
legend("Difference")