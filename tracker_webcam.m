%% Henry Pratama Suryadi
%% National University of Singapore
%% Final Year Project 2015-2016

clc;
addpath('../Datasets');
addpath('./Functions');

close all;
rand('state', 0); randn('state',0); 

%% Set parameters for the tracking
[pos, opt, startFrame, title] = initParam(0);
cam = webcam();
curFrame = snapshot(cam);

%% Set event handler and display parameters
mouse.left = 0;
mouse.top = 0;
mouse.bottom = 0;
mouse.right = 0;
[width height dim] = size(curFrame);
color = [1 0 0];
figure('position',[100 100 width height]); 
set(gcf,'DoubleBuffer','on','MenuBar','none');
set(gcf,'WindowButtonDownFcn', 'mouse = mouseDown(gca, mouse);');
set(gcf,'WindowButtonUpFcn', '[mouse, param0, pos] = mouseUp(gca, mouse);');
runLoop = false;

%% Get which object need to be tracked
while ~runLoop
	curFrame = snapshot(cam);
	imshow(curFrame);
	hold on;
	if sum(pos ~= 0) 
		%% Get parameters for the first frame
		param0 = [pos(1), pos(2), pos(3) / opt.tmplsize(1), pos(5), pos(4) / pos(3), 0];
		param0 = affparam2mat(param0);

		drawbox2([32 32], param0, 'Color', color, 'LineWidth', 2.5);
		hold off;
		drawnow;
	end

	key = get(gcf, 'CurrentCharacter');
	if key == 'z' & sum(pos ~= 0)
		runLoop = true;
	end
end

if dim == 3
	grayFrame = double(rgb2gray(curFrame)) / 255;
else
	grayFrame = double(curFrame) / 255;
end

%% Generate variables and square templates
wimgs = [];
wimgs_old = [];
result = [];
P = [];
lambda = 5e-6;

[param, tmpl] = firstFrame(grayFrame, param0, opt.tmplsize);
sz = size(tmpl.mean);
dict = genDictionary(sz, opt.blockSizeSmall, opt.blockNumSmall);

%% Start tracking
while runLoop
	curFrame = snapshot(cam);
	if size(curFrame, 3) == 3
		grayFrame = double(rgb2gray(curFrame)) / 255;
	else
		grayFrame = double(curFrame) / 255;
	end

	%% Perform L2 tracking algorithm
	[param, opt] = trackerL2(grayFrame, tmpl, param, opt, P, dict);
	if param.wimg ~= zeros(opt.tmplsize(1), opt.tmplsize(2));
		wimgs = [wimgs, param.wimg(:)];
	end

	%% Update tracker with the latest data
	if size(wimgs, 2) >= opt.batchsize
		%% Short-lifespan dictionary update
		[tmpl.basis, tmpl.eigval, tmpl.mean, tmpl.numsample] = ...
			sklm(wimgs, tmpl.basis, tmpl.eigval, tmpl.mean, tmpl.numsample, opt.ff);
		wimgs = [];
		wimgs_old = [wimgs_old, param.temp(:)];
		param.prob = 0;
		
		%% Long-lifespan dictionary update
		if size(wimgs_old, 2) >= opt.batchsize
			[tmpl.basis, tmpl.eigval, tmpl.mean, tmpl.numsample] = ...
				sklm(wimgs_old, tmpl.basis, tmpl.eigval, tmpl.mean, tmpl.numsample, opt.ff);
			wimgs_old = [];
		end

		%% Abandon unnecessary PCA basis templates, compute P of dictionary
		if size(tmpl.basis, 2) > opt.maxbasis
			tmpl.basis = tmpl.basis(:, 1:opt.maxbasis);
			tmpl.eigval = tmpl.eigval(1:opt.maxbasis);
		end
		D = [tmpl.basis, dict.square];
		P = inv(D' * D + lambda * eye(size(D, 2))) * D';
	end

	%% Show tracking result
	imshow(curFrame);
	hold on;
	drawbox2([32 32], param.est, 'Color', color, 'LineWidth', 2.5);
	hold off;
	drawnow;
	
	%% Check if still need to continue tracking
	key = get(gcf, 'CurrentCharacter');
	if key == 'x'
		runLoop = false;
	end
end

release(dict.track);
close all;
clear all;