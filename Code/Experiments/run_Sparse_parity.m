close all
clear
clc

dims = [5 10 25 50 100];

for j = 1:length(dims)
    
    d = dims(j);
    n = 1000;
    dgood = 3;
    ntrees = 500;
    ntrials = 5;
    NWorkers = 2;
    if d <= 5
        mtrys = 1:d;
    else
        mtrys = ceil(d.^[0 1/4 1/2 3/4 1]);
    end
    err_rf = zeros(ntrees,length(mtrys),ntrials);
    err_rerf = zeros(ntrees,length(mtrys),ntrials);
    err_rerfdn = zeros(ntrees,length(mtrys),ntrials);
    err_rf_rot = zeros(ntrees,length(mtrys),ntrials);
    Class = [0;1];

    for trial = 1:ntrials

        fprintf('trial %d\n',trial)

        X = zeros(n,d);
        %Sigma = 1/8*ones(1,d);
        Sigma = 1/32*ones(1,d);
        %nones = randi(d+1,n,1)-1;
        %Y = mod(nones,2);
        %Ystr = cellstr(num2str(Y));
        Mu = sparse(n,d);
        for jj = 1:n
            %onesidx = randsample(1:d,nones(j),false);
            %Mu(j,onesidx) = 1;
            Mu(jj,:) = binornd(1,0.5,1,d);
            X(jj,1:d) = mvnrnd(Mu(jj,:),Sigma);
        end

        nones = sum(Mu(:,1:dgood),2);
        Ystr = cellstr(num2str(mod(nones,2)));

        i = 1;

        for mtry = mtrys

            fprintf('mtry = %d\n',mtry)
            
            rf = rpclassificationforest(ntrees,X,Ystr,'RandomForest',true,'nvartosample',mtry,'NWorkers',NWorkers,'Stratified',true);
            err_rf(:,i,trial) = oobpredict(rf,X,Ystr,'every');

            rerf = rpclassificationforest(ntrees,X,Ystr,'sparsemethod','sparse','nvartosample',mtry,'NWorkers',NWorkers,'Stratified',true);
            err_rerf(:,i,trial) = oobpredict(rerf,X,Ystr,'every');

            rerfdn = rpclassificationforest(ntrees,X,Ystr,'sparsemethod','sparse','mdiff','node','nvartosample',mtry,'NWorkers',NWorkers,'Stratified',true);
            err_rerfdn(:,i,trial) = oobpredict(rerfdn,X,Ystr,'every');
            
            rf_rot = rpclassificationforest(ntrees,X,Ystr,'RandomForest',true,'rotate',true,'nvartosample',mtry,'NWorkers',NWorkers,'Stratified',true);
            err_rf_rot(:,i,trial) = oobpredict(rf_rot,X,Ystr,'every');

            i = i + 1;
        end
    end

    save(sprintf('~/RandomerForest/Results/Sparse_parity_parameter_selection_n%d_d%d.mat',n,d),'err_rf','err_rerf','err_rerfdn','err_rf_rot')

    if length(mtrys) < 5
        emptyCol = 5 - length(mtrys);
        
        sem_rf(:,1:length(mtrys),j) = std(err_rf,[],3)/sqrt(ntrials);
        sem_rerf(:,1:length(mtrys),j) = std(err_rerf,[],3)/sqrt(ntrials);
        sem_rerfdn(:,1:length(mtrys),j) = std(err_rerfdn,[],3)/sqrt(ntrials);
        sem_rf_rot(:,1:length(mtrys),j) = std(err_rf_rot,[],3)/sqrt(ntrials);
        sem_rf(:,length(mtrys)+1:5,j) = NaN(ntrees,emptyCol);
        sem_rerf(:,length(mtrys)+1:5,j) = NaN(ntrees,emptyCol);
        sem_rerfdn(:,length(mtrys)+1:5,j) = NaN(ntrees,emptyCol);
        sem_rf_rot(:,length(mtrys)+1:5,j) = NaN(ntrees,emptyCol);

        var_rf(:,1:length(mtrys),j) = var(err_rf,0,3);
        var_rerf(:,1:length(mtrys),j) = var(err_rerf,0,3);
        var_rerfdn(:,1:length(mtrys),j) = var(err_rerfdn,0,3);
        var_rf_rot(:,1:length(mtrys),j) = var(err_rf_rot,0,3);
        var_rf(:,length(mtrys)+1:5,j) = NaN(ntrees,emptyCol);
        var_rerf(:,length(mtrys)+1:5,j) = NaN(ntrees,emptyCol);
        var_rerfdn(:,length(mtrys)+1:5,j) = NaN(ntrees,emptyCol);
        var_rf_rot(:,length(mtrys)+1:5,j) = NaN(ntrees,emptyCol);

        mean_err_rf(:,1:length(mtrys),j) = mean(err_rf,3);
        mean_err_rerf(:,1:length(mtrys),j) = mean(err_rerf,3);
        mean_err_rerfdn(:,1:length(mtrys),j) = mean(err_rerfdn,3);
        mean_err_rf_rot(:,1:length(mtrys),j) = mean(err_rf_rot,3);
        mean_err_rf(:,length(mtrys)+1:5,j) = NaN(ntrees,emptyCol);
        mean_err_rerf(:,length(mtrys)+1:5,j) = NaN(ntrees,emptyCol);
        mean_err_rerfdn(:,length(mtrys)+1:5,j) = NaN(ntrees,emptyCol);
        mean_err_rf_rot(:,length(mtrys)+1:5,j) = NaN(ntrees,emptyCol);
    else
        sem_rf(:,:,j) = std(err_rf,[],3)/sqrt(ntrials);
        sem_rerf(:,:,j) = std(err_rerf,[],3)/sqrt(ntrials);
        sem_rerfdn(:,:,j) = std(err_rerfdn,[],3)/sqrt(ntrials);
        sem_rf_rot(:,:,j) = std(err_rf_rot,[],3)/sqrt(ntrials);

        var_rf(:,:,j) = var(err_rf,0,3);
        var_rerf(:,:,j) = var(err_rerf,0,3);
        var_rerfdn(:,:,j) = var(err_rerfdn,0,3);
        var_rf_rot(:,:,j) = var(err_rf_rot,0,3);

        mean_err_rf(:,:,j) = mean(err_rf,3);
        mean_err_rerf(:,:,j) = mean(err_rerf,3);
        mean_err_rerfdn(:,:,j) = mean(err_rerfdn,3);
        mean_err_rf_rot(:,:,j) = mean(err_rf_rot,3);
    end

end

save('~/RandomerForest/Results/Sparse_parity.mat','sem_rf','sem_rerf','sem_rerfdn','sem_rf_rot',...
    'var_rf','var_rerf','var_rerfdn','var_rf_rot',...
    'mean_err_rf','mean_err_rerf','mean_err_rerfdn','mean_err_rf_rot')