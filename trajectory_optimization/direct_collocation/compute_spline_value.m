% Compute the value of the ith spline
function [s, sdot] = compute_spline_value(i, t, z, n, p, N, Dt, dynamics)

    [s0, s1, s2, s3] = compute_spline_coefficients(i, z, n, p, N, Dt, dynamics);
    s = s0 + s1*t + s2*t^2 + s3*t^3;
    sdot = s1 + 2*s2*t + 3*s3*t^2;

end