function [m0_out,t2_out,r2_out] = dotheT2fitSingle(input_intensities,tes,~,te_selection)

% -----------------------------------------------------------------------
% Performs a T2 map fit of multi-echo data for 1 pixel
% Gustav Strijkers
% 24 Sept 2023
% -----------------------------------------------------------------------


% drop the TEs that are deselected in the app
delements = find(te_selection==0);
tes(delements) = [];
input_intensities(delements) = [];

% prepare the data
x = [ones(length(tes),1),tes];
y = log(input_intensities)';

% do the linear regression
b = x\y;

% m0 and t2
m0 = exp(b(1));
t2 = -1/b(2);

% R2
yCalc2 = x * b;
r2 = 1 - sum((y - yCalc2).^2)/sum((y - mean(y)).^2);

% return the values
t2_out = t2;
m0_out = m0;
r2_out = r2;

end