function [p, opt, startFrame, title] = initParam(data_id)
%% 
%% 'p = [px py sx sy theta]'
%% the location of the target in the first frame
%%
%% px py are the coordinates of the center of the box
%% sx sy are the size of the box, width and height
%%
%% theta is the rotation angle of the box
%%
%% 'affsig'
%% these are the standard deviations of the dynamics distribution, and 
%% it controls the scale, size and area to sample the candidates.
%% affsig(1) = x translation (pixels, mean is 0)
%% affsig(2) = y translation (pixels, mean is 0)
%% affsig(3) = x & y scaling
%% affsig(4) = rotation angle
%% affsig(5) = aspect ratio
%% affsig(6) = skew angle
	opt = struct('numsample', 150, 'condenssig', 0.25, 'ff', 1, 'batchsize', 5, ...
		'tmplsize', [32 32], 'maxbasis', 16);

	switch data_id
	
	case 1
		p = [215 255 34 81 0];
		opt.affsig = [5 5 .001 .001 .0001 .0001];
		title = 'Basketball';
		
	case 2
		p = [305.5 164 35 42 0];
		opt.affsig = [10,10,.001,.000,.0001,.0001];
        title = 'Boy';
		   
	case 3
		p = [124 95 107 87 0];
		opt.affsig = [2.5,2.5,.025,.0,.00,.000];
		title = 'Car4';
		
	case 4
		p = [88 138 29 23 0];
		opt.affsig = [2,2,.01,.00,.0005,.0005];    
		title = 'CarDark';
		
	case 5
		p = [162 216 50 140 0];
		opt.affsig = [3,3,.01,.00,.001,.0000];
		title = 'Caviar';
		
	case 6
		p = [161 119 64 78 0];
		opt.affsig = [3.5,3.5,.025,.002,.003,.0005];
		title = 'David';
	
	case 7
		p = [350 40 100 70 0];
		opt.affsig = [17,17,.0005,.001,.0001,.0001];
 		title = 'Deer';

	case 8
		p = [188 116 56 65 0];
		opt.affsig = [15,15,.001,.0005,.0001,.0001];
 		title = 'DragonBaby';
	
	case 9
		p = [189 175 132 176 0];
		opt.affsig = [4,4,.03,.005,.0001,.0001];
 		title = 'Dudek';
		
	case 10
		p = [175 150 114 162 0];
		opt.affsig = [2.5,2.5,.00,.000,.00,.000];   
    	title = 'FaceOcc1';
		
    case 11
    	p = [156 107 74 100 0];
    	opt.affsig = [3,3,.001,.025,.0002,.0001];
        title = 'FaceOcc2';
		
    case 12
		p = [73 44 31 45 0];
		opt.affsig = [2,2,.002,.02,.000,.000];
    	title = 'Girl';
		
    case 13
    	p = [164 126 34 33 0];
    	opt.affsig = [16,16,.000,.000,.000,.00];
        title = 'Jumping';
		
    case 14
    	p = [293 257 73 210 0];
    	opt.affsig = [15,15,.05,.003,.000,.00];
        title = 'Liquor';
		
	case 15
		p = [72 112 28 23 0];
		opt.affsig = [4,4,.001,.001,.001,.0000];
        title = 'Panda';
		
	case 16
		p = [256 170 61 71 0];
		opt.affsig = [1,1,.0005,.0001,.0001,.0001];
		title = 'Shaking';
		
	case 17
		p = [94 198 87 290 0];
		opt.affsig = [2,2,.01,.0005,.0005,.0001];
        title = 'Singer1';
		
	case 18
		p = [148 82 51 61 0];
		opt.affsig = [2.2,2.2,.02,.005,.003,.0001];       
		title = 'Sylvester';
		
	case 19
		p = [180 105 68 101 0];
		opt.affsig = [5,5,.01,0.01,0.0005,0.000];
		title = 'Trellis';
		
	case 20
		p = [146 190 31 115 0];
		opt.affsig = [2,2,.01,0.003,0.0005,0.000];
		title = 'Walking2';

	%% For webcam settings
	case 0
		p = [0 0 0 0 0];
		opt.affsig = [6,6,.03,.03,.0001,.0001];
		title = 'Webcam';
	case 21
		p = [252 269 159 193 0];
		opt.affsig = [3,3,.03,.025,.0001,.0001];
		title = 'test1';
	case 22
		p = [339 264 63 244 0];
		opt.affsig = [3,3,.03,.025,.0001,.0001];
		title = 'test2';
	otherwise
		error(['unknown title' title]);
	end

	opt.title = title;
	opt.errRatio = [];
	opt.occMatrix = [];

	opt.blockSizeSmall = [2 2];
	opt.blockNumSmall = 256;

	opt.threshold.high = 0.6;
	opt.threshold.low = 0.1;

	if data_id == 6
		startFrame = 300;
	else
		startFrame = 1;
	end