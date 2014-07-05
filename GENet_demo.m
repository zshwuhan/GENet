close all
clear all
% clc
% load PIE_32x32.mat
% load dataYaleB.mat
% load mnist_basic.mat
% load dataORL.mat
addpath('Liblinear')
addpath('Utils')
cd 'orl_faces'
getORLdata(5)
load dataORL

% load myPIE
% load dataYaleB
%% ================== setting GENet ==========================
% load dataORL

GENet.layer{1}.type = 'PCA';
GENet.layer{1}.ReducedDim = 100;


GENet.layer{2}.type = 'MFA';
GENet.layer{2}.intraK = 2;  %越大越紧
GENet.layer{2}.interK = 500;  %越大越高
GENet.layer{2}.ReducedDim = 70;
GENet.layer{2}.Regu = 1;

% GENet.layer{2}.type = 'MFA';
% GENet.layer{2}.intraK = 5;  %越大越紧
% GENet.layer{2}.interK = 500;  %越大越高
% GENet.layer{2}.ReducedDim = 71;
% GENet.layer{2}.Regu = 1;

GENet.layer{3}.type = 'PCA';
GENet.layer{3}.ReducedDim = 60;

GENet.layer{3}.type = 'MFA';
GENet.layer{3}.intraK = 10;  %越大越紧
GENet.layer{3}.interK = 500;  %越大越高
GENet.layer{3}.ReducedDim = 40;
GENet.layer{3}.Regu = 1;

%% ================== train GENet ==========================
fprintf('\n ====== Computing the eigvalue ======= \n')
[GENet,output] = GENet_train(GENet,train_data,train_label);


fprintf('\n ====== Training Linear SVM Classifier ======= \n')
models = train(train_label,sparse(output), '-s 1 -q'); % we use linear SVM classifier (C = 1), calling libsvm library


%% ================== test GENet ==========================

fprintf('\n ====== MFANet Testing ======= \n')
output = GENet_test(GENet,test_data);


nCorrRecog = 0;
tic; 
for i=1:size(output,1)
    [xLabel_est, accuracy, decision_values] = predict(test_label(i),sparse(output(i,:)), models, '-q'); % label predictoin by libsvm  
    if xLabel_est == test_label(i)
        nCorrRecog = nCorrRecog + 1;
    end
    if 0==mod(i,size(output,1)/2); 
        fprintf('Accuracy up to %d tests is %.2f%%; taking %.2f secs per testing sample on average. \n',...
           [i 100*nCorrRecog/i toc/i]); 
    end
end


Accuracy = nCorrRecog / size(output,1); 
ErRate = 1 - Accuracy;
fprintf('\n     Testing error rate: %.2f%%\n', 100*ErRate);
fprintf('\n     Testing Accuracy rate: %.2f%%\n', 100*Accuracy);



