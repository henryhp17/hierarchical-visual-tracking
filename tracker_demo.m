%% Henry Pratama Suryadi
%% National University of Singapore
%% Final Year Project 2015-2016

clc;
addpath('../Datasets');
addpath('./Functions');

%% Datasets initialization
numData = 1;
startSet = 15;

for data_id = startSet:(startSet + numData - 1)
	close all;
	clearvars -except data_id numData startSet;
	rand('state', 0); randn('state',0); 
	t = 0;

	%% Set parameters for the tracking
	[pos, opt, startFrame, title] = initParam(data_id);
	dataPath = ['../Datasets/' title '/img/'];
	numFrames = length(dir(fullfile(dataPath, '*.jpg')));
	curFrame = imread([dataPath num2str(startFrame, '%04d') '.jpg']);

	[width height dim] = size(curFrame);
	color = [1 0 0];
	figure('Position',[100 100 width height]); 
	set(gcf,'DoubleBuffer','on','MenuBar','none');

	timerVal = tic;
	if dim == 3
		grayFrame = double(rgb2gray(curFrame)) / 255;
	else
		grayFrame = double(curFrame) / 255;
	end

	%% Get parameters for the first frame
	param0 = [pos(1), pos(2), pos(3) / opt.tmplsize(1), pos(5), pos(4) / pos(3), 0];
	param0 = affparam2mat(param0);

	%% Generate variables and square templates
	wimgs = [];
	wimgs_old = [];
	P = [];
	result = [];
	lambda = 5e-6;

	[param, tmpl] = firstFrame(grayFrame, param0, opt.tmplsize);
	sz = size(tmpl.mean);
	dict = genDictionary(sz, opt.blockSizeSmall, opt.blockNumSmall);
	t = toc(timerVal);

	%% Start tracking
	for f = startFrame:(startFrame + numFrames - 1)
		timerVal = tic;
		curFrame = imread([dataPath num2str(f, '%04d') '.jpg']);
		if size(curFrame, 3) == 3
			grayFrame = double(rgb2gray(curFrame)) / 255;
		else
			grayFrame = double(curFrame) / 255;
		end

		%% Perform L2 tracking algorithm
		opt.frameNum = f;
		[param, opt] = trackerL2(grayFrame, tmpl, param, opt, P, dict);
		result = [result, param.est];
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
		t = t + toc(timerVal);

		%% Show tracking result
		imshow(curFrame);
		hold on;
		numStr = sprintf('#%03d', f);
		text(10, 20, numStr, 'Color', 'r', 'FontWeight', 'bold', 'FontSize', 20);
		drawbox2([32 32], param.est, 'Color', color, 'LineWidth', 2.5);
		hold off;
		drawnow;
	end

	%% Evaluate the accuracy and speed of tracking result
	meanError = evalError(result, title, t);
end

release(dict.track);
close all;
clear all;