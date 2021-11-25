[data,input_name] = loadgas;
trn_data = data(1:2:end,:);
chk_data = data(2:2:end,:);
exhsrch(1,trn_data,chk_data,input_name);
input_index = exhsrch(2,trn_data,chk_data,input_name);
exhsrch(3,trn_data,chk_data,input_name);
close all;
new_trn_data = trn_data(:,[input_index, size(trn_data,2)]);
new_chk_data = chk_data(:,[input_index, size(chk_data,2)]);
in_fismat = genfis(new_trn_data(:,1:end-1),new_trn_data(:,end));
anfisOpt = anfisOptions('InitialFIS',in_fismat,'EpochNumber',100,...
                        'StepSizeDecreaseRate',0.5,...
                        'StepSizeIncreaseRate',1.5,...
                        'ValidationData',new_chk_data,...
                        'DisplayANFISInformation',0,...
                        'DisplayErrorValues',0,...
                        'DisplayStepSize',0,...
                        'DisplayFinalResults',0);
[trn_out_fismat,trn_error,step_size,chk_out_fismat,chk_error] = ...
    anfis(new_trn_data,anfisOpt);
[a,b] = min(chk_error);
plot(1:100,trn_error,'g-',1:100,chk_error,'r-',b,a,'ko')
title('Training (green) and checking (red) error curve','fontsize',10)
xlabel('Epoch numbers','fontsize',10)
ylabel('RMS errors','fontsize',10)
% Performing Linear Regression
N = size(trn_data,1);
A = [trn_data(:,1:6) ones(N,1)];
B = trn_data(:,7);
coef = A\B; % Solving for regression parameters from training data

Nc = size(chk_data,1);
A_ck = [chk_data(:,1:6) ones(Nc,1)];
B_ck = chk_data(:,7);
lr_rmse = norm(A_ck*coef-B_ck)/sqrt(Nc);
% Printing results
fprintf('\nRMSE against checking data\nANFIS : %1.3f\tLinear Regression : %1.3f\n', a, lr_rmse);
chk_out_fismat = setfis(chk_out_fismat,'input',1,'name','Weight');
chk_out_fismat = setfis(chk_out_fismat,'input',2,'name','Year');
chk_out_fismat = setfis(chk_out_fismat,'output',1,'name','MPG');

% Generating the FIS output surface plot
gensurf(chk_out_fismat);
plot(new_trn_data(:,1),new_trn_data(:, 2),'bo', ...
     new_chk_data(:,1),new_chk_data(:, 2),'rx')
xlabel('Weight','fontsize',10)
ylabel('Year','fontsize',10)
title('Training (o) and checking (x) data','fontsize',10)
