% test stack-of-stars sequence 
currentFolder = cd;
addpath(genpath(fullfile(pwd,'info4Test')));
cd ('../sequences'); 
run('seqStartup.m');
cd(currentFolder); 
run('SOSseq.m');
cd ('../sequences/stack_of_stars'); 
mySOS = SOSkernel(inputs); % create a SOSkernel object
mySOS.writeSequence('testSOS','testing',1); 
cd(currentFolder); 
clearvars -except currentFolder;


% test koosh-ball sequence 
run("KBseq.m")
cd ('../sequences/koosh_ball') 
myKB = KBkernel(inputs); % create a KBkernel object
myKB.writeSequence('testKB','testing',1); 
cd(currentFolder); 
clearvars -except currentFolder;

rmpath(genpath(fullfile(pwd,'info4Test')));
fprintf('### test passed ###');
clearvars; 


