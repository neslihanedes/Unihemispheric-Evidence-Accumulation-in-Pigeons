
try 
    start;
    bIO(5,1)
    experimentConditionsConfiguration;

    par.probeDelay = par.probeDelay1;
    binoMonoTrials1(par);
    par.probeDelay = par.probeDelay2;
    binoMonoTrials1(par);

    % ask user
    userSelection = questdlg('One more ride my darling?');
    if strcmp(userSelection, 'Yes')
        par.probeDelay = par.probeDelay1;
        binoMonoTrials1(par);
        par.probeDelay = par.probeDelay2;
        binoMonoTrials1(par);
    end

    closeNetworkIO();
catch error
    disp('There was some error >:(');
    disp(error.message);
    disp('Trying to cleanup open resources');
    
    closeNetworkIO();
    closeWindow;
    
    rethrow(error)
end