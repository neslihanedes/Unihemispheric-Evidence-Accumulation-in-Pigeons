% start
%
% Call this script to use all functions of the biopsy Toolbox.
%
% INPUTS
%
% INPUTS-OPTIONAL
%
% OUTPUTS
%
% EXAMPLES
%
% Copyright 2007-2017
% CC-GNU GPL by attribution
% Please cite the BioPsychology Toolbox where this function is used.
%       http://biopsytoolbox.sourceforge.net/
%
% See also: mySetup

% VERSION HISTORY:
% Author:  		Tobias Otto, Jonas Rose
% Version: 		1.9
% Last Change:  03.03.2018

% 14.06.2017, Tobias: release version for Biopsy Toolbox 2
% 21.06.2017, Tobias: added IO support for Raspberry Pi 2
% 07.07.2017, Tobias: added option for psychtoolbox verbosity
% 17.07.2017, Tobias: initialized WINDOW.handle as emty matrix
% 06.10.2017, Tobias: bugfix for init of network IO box
% 06.11.2017, Tobias: added Jonas udp viewer and memory mapped files
% 07.11.2017, Tobias: moved computations from mySetup to start
% 04.12.2017, Tobias: added global struct NETWORK for remote experiments
% 01.03.2018, Tobias: added callback and timer for manual shaping
% 03.03.2018, Tobias: added ACN io device

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DO NOT edit enything beyond this line
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
year = datestr(now,'yyyy');
clc
disp(' ===================================================================');
disp('  The BioPsychology Toolbox II - A free, open source Matlab Toolbox ');
disp(' ===================================================================');
disp(' ');
disp('                           --- 64 bit ---');
disp(' ');
disp('         Developed at the Ruhr University in Bochum, ');
disp('             Institute of Cognitive Neuroscience');
disp(' ');
disp(' Cite the BioPsychology Toolbox where any of the toolbox-functions');
disp('   are used or results obtained using the toolbox are published.');
disp(' ');
disp(['        Copyright 2007-' year ', CC-GNU GPL by attribution']);
disp('             http://biopsytoolbox.sourceforge.net/');
disp(' ');
disp(' ');
disp('Initializing ...');

%% Add global variables
global SETUP
global WINDOW
global NETWORK
NETWORK.num     = 0;    % Number of active network connections
WINDOW.handle   = [];
on              = 1;
off             = 0;

%% Get setup information
if(isempty(dir('mySetup.m')))
    disp(' ================================================================');
    disp(' Sorry, but I can''t find the file mySetup.m')
    disp(' Please copy it into the current working directory');
    disp(' ================================================================');
    error('Please solve problem and try again');
else
    mySetup
end

% Order fields
SETUP = orderfields(SETUP);

%% Initializations and minor computations
% For Monitor dimensions
SETUP.screen.width  = SETUP.screen.width/SETUP.screen.ScreenWidth;
SETUP.screen.height = SETUP.screen.height/SETUP.screen.ScreenHeight;
SETUP.screen.X      = SETUP.screen.X/SETUP.screen.ScreenWidth;
SETUP.screen.Y      = SETUP.screen.Y/SETUP.screen.ScreenHeight;
% For screen color
SETUP.screen.bgColor= SETUP.screen.bgColor*255;

% For touchscreen
SETUP.touchScreen.time              = 0;
SETUP.touchScreen.lastTime          = 0;
SETUP.touchScreen.localValue        = [0 0];
SETUP.touchScreen.lastLocalValue    = [0 0];
SETUP.touchScreen.globalValue       = [0 0];
SETUP.touchScreen.lastGlobalValue   = [0 0];
SETUP.touchScreen.screenIndex       = 1;
SETUP.touchScreen.lastScreenIndex   = 0;
SETUP.touchScreen.found             = 0;
SETUP.touchScreen.offIndex          = -1;
SETUP.touchScreen.deltaP            = SETUP.touchScreen.deltaP/mean([SETUP.screen.ScreenWidth, SETUP.screen.ScreenHeight]);

% For ephys (photo diode)
SETUP.ephys.photodiode = SETUP.ephys.photodiode./ ...
    [SETUP.screen.ScreenWidth SETUP.screen.ScreenHeight SETUP.screen.ScreenWidth SETUP.screen.ScreenHeight];

% Convert strings of feeder type to numbers
switch lower(SETUP.io.feederType)
    case 'time'
        SETUP.io.feederType = 1;
    case 'amount'
        SETUP.io.feederType = 2;
end

% Init variable to control initializations
SETUP.networkDIO.initDone = 0;  % Set this value anyway, even if we use other hardware

% Init raspberry
if(~isfield(SETUP.raspberry, 'num'))
    SETUP.raspberry.num = 0;
end

%% Check inputs in mySetup
% %%%%%%%%%%%%%%%%%%%%%%%%
if(any(SETUP.screen.X > 1))
    disp(' ================================================================');
    disp(' Check entries in mySetup.m! ');
    disp(' At least one entry of the left lower corner in X direction is ');
    disp(' bigger than the screen width itself.');
    disp(' Check entris in section 5 or 6');
    disp(' ================================================================');
    error('Please solve problem and try again');
end

if(any(SETUP.screen.Y > 1))
    disp(' ================================================================');
    disp(' Check entries in mySetup.m! ');
    disp(' At least one entry of the left lower corner in Y direction is ');
    disp(' bigger than the screen height itself.');
    disp(' Check entris in section 5 or 6');
    disp(' ================================================================');
    error('Please solve problem and try again');
end

if(length(SETUP.screen.X) ~= length(SETUP.screen.Y))
    disp(' ================================================================');
    disp(' Check entries in mySetup.m! ');
    disp(' The number of switch positions in X and Y direction aren''t equal');
    disp(' Correct this problem in section 6');
    disp(' ================================================================');
    error('Please solve problem and try again');
end

if(length(SETUP.screen.X)+length(SETUP.screen.Y) ~= ...
        length(SETUP.screen.width)+length(SETUP.screen.height))
    disp(' ================================================================');
    disp(' Check entries in mySetup.m! ');
    disp(' The number of entries of switch positions aren''t equal to the');
    disp(' entries in switch width and height. Correct this problem in ');
    disp(' section 6 or 7.');
    disp(' ================================================================');
    error('Please solve problem and try again');
end

%% Set new state for rand !!!
% Get info about the environment
if(strcmpi(SETUP.platform, 'Windows64Bit'))
    % Get SETUP.platformNum info
    SETUP.platformNum = 1;
    
    % Check MATLAB version
    tmp     = version('-release');
    tmp1    = tmp(end);
    tmp2    = str2double(tmp(1:end-1));
    
    if(tmp2 < 2012 || strcmpi('2012a', tmp))
        error('This MATLAB version is too old. Please update at least to MATLAB 2012b');
    elseif(tmp2 >= 2012 && tmp2 < 2015)
        RandStream.setGlobalStream(RandStream('mt19937ar','Seed',sum(100*clock)));
    elseif(tmp2 >= 2015)
        rng('shuffle');
    end
elseif(strcmpi(SETUP.platform, 'RaspberryPi2'))
    % Get SETUP.platformNum info
    SETUP.platformNum = 2;
    
    % Put code here to initialize the random number generator!
else
    disp(' ================================================================');
    disp(' Check entries in mySetup.m! ');
    disp(' The name of the SETUP.platformNum is wrong specified!');
    disp(' Correct this problem in section (1c)');
    disp(' ================================================================');
    error('Please solve problem and try again');
end

% Necessary for subfunctions ... since they use toc
tic


%% Add path for psychtoolbox toolbox
% Check for correct entry of the Biopsytoolbox
if(exist([SETUP.toolboxPath filesep 'IO'],'dir') && ...
        exist([SETUP.toolboxPath filesep 'Screen'],'dir') && ...
        exist([SETUP.toolboxPath filesep 'Sound'],'dir') && ...
        exist([SETUP.toolboxPath filesep 'Tools'],'dir') && ...
        exist([SETUP.toolboxPath filesep 'Touchscreen'],'dir'))
    disp(['--> Found Biopsychology Toolbox in: ' SETUP.toolboxPath])
else
    disp(' ====================================================================');
    disp(' Check the entry of the Biopsychology Toolbox path');
    disp(' There is no toolbox in this path or the folder structure is broken');
    disp(' Please correct this problen in the mySetup.m file in section 1a.');
    disp(' ================================================================');
    error('Please solve problem and try again');
end

% Check for correct entry of the PsychToolbox
if(exist([SETUP.psychToolboxPath filesep 'PsychBasic'],'dir') && ...
        exist([SETUP.psychToolboxPath filesep 'PsychOneliners'],'dir') && ...
        exist([SETUP.psychToolboxPath filesep 'PsychRects'],'dir') && ...
        exist([SETUP.psychToolboxPath filesep 'PsychSound'],'dir') && ...
        exist([SETUP.psychToolboxPath filesep 'PsychJava'],'dir'))
    disp(['--> Found Psychtoolbox in: ' SETUP.psychToolboxPath])
else
    disp(' ====================================================================');
    disp(' Check the entry of the Psych Toolbox path');
    disp(' There is no toolbox in this path or the folder structure is broken');
    disp(' Please correct this problen in the mySetup.m file in section 1b.');
    disp(' ================================================================');
    error('Please solve problem and try again');
end

% Get all folders
psychPath = genpath(SETUP.psychToolboxPath);

% Set path for psych toolbox
addpath(psychPath);

%% Change paths according to the Psychophysics Toolbox PostInstRoutine
% Is this a Release2007a or later Matlab?
if(SETUP.platformNum == 1)
    % This is a R2007a or post R2007a Matlab:
    % Add MatlabWindowsFilesR2007a subfolder to Matlab path:
    addpath([SETUP.psychToolboxPath '\PsychBasic\MatlabWindowsFilesR2007a\']);
    disp('--> using Matlab release 2007a or later');
elseif(SETUP.platformNum == 2)
    % This is a Raspberry system
    % Add Octave3LinuxFilesARM subfolder to Matlab path:
    addpath([SETUP.psychToolboxPath '/PsychBasic/Octave3LinuxFilesARM/']);
    disp('--> using Octave on Raspberry Pi');
else
    % This is a pre-R2007a Matlab:
    % Add MatlabWindowsFilesR11 subfolder to Matlab path:
    disp(' --------------------------------------------');
    disp(' --> Matlab release prior to R2007a detected.');
    disp(' Sorry this version is not longer supported!');
    disp(' Please upgrade to a newer version of MATLAB');
    disp(' --------------------------------------------');
    error('Please solve problem and try again');
end

%% Set verbosity of Psychtoolbox
if(SETUP.platformNum == 1)
    Screen('Preference', 'Verbosity', SETUP.psychToolbox.verbosity);
elseif(SETUP.platformNum == 2)
    % This is a Raspberry system --> set to zero anyway!
    % Otherwise Octave will get stuck and waits for space press
    Screen('Preference', 'Verbosity', 2);
    disp(' --> Setting psych toolbox verbosity to 0');
end

%% Set path for biopsy toolbox
% Get all folders
bioPath = genpath(SETUP.toolboxPath);
% Set path for biopsy toolbox finally
addpath(bioPath);

% Check which interface is used
switch lower(SETUP.io.interface)
    case 'iowarrior'
        interface = 1;
    case 'parallel'
        interface = 2;
    case 'keyboard'
        interface = 3;
    case 'fbiscience'
        interface = 4;
    case 'warriorbox'
        interface = 5;
    case 'networkbox'
        interface = 7;
    case 'networkboxmatlab'
        interface = 8;
    case 'raspberrypi2'
        interface = 9;
    case 'networkboxacn'
        interface = 10;
    otherwise
        disp(' ================================================================');
        disp(' Check entries in mySetup.m! ');
        disp(' Please specify correct IO interface in mySetup. Correct this')
        disp(' problem in section 2')
        disp(' ================================================================');
        error('Please solve problem and try again');
end

% Put path entry on top of the path list (like the psycho phsyics toolbox)
addpath([SETUP.toolboxPath filesep 'IO' filesep 'Interface' num2str(interface)]);

% Save interface number to SETUP struct
SETUP.io.interfaceNum = interface;

%% Copy necessary dlls into working directory
% Check for windows and MATLAB systems only (SETUP.platformNum == 1)
foundHW = 0;
if(interface ~= 3 && SETUP.platformNum == 1)
    curDir = cd;
    switch interface
        case 1
            if(isempty(dir('iowkit.dll')))
                copyfile([SETUP.toolboxPath '\IO\Interface1\iowkit.dll'] , curDir);
                disp('Copied iowkit.dll (IO-WARRIOR 40) into the current working directory');
                foundHW = 1;
            end
        case 2
            if(isempty(dir('porttalk.sys')))
                copyfile([SETUP.toolboxPath '\IO\Interface2\porttalk.sys'] , curDir);
                disp('Copied porttalk.sys (PortTalk device driver) into the current working directory');
                disp('See http://www.beyondlogic.org/porttalk/porttalk.htm for more details.');
                foundHW = 1;
            end
        case 4
            if(isempty(dir('iowkit.dll')))
                copyfile([SETUP.toolboxPath '\IO\Interface4\iowkit.dll'] , curDir);
                disp('Copied iowkit.dll (FBI-Science) into the current working directory');
                foundHW = 1;
            end
        case 5
            if(isempty(dir('iowkit.dll')))
                copyfile([SETUP.toolboxPath '\IO\Interface5\iowkit.dll'] , curDir);
                disp('Copied iowkit.dll (WARRIOR-IO-BOX) into the current working directory');
                foundHW = 1;
            end
    end
end

% Check for all systems (Windows and MATLAB/Octave and Raspberry), if we
% haven't found something yet
if(interface ~= 3 && foundHW == 0)
    switch interface
        case 7
            SETUP.networkDIO.initDone   = 0;
        case 8
            SETUP.networkDIO.initDone   = 0;
        case 9
            SETUP.raspberryPi2.initDone	= 0;
        case 10
            SETUP.networkDIO.initDone   = 0;
    end
end

%% Remap pin numbers to names for keyboard use during programming
SETUP.io.remapNames = []; % Struct where the names are stored

% Copy field names and delete unnecessary names
names                                   = fieldnames(SETUP.io);
names(strcmpi(names,'inputKeys'))       = [];
names(strcmpi(names,'remapNames'))      = [];
names(strcmpi(names,'interface'))       = [];
names(strcmpi(names,'feederType'))      = [];
names(strcmpi(names,'interfaceNum'))	= [];
counter                                 = 1;

for i=1:length(names)
    if(~isempty(SETUP.io.(names{i})) && ~ischar(SETUP.io.(names{i})))
        len = length(SETUP.io.(names{i}));
        for j=1:len
            if(SETUP.io.(names{i}) > 0)
                SETUP.io.remapNames{1,SETUP.io.(names{i})(j)} = names{i};
                counter = counter + 1;
            else
                disp(' ================================================================');
                disp([' The value entered in SETUP.io.' names{i} ' is not valid !!!']);
                disp(' Please enter values bigger than zero or an empty matrix []');
                disp(' if no device is attached. See mySetup.m for details');
                disp(' ================================================================');
                error('Please solve problem and try again');
            end
        end
    end
end

%% Init timer (WINDOW only)
if(SETUP.platformNum == 1)
    %% Init timer for manual shaping
    if(SETUP.manualShaping.status == 1)
        disp(' ================================================================');
        disp('               !!! Manual shaping mode is used !!!');
        disp('            Please call closeWindow to stop manual shaping.');
        disp(' ================================================================');
        
        SETUP.manualShaping.reward  = 0;
        SETUP.manualShaping.timer   = timer('TimerFcn','callback_manualShaping', ...
            'BusyMode','Queue', ...
            'Period',0.1 , ...
            'ExecutionMode','fixedSpacing');
        start(SETUP.manualShaping.timer);
    end
end

%% Add entry in struct for startStopDevice timers
% Let's start with 32 entries. If someone needs more it's added
% automatically. This is done here only for performance reasons
SETUP.startStop.startStopTimer         = [];
SETUP.startStop.startStopTimerIndex    = zeros(1,32);

%% Init sound
% If enabled initialize the psych toolbox sound
if(SETUP.sound.enable == 1)
    disp(' --> Initializing PsychToolbox Sound ...');
    % Basic initialization of the sound driver
    InitializePsychSound;
    
    % Delete handles if exist
    closeSound;
    
    % Init audio!
    initSound;
    
    % Start from scratch
    SETUP.sound.handles = -1*ones(1,32);
end

%% Init UDP viewer
% open udp communication with control pc
if isfield(SETUP,'udp') && ~isempty(SETUP.udp.ip)
    SETUP.udp.obj = udp(SETUP.udp.ip, SETUP.udp.port, ...
        'localport', SETUP.udp.lclPort);
    fopen(SETUP.udp.obj);
end

%% Init memory mapped file
% create memory mapped file(s) for gaze-tracker start the tracker(s)
if ~isempty(SETUP.tracker.bufFleNme)
    for i=1:length(SETUP.tracker.bufFleNme)
        % create the memory mapped file for data exchange
        if ~exist(SETUP.tracker.bufFleNme{i},'file')
            f = fopen(SETUP.tracker.bufFleNme{i},'w+');
            fwrite(f,[0 0 0 0 0],'double');
            fclose(f);
        end
        % map file to memeoy
        SETUP.tracker.bufFle{i} = ...
            memmapfile(SETUP.tracker.bufFleNme{i},'Format','double');
        %         % start each tracker on a separate worker
        %         SETUP.tracker.job{i} = batch(@startPointGrey,0,...
        %             {SETUP.tracker.cfgFleNme{i},SETUP.tracker.bufFleNme{i}});
    end
end

%% Init naming scheme for keyboard answers
if(strcmpi(SETUP.io.interface, 'Keyboard'))
    disp(' --> Init naming scheme for keyboard answers ...');
    KbName('UnifyKeyNames');
    disp('                                                   done!');
end

%% Clear needless variables
clear names counter bioPath i j needless pos startPos interface curDir len
clear tmp k ans year tmp2 tmp1 pc psychPath foundHW

%% Done
disp('                 ... done');
