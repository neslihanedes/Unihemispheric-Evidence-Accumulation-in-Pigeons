
try
  
    binoMonoTrials1();
    closeNetworkIO();
catch error
    disp('There was some error >:(');
    disp(error.message);
    disp('Trying to cleanup open resources');
    
    closeNetworkIO();
    closeWindow;
    
    rethrow(error)
end