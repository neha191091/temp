function A = linsc_mt(A, m, t)
% Calculate m.*A+t with singleton expansion

A = bsxfun(@times, m, A);
A = bsxfun(@plus, A, t);
