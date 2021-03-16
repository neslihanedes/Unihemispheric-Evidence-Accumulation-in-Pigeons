function out = startProbeTrial(par, stim, i)
% This function handles the probe trial

% Tobias Otto
% 1.0
% 25.04.2018

% 25.04.2018, Tobias: first draft

%% Init variables
trialType   = par.buffer(1,i);
delay       = par.buffer(2,i);
% Init response structs
nogoResp    = keyBuffer(0);
goResp      = nogoResp;

%% Start ITI
showStimuli;
WaitSecs(par.timeITI);

%% Check helmet
if(ismember(trialType, 7))
    % probe trial left
    bIO(par.shutterLeft, par.shutterOn);
elseif(ismember(trialType, 8))
    % probe trial right
    bIO(par.shutterRight, par.shutterOn);
end

%% Start init
showStimuli(stim.init, par.posStimuli);
controlSound(snd);
init = keyBuffer(par.timeITI, 'goodKey', par.posStimuli, par.peckInit);

% Clear screen
showStimuli;

%% Continue after response
if(init.goodKey == par.peckInit)
    initDone = 1;
    
    %% Wait given time
    WaitSecs(par.timeDelay);
    
    %% Show stimulus GO and wait for response
    showStimuli(stim.good, par.posStimuli);
    goResp = keyBuffer(delay, 'goodKey', par.posStimuli, par.peckStimulus);
    
    %% Show Stimulus NOGO and wait for response
    if(goResp.goodKey ~= par.peckStimulus)
        showStimuli(stim.bad, par.posStimuli);
        nogoResp = keyBuffer(par.timeStimulus, 'badKey', par.posStimuli, par.peckStimulus);
        
        %% Punish
        if(nogoResp.badKey > 0)
            punishment(par.timePunish);
        end
    else
        %% Reward
        feeding(par.timeReward);
    end
else
    initDone    = 0;
end

%% Check helmet again
if(ismember(trialType, 7))
    % probe trial left
    bIO(par.shutterLeft, par.shutterOff);
elseif(ismember(trialType, 8))
    % probe trial right
    bIO(par.shutterRight, par.shutterOff);
end

%% Store variables in output struct
out.i           = i;
out.trialType   = trialType;
out.delay       = delay;
out.init        = init;
out.respGo    	= goResp;
out.respNogo  	= nogoResp;
out.initDone    = initDone;
out.reward      = goResp.goodKey == par.peckStimulus;
out.punish      = nogoResp.badKey > 0;

