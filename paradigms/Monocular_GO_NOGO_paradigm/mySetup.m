function mySetup

% function [] = mySetup()
%
% This function initializes the Biopsy Toolbox and sets all basic parameters
% of the setup in use. This function needs to be stored on each
% experimental computer. All required hardware definitions are stored in
% the global variable SETUP created by this function. Edit this function when
% building a new setup. Description of specific field names and values can
% be found in the function..
%
% INPUTS
%
% INPUTS-OPTIONAL
%
% OUTPUTS
%
% EXAMPLES
%
% Copyright 2007-2010
% CC-GNU GPL by attribution
% Please cite the BioPsychology Toolbox where this function is used.
%       http://sourceforge.net/projects/biopsytoolbox/
%
% See also:  start

% VERSION HISTORY:
% Author:         Tobias Otto, Jonas Rose
% Version:        1.3
% Last Change:    01.03.2018
%
% 14.06.2017, Tobias: release version for Biopsy Toolbox 2
% 21.06.2017, Tobias: added IO support for Raspberry Pi 2
% 06.11.2017, Tobias: added Jonas udp viewer and memory mapped files
% 01.03.2018, Tobias: added manual shaping mode

%% BUGS/ TODO
% - publish in nature

% TODO:
% * double check comments!

global SETUP

%% (1a) Please enter path to the BiopsyToolbox folder
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SETUP.toolboxPath = [getenv('USERPROFILE') '\Documents\MATLAB\IKNToolbox'];

%% (1b) Please enter path to the Psychophysics Toolbox folder
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SETUP.psychToolboxPath  = [getenv('USERPROFILE') '\Documents\MATLAB\PsychToolbox3Orig_GitHub_Release'];

%% (1c) Please specify platform
% This version of the Biopsy Toolbox supports these platforms:
% 'Windows64Bit'    --> Computer with a 64 bit Windows operating system
%                       installed  and a 64 bit MATLAB
% 'RaspberryPi2'     --> Raspberry Pi with Octave
SETUP.platform = 'Windows64Bit';

%% (2) Please choose the IO device
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The BiopsyToolbox provides nativ access to two different IO devices: the
% IO-Warrior 40 and a self made parallel port Interface. Please choose the
% interface you want to use.
% For training purposes the keyboard can be used as well.
% 'IOWarrior'    -> Grants access to the IO-Warrior 40 (WINDOWS ONLY)
% 'Parallel'     -> Grants access to the self made parallel port interface (WINDOWS ONLY)
% 'WarriorBox'   -> Grants access to the self made IO-Warrior interface (WINDOWS ONLY)
% 'FBIScience'   -> Grants access to the FBI-Science IO device (WINDOWS ONLY)
% 'NetworkBox'   -> Grants access to the Odroid network IO device (Biopsychology)
% 'NetworkBoxACN'-> Grants access to the Odroid network IO device (ACN)
% 'Keyboard'     -> For testing your program in your office using the keyboard
% 'RaspberryPi2' -> Grants access to the IO pins of the Raspberry 2
SETUP.io.interface = 'NetworkBox';

% Add IP address of NetworkBox as string here. E.g. '192.168.0.1'
% Otherwise leave this field empty!
SETUP.networkDIO.odroidIP   = '192.168.0.12';

%% (3a) Please specify the OUTPUT devices
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Each device is connected to a separate pin/output at the output device.
% Please specify the pin numbers for the devices used in the setup. Unused
% outputs should contain an empty matrix.
SETUP.io.houseLight  = 1;
SETUP.io.feeder      = 3;
SETUP.io.feederLight = [];
SETUP.io.feederPower = 5;
SETUP.io.punishment  = [];
%% (3b) Please specify the feeder
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This section defines if the amount of food given to a subject is defined
% in time (seconds) or in amount of food (e.g. number of pallets)
% Define time in seconds    --> 'time'
% Define time in amount     --> 'amount'
SETUP.io.feederType     = 'time';

% Manual shaping (WINDOWS ONLY)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set this value to one, if you want to manually reward by pressing the 'f'
SETUP.manualShaping.status = 0;

%% (4) Please specify the number(s) of the INPUT pins
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Each input device (e.g. real switch or pecking key)
% must be specified here. Physicsal switches are connected to a single
% pin/input to the IO device. Please be aware that the first pin number
% corresponds to the first input key (doesn't matter on which input pin the
% key is connected). That means that the first response key could be
% connected to pin 7 and the second response key to pin 3. That would
% result in [7 3].
SETUP.io.inputKeys     = [1 2 3];

%% (5) Please specify monitor dimensions
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Screen width and hight in centimeters
SETUP.screen.ScreenWidth      = 20;
SETUP.screen.ScreenHeight     = 18;

%% (6) Switch/Image positions in centimeters
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Specify the position of the left lower corner of the switch with
% reference to the left lower corner of the screen.
% REMEMBER for the TOUCH SCREEN that the first number entered in the
% following vectors corresponds to index 1 in the keyBuffer output. The
% second value to index 2 and so on. But only for touchscreens!
SETUP.screen.X        = [1, 8.5, 12];
SETUP.screen.Y        = [16, 6, 16];

%% (7) Width and height of the switches/ images in centimeters
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Specify the width and height of the switches in centimeters
SETUP.screen.width    = [5, 5, 5];
SETUP.screen.height   = [7, 7, 7];
%% (8) TOUCH SCREEN SETTINGS (WINDOWS ONLY)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set this value to one, if you want to use a touch screen
SETUP.touchScreen.on = 0;

% Set to one to plot a red dot to the recognised touch location
% Not recommended during experiments!
SETUP.touchScreen.display = 1;

% Enter minimum time between two touches (in seconds)
SETUP.touchScreen.deltaT = 0.005;

% Enter minimum distance between two touches (in centimeters)
% After call of initWindow the relative value is computed and replaced
SETUP.touchScreen.deltaP = 10;

%% (9) Background color
% Change to background color from black to any another color using short
% names (pre defined in MATLAB) or a RGB triplet ranged from 0 to 1
%
% [1 1 0] --> yellow
% [1 0 1] --> magenta
% [0 1 1] --> cyan
% [1 0 0] --> red
% [0 1 0] --> green
% [0 0 1] --> blue
% [1 1 1] --> white
% [0 0 0] --> black
%
% or anything between zero and one ...
SETUP.screen.bgColor = [0 0 0];

%% (10) Transparency
% Set this value to 1, if you want to enable transparency for your stimuli.
% This is a global setting and transparency has to be enabled for each
% stimulus individually during call of showStimuli
SETUP.screen.transparency = 1;

%% (12) Sound support
% %%%%%%%%%%%%%%%%%%%
% Set this value to one to enable sound support. This should always be the
% case, because some functions use sound options. If this is disabled the
% keyBuffer will not work with the optional argument 'sound' and an error
% occurs.
SETUP.sound.enable = 0;

% % Define the playback frequency for the sound files. The frequency must
% % match with the frequency the files are recorded with. Otherwise playback
% % is a bit out of tune.
% % Common frequencies are: 44100, 32000, 22050, 16000, 11025, 8000
% SETUP.sound.freq = 8000;
%
% % Define the number of channels for audio playback
% % (1 -> mono or 2 -> stereo)
% % Default is okay, if a mono file is loaded, the loadSound function will
% % duplicate the file to get an stereo playback.
% SETUP.sound.chan = 2;

%% (13) Set Psych toolbox verbosity
% Set the verbosity of the psychophysics toolbox
% 0 - Disable all output - Same as using the SuppressAllWarnings flag.
% 1 - Only output critical errors.
% 2 - Output warnings as well.
% 3 - Output startup information and a bit of additional information.
%     This is the default.
% 4 - Be pretty verbose about information and hints to optimize your code
%     and system.
% 5 - Levels 5 and higher enable very verbose debugging output, mostly
%     useful for debugging PTB itself, not generally useful for end-users.
%
% For normal use 1 is fine!
SETUP.psychToolbox.verbosity = 3;

%% (14) UDP communication for remote status display
% contact deteails of the remote listener
SETUP.udp.ip        = [];'192.168.2.1';    % remote ip
SETUP.udp.port      = 5006;             % remote port
SETUP.udp.lclPort   = 5005;             % local port

%% (15) Image to be used as negative feedback
% If specified the given image will be shown during punishment!
% Specify the path to the image as string or leave empty otherwise!
% Image position is full screen by default: [0 0 1 1]
SETUP.punishment.img 	= [];
SETUP.punsiment.imgPos	= [0 0 1 1]; %[left, bottom, width, height] figure coordinate

%% (16) UDP communication with odroid DIO interface
% ---> These entries are now in openNetworkIO (no changes needed anyway)

%% (17) memory mapped file(s) for gaze tracker
% ---> more information needed
SETUP.tracker.bufFleNme = {};   	% match fileNames in videoTracker.m
SETUP.tracker.cfgFleNme = {};       % configuration file of tracker
SETUP.tracker.bufFle    = {};    	% generate it using tracker.preview
SETUP.tracker.frameRate = 150;

%% (18) EPHYS SETTINGS
% %%%%%%%%%%%%%%%%%%%%
% Enter values for the white bar at the top of the screen.  This is useful
% to get the exact timing when the stimulus was presented on the monitor.
% The coordinates are entered with reference to the left lower corner of
% the screen.
% The values are entered in centimeter and have the following meaning:
% 1. left lower corner, X coordinate
% 2. left lower corner, Y coordinate
% 3. width of bar
% 4. height of bar
%
% Defaults should be okay!

% White bar at the top of the screen, stretched over the whole screen
%[left, bottom, width, height]
SETUP.ephys.photodiode = [0, SETUP.screen.ScreenHeight-2, SETUP.screen.ScreenWidth, SETUP.screen.ScreenHeight];

%% (19) Raspberry 2B SETTINGS
% %%%%%%%%%%%%%%%%%%%%%%%%%%%
% Enter the IP addresses of your Raspberry 2B as string systems here. 
% The order of the IP addresses is important, because the systems that is
% entered first is known as system one, the second system entered is known
% as system two, ...
% e.g. SETUP.raspberry.ip{1} = '192.168.0.20';
% e.g. SETUP.raspberry.ip{2} = '192.168.0.21';
SETUP.raspberry.ip{1} = [];
