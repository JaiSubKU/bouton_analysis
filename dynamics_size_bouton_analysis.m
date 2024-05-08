%change branch name MANUAL ENTRY
Processed_table_S1 = table2array(B4.Processed_table_S1);
Processed_table_S2 = table2array(B4.Processed_table_S2);


% percentage change in bouton fluorescence
bouton_change = 100*(ch1_SDs_above_k_mean_S2-ch1_SDs_above_k_mean_S1)./ch1_SDs_above_k_mean_S1;
bouton_fluo_S1  =   ch1_SDs_above_k_mean_S1;

% find synapse class
stable_enpassant = find(Processed_table_S1(:,1)-Processed_table_S2(:,1)==0 & Processed_table_S1(:,1)==1);
size.enpassant.enpassant_change = bouton_change(stable_enpassant);

stable_terminal = find(Processed_table_S1(:,1)-Processed_table_S2(:,1)==0 & Processed_table_S1(:,1)==2);
size.terminal.terminal_change = bouton_change(stable_terminal);

% get first session fluorescence

enpassant_fluo_S1 = find(Processed_table_S1(:,1)==1);
size.enpassant.S1_fluo = bouton_fluo_S1(enpassant_fluo_S1);

terminal_fluo_S1 = find(Processed_table_S1(:,1)==2);
size.terminal.S1_fluo = bouton_fluo_S1(terminal_fluo_S1);

%change branch name MANUAL ENTRY
B4.size=size;

