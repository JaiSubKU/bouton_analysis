
%input Processed_table_S1/S2/S3 from the output of data_conversion

%change branch name MANUAL ENTRY
Processed_table_S1 = table2array(B4.Processed_table_S1);
Processed_table_S2 = table2array(B4.Processed_table_S2);


% density of synapses MANUAL ENTRY
density.Total_dendritic_length = B4.dendrite_length;


% calculate dynamics
dynamics.enpassant.num_gain_enpassant = sum(Processed_table_S1(:,1)-Processed_table_S2(:,1)==2);
dynamics.enpassant.num_loss_enpassant = sum(Processed_table_S1(:,1)-Processed_table_S2(:,1)==-2);
dynamics.enpassant.num_stable_enpassant = sum(Processed_table_S1(:,1)-Processed_table_S2(:,1)==0 & Processed_table_S1(:,1)==1);

dynamics.terminal.num_gain_terminal = sum(Processed_table_S1(:,1)-Processed_table_S2(:,1)==1);
dynamics.terminal.num_loss_terminal = sum(Processed_table_S1(:,1)-Processed_table_S2(:,1)==-1);
dynamics.terminal.num_stable_terminal = sum(Processed_table_S1(:,1)-Processed_table_S2(:,1)==0 & Processed_table_S1(:,1)==2);

density.S1.num_enpassant = sum(Processed_table_S1(:,1)==1);
density.S1.density_enpassant = density.S1.num_enpassant/density.Total_dendritic_length;
density.S1.num_terminal = sum(Processed_table_S1(:,1)==2);
density.S1.density_terminal = density.S1.num_terminal/density.Total_dendritic_length;


density.S2.num_enpassant = sum(Processed_table_S2(:,1)==1);
density.S2.density_enpassant = density.S2.num_enpassant/density.Total_dendritic_length;
density.S2.num_terminal = sum(Processed_table_S2(:,1)==2);
density.S2.density_terminal = density.S2.num_terminal/density.Total_dendritic_length;


%change branch name MANUAL ENTRY
B4.density=density;
B4.dynamics = dynamics;







