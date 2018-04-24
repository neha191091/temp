function A = unlinsc_mt(A, m, t)
% Undo m.*A+t with singleton expansion

A = bsxfun(@minus, A, t);
A = bsxfun(@rdivide, A, m);
