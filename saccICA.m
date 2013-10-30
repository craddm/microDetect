function EEG = saccICA(EEG)
    
    EEG = pop_epoch( EEG, {  'sac'  }, [-0.1 0.1], 'newname', 'Merged datasets epochs', 'epochinfo', 'yes');
    EEG = pop_rmbase( EEG, []);    

    covarianceMatrix = cov(double(EEG.data(1:68,:))');
    [E, D] = eig (covarianceMatrix);
    rankTolerance = 1e-7;
    tmprank = sum (diag (D) > rankTolerance);

    EEG = pop_runica(EEG, 'icatype','runica','dataset',1,'options',{'extended' 1},'chanind',[1:68],'pca',tmprank);
