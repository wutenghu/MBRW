clear;
clc;

%% Preprocessing step : Import Train dataset

pathInputData = '../Data/InputData/';

% Change name of file for different input dataset 
nameInputData = 'InputDataYahooKDD2011Sample.dat';
disp(strcat('Importing dataset from ',pathInputData, nameInputData));
importfile(strcat(pathInputData, nameInputData));
clickstreams_pairwise = InputDataVarName;
max_item_idx = max(max(clickstreams_pairwise(:,2)));
disp('Number of user item pairs in input dataset: ');
disp(size(clickstreams_pairwise,1));

%% Generation of CVS and DS from data
disp('Generating CVS, DS model ... ');
create_model;
clickstreams_train = clickstreams;
disp('Generation of CVS, DS matrices finished ! ');

%% Generating Markov Matrices from CVS and DS
disp('Generationg markov matrices from CVS and DS ... ');
makeMarkovMatrices;
disp('Markov matrices created ! ');

%% Saving model parameters

save('../Data/ModelAutoGeneratedData/CVS_norm','CVS_norm');
save('../Data/ModelAutoGeneratedData/DS_norm','DS_norm');
save('../Data/ModelAutoGeneratedData/clickstreams_train','clickstreams_train');
save('../Data/ModelAutoGeneratedData/clickstreams_train_user','clickstreams_train_user');
save('../Data/ModelAutoGeneratedData/clickstream_matrix','clickstream_matrix');

clear;
disp('Model saved in ../Data/ModelAutoGeneratedData/ directory ! ');

%% Generation of synthetic clickstream data

disp('Importing model parameters from ../Data/ModelAutoGeneratedData/ ... ');
load('../Data/ModelAutoGeneratedData/CVS_norm.mat');
load('../Data/ModelAutoGeneratedData/DS_norm.mat');
load('../Data/ModelAutoGeneratedData/clickstreams_train.mat');
load('../Data/ModelAutoGeneratedData/clickstreams_train_user.mat');
load('../Data/ModelAutoGeneratedData/clickstream_matrix.mat');


disp('Generation of synthetic dataset started with default parameters ...');
% MBRW algoritm parameters
mbrw_parameters = zeros(1,8);
num_synthetic_cs = 1000;
mbrw_parameters(1) = num_synthetic_cs;
% Memory parameters from Gauss distribution
mu1 = 3;
mbrw_parameters(2) = mu1;
sigma1 = 2;
mbrw_parameters(3) = sigma1;
% Number of hops parameters from Gauss distribution
mu2 = 5;
mbrw_parameters(4) = mu2;
sigma2 = 2;
mbrw_parameters(5) = sigma2;
% Last index parameter from Gauss distribution
mu3 = 0;
mbrw_parameters(6) = mu3; 
sigma3 = 1;
mbrw_parameters(7) = sigma3;

% Anonymization constant theta with default 0.8 
% Synthetic clickstreams will not have any clickstream
% that has similarity to some real clickstream above theta value
% Note that we use rigid similarity measure between clickstreams which
% is calculates as similarity between binary vectors where ordering is not relevant
theta = 0.8;
mbrw_parameters(8) = theta; 

[ artificial_clickstream_set, sequence_matrix_rw, cvs_matrix_rw ] = MBRW( clickstreams_train, clickstreams_train_user, clickstream_matrix, DS_norm, CVS_norm, mbrw_parameters );

%% Exporting syntehtic clickstream data to AML file format

name_str = '../Data/OutputData/SyntheticData.dat';
out = exportSetToAML_format( artificial_clickstream_set, name_str );
disp('Synthetic dataset saved to ../Data/OutputData/SyntheticData.dat !');