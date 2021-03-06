N = 10000;
x = linspace(0, 1, N);

mu = 0;
sigma = 1;
% ground truth
y = icdf('Normal', x, mu, sigma);

% quantize (64)
Q = 64;
step = 0.5 / (2*Q);
x_quant = linspace(step, 0.5 - step, Q);
y_level = icdf('Normal', x_quant, mu, sigma);
% map to 0~2Q
val = 2*Q*x/0.5;
% map to 1~Q
val = round((val+1)/2);
val(N) = 2*Q;
% mirror at 0.5
val = val .* (val <= Q) + (2*Q+1 - val) .* (val > Q);
% plot(x, x_mirror_at_center);
y_quant = y_level(val);
y_quant = y_quant .* (x <= 0.5) - y_quant .* (x > 0.5);

error = abs(y_quant - y);
figure;
semilogy(x, error);
xlabel('ICDF value', 'interpreter', 'latex');
ylabel('Quantization Error', 'interpreter', 'latex');
title('Error vs ICDF when L = 64', 'interpreter', 'latex', 'Fontsize', 14);

figure;
plot(x, y);
xlabel('CDF', 'interpreter', 'latex');
ylabel('epsilon', 'interpreter', 'latex');
title('ICDF', 'interpreter', 'latex', 'Fontsize', 14);

figure;
stem(x_quant, y_level);
xlabel('CDF', 'interpreter', 'latex');
ylabel('epsilon', 'interpreter', 'latex');
title('ICDF', 'interpreter', 'latex', 'Fontsize', 14);

ave_err = sum(error(2:N-1))/(N-2);