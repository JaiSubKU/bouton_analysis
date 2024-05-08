% this file uses intensity-values obtained from Kalen's imageJ macro and
% the XYZ values obtained from running the code for SNT trace to create
% tables that contain information about synapse type, their intensity,
% their intensity in relation to bg determined using k nearest neighbor

% take inputs
Table_branch = readtable('intensity-values-B4.xlsx');
SNT_xyz = readtable('SNT-coordinates-B4.xlsx');
SNT_xyz = table2array(SNT_xyz);


%change distance from soma for each branch
distance_from_soma_S1 = 0;


% MANUAL ENTRY
% Set the number of nearest neighbors to find
k = 8;


% get rid of unnecessary columns in the excel file
Table_branch_rel =Table_branch(:,[4,5,6,7,11,12,13,17,19,20,21,22,23,24]);
Table_branch_rel_array = table2array(Table_branch_rel);

% Since the synapse type in the original table is string and in a Cell
% array format, it is taken out of the table first as below
Synapse_type = Table_branch(:,16);
Synapse_type_array=table2array(Synapse_type);

%create categorical array for synapse types and have consistent numerical
%values
%!!bouton_analysis version: EnPassant = 1, TerminalBoutons = 2, Nothing =
%3
Synapse_type_array_cat = categorical(Synapse_type_array);
Synapse_type_array_cat_reord = reordercats(Synapse_type_array_cat,{'EnPassant','TerminalBoutons','Nothing'});
Synapse_type_num = grp2idx(Synapse_type_array_cat_reord);

% Final table is made by making synapse type as the first column, followed
% by Session number, X,Y,Z coordinates of the bg, xyz of synapses, marker #, Ch1,2,3 intensity, Ch1,2,3 adjacent shaft background value
Final_table = horzcat(Synapse_type_num,Table_branch_rel_array);

% Remove rows containing NaN
Final_table(any(isnan(Final_table), 2), :) = [];

% Remove rows containing NaN
Table_branch_rel_array(any(isnan(Table_branch_rel_array), 2), :) = [];

%Separate table based on session 
 ind1 = Final_table(:,2) == 1;
 ind2 = Final_table(:,2) == 2;
 Final_table_S1 = Final_table(ind1,:);
 Final_table_S2 = Final_table(ind2,:);

% to get marker_coordinates from the table and correct the z coordinate
marker_coordinates_S1 = Final_table_S1(:,[6,7,8]);
marker_coordinates_zcorr_S1=marker_coordinates_S1;
marker_coordinates_zcorr_S1(:,3)=ceil(marker_coordinates_zcorr_S1(:,3)./3);

% x,y corrected marker coordinates
marker_coordinates_xyzcorr_S1 = marker_coordinates_zcorr_S1;
marker_coordinates_xyzcorr_S1(:,[1,2]) = 0.13.*marker_coordinates_xyzcorr_S1(:,[1,2]);

% Get first SNT coordinates. 

First_SNT_coordinates_S1 = SNT_xyz(1,:);

% get x, y, and z of SNT_xyz
x=SNT_xyz(:,1);
y=SNT_xyz(:,2);
z=SNT_xyz(:,3);

% get distance between each pixel of SNT trace and create cumulative
% distance
consecutiveDistances_SNT = sqrt((x(2:end)-x(1:end-1)).^2 + (y(2:end)-y(1:end-1)).^2 + (z(2:end)-z(1:end-1)).^2);
cum_consec_dist_SNT = cumsum(consecutiveDistances_SNT);
cum_consec_dist_SNT = vertcat(0,cum_consec_dist_SNT);

% get distance of each marker with each SNT marker
dist_marker_SNT = pdist2(marker_coordinates_xyzcorr_S1,SNT_xyz);

% get minimum distance of each marker (M) with each SNT marker and find the
% index (I)
[M,I]=min(dist_marker_SNT,[],2);

% get distance of each marker with first SNT pixel
marker_dist_first_SNT =  cum_consec_dist_SNT(I);
marker_dist_first_SNT_final =cum_consec_dist_SNT(I)+M;

% calculates distance of each marker from soma (distance from first
% landmark + distance from soma to first landmark)
distance_from_soma_final = marker_dist_first_SNT_final + distance_from_soma_S1;

% create an array and table with all the required information and sort it
% based on distance from the first landmark
Final_table_S1_dist_soma = horzcat(Final_table_S1,marker_dist_first_SNT_final,distance_from_soma_final);
Final_table_S2_dist_soma = horzcat(Final_table_S2,marker_dist_first_SNT_final,distance_from_soma_final);

% from now it will be session specific analysis
% first S1

% Keep only relevant columns for final analysis
Processed_table_S1 = Final_table_S1_dist_soma;
Processed_table_S1(:,[3,4,5,6,7,8,13,14,15]) = [];


% keep only S1 (S2 will be below)
Table_branch_rel_array_S1 = Table_branch_rel_array;
Table_branch_rel_array_S1(Table_branch_rel_array_S1(:,1) ~= 1, :) = [];

% get xyz values for synapses and background
bg_xyz_S1 = Table_branch_rel_array_S1(:,2:4);
synapse_xyz_S1 = Table_branch_rel_array_S1(:,5:7);

% Find the indices (rows) of the k nearest neighbors in bg_xyz for each
% point in synapse_xyz
idx_S1 = knnsearch(bg_xyz_S1, synapse_xyz_S1, 'K', k);

% get the distance between each synapse and bg marker. rows each synapse and columns each bg
syn_bg_dist_S1 = pdist2(synapse_xyz_S1,bg_xyz_S1);

% get bg fluorescence values
ch1_bg_fl_S1 = Table_branch_rel_array_S1(:,12);

% get the fluorescence bg values for k nearest neighbors
ch1_bg_nearest_k_S1 = ch1_bg_fl_S1 (idx_S1(:, 1:k));

% get xyz values for synapses and adjacent
Table_branch_adj_S1 = table2array(Table_branch(:,[8,9,10,25,26,27]));
adj_xyz_S1 = Table_branch_adj_S1(:,1:3);

% Find the indices (rows) of the k nearest neighbors in adj_xyz for each
% point in synapse_xyz
idxadj_S1 = knnsearch(adj_xyz_S1, synapse_xyz_S1, 'K', k);

% get adj fluorescence values
ch1_adj_fl_S1 = Table_branch_adj_S1(:,4);

% get the fluorescence adj values for k nearest neighbors
ch1_adj_nearest_k_S1 = ch1_adj_fl_S1 (idxadj_S1(:, 1:k));

% concotanate adjacent and background nearest neighbor fluorescence values
adj_bg_combined_S1 = horzcat(ch1_bg_nearest_k_S1,ch1_adj_nearest_k_S1);
mean_adj_bg_combined_S1 = mean(adj_bg_combined_S1,2); 
stddev_adj_bg_combined_S1 = std(adj_bg_combined_S1,[],2);
threshold_Ch1_S1 = mean_adj_bg_combined_S1 + 3*stddev_adj_bg_combined_S1;
ch1_fluo_S1 = Processed_table_S1(:,4);

% get marker ratio/threshold
ch1_thresh_ratio_S1 = ch1_fluo_S1./threshold_Ch1_S1;

%Get number of SDs each marker is above k nearest neighbors
ch1_SDs_above_k_mean_S1 = (ch1_fluo_S1 - mean_adj_bg_combined_S1)./stddev_adj_bg_combined_S1;

%create an empty column to match the column order with previous analysis
empty_col = zeros(height(Processed_table_S1),1);

%!!replaced unused variables with empty_col
Processed_table_S1=horzcat(Processed_table_S1(:,1:3),empty_col,empty_col,ch1_SDs_above_k_mean_S1,Processed_table_S1(:,4:8),ch1_thresh_ratio_S1,empty_col,empty_col,empty_col);

% same as above in a table format
Processed_table_S1_final = array2table(Processed_table_S1,...
    'VariableNames',{'Synapse_type','Session','marker_id','empty1','empty2','Ch1_SDs_above_k_mean','Ch1_int','empty4','empty5','dist_firstlandmark','empty6',' Threshold Ratio','empty7','empty8','empty9'});

% now S2

% Keep only relevant columns for final analysis
Processed_table_S2 = Final_table_S2_dist_soma;
Processed_table_S2(:,[3,4,5,6,7,8,13,14,15]) = [];

% keep only S2 
Table_branch_rel_array_S2 = Table_branch_rel_array;
Table_branch_rel_array_S2(Table_branch_rel_array_S2(:,1) ~= 2, :) = [];

% get xyz values for synapses and background

bg_xyz_S2 = Table_branch_rel_array_S2(:,2:4);
synapse_xyz_S2 = Table_branch_rel_array_S2(:,5:7);

% Find the indices (rows) of the k nearest neighbors in bg_xyz for each
% point in synapse_xyz

idx_S2 = knnsearch(bg_xyz_S2, synapse_xyz_S2, 'K', k);

% get the distance between each synapse and bg marker. rows each synapse and columns each bg

syn_bg_dist_S2 = pdist2(synapse_xyz_S2,bg_xyz_S2);

% get bg fluorescence values
ch1_bg_fl_S2 = Table_branch_rel_array_S2(:,12);

% get the fluorescence bg values for k nearest neighbors
ch1_bg_nearest_k_S2 = ch1_bg_fl_S2 (idx_S2(:, 1:k));

% get xyz values for synapses and adjacent
Table_branch_adj_S2 = table2array(Table_branch(:,[8,9,10,25,26,27]));
adj_xyz_S2 = Table_branch_adj_S2(:,1:3);

% Find the indices (rows) of the k nearest neighbors in adj_xyz for each
% point in synapse_xyz
idxadj_S2 = knnsearch(adj_xyz_S2, synapse_xyz_S2, 'K', k);

% get adj fluorescence values
ch1_adj_fl_S2 = Table_branch_adj_S2(:,4);

% get the fluorescence adj values for k nearest neighbors
ch1_adj_nearest_k_S2 = ch1_adj_fl_S2 (idxadj_S2(:, 1:k));

% concotanate adjacent and background nearest neighbor fluorescence values
adj_bg_combined_S2 = horzcat(ch1_bg_nearest_k_S2,ch1_adj_nearest_k_S2);
mean_adj_bg_combined_S2 = mean(adj_bg_combined_S2,2); 
stddev_adj_bg_combined_S2 = std(adj_bg_combined_S2,[],2);
threshold_Ch1_S2 = mean_adj_bg_combined_S2 + 3*stddev_adj_bg_combined_S2;
ch1_fluo_S2 = Processed_table_S2(:,4);

% get marker ratio/threshold
ch1_thresh_ratio_S2 = ch1_fluo_S2./threshold_Ch1_S2;

%Get number of SDs each marker is above k nearest neighbors
ch1_SDs_above_k_mean_S2 = (ch1_fluo_S2 - mean_adj_bg_combined_S2)./stddev_adj_bg_combined_S2;

%create an empty column to match the column order with previous analysis
empty_col = zeros(height(Processed_table_S2),1);

%!!replaced unused variables with empty_col
Processed_table_S2=horzcat(Processed_table_S2(:,1:3),empty_col,empty_col,ch1_SDs_above_k_mean_S2,Processed_table_S2(:,4:8),ch1_thresh_ratio_S2,empty_col,empty_col,empty_col);

% same as above in a table format
Processed_table_S2_final = array2table(Processed_table_S2,...
      'VariableNames',{'Synapse_type','Session','marker_id','empty1','empty2','Ch1_SDs_above_k_mean','Ch1_int','empty4','empty5','dist_firstlandmark','empty6',' Threshold Ratio','empty7','empty8','empty9'});


%change branch name
%MANUAL ENTRY
B4.dendrite_length = max(cum_consec_dist_SNT);
B4.Processed_table_S1 = Processed_table_S1_final;
B4.Processed_table_S2 = Processed_table_S2_final;
