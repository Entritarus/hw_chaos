function dvar = calc_derivatives(t, var, n)
    % specify constants
    R1 = 1e3;
    R2 = 10e3;
    R3 = 6e3;
    R4 = 20e3;

    C1 = 1e-9; % 1e-9 
    C2 = 150e-12; % 150e-12

    L1 = 1e-3; % 1e-3
    Vin = 10; % change

    IR4 = Vin/R4;
    k = R3/R2 + 1;

    q = 1.6e-19;
    kb = 1.38e-23; % Boltzmann constant
    T = 300; % ambient temperature of the diode
    IS = 60e-9; % reverse current of 1n4148 diode

    a = (k-1)*R1/sqrt(L1/C1);
    b = IR4*q*sqrt(L1/C1)/kb/T;
    c = IS*q*sqrt(L1/C1)/kb/T;
    e = C2/C1;

    % get variables
    x = var(1);
    y = var(2);
    z = var(3);

    % calculate derivatives
    dvar(1,:) = y;
    dvar(2,:) = a*y - x - z;
    dvar(3,:) = (b + y - c*(exp_approx(z, n, -5, 10) - 1))/e;
end