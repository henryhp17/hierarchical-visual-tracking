function [param, opt] = trackerL2(frame, tmpl, param, opt, P, dict)
	num = opt.numsample;
	sz = size(tmpl.mean);
	N = sz(1) * sz(2);
	
	%% 1 -> Coarse search
	%% 2 -> Fine search
	for i = 1:2
		%% Generate particles for the Bayesian inference framework
		param.param = repmat(affparam2geom(param.est(:)), [1, num]);
		randMatrix = randn(6, num);
		param.param = param.param + randMatrix .* repmat(opt.affsig(:) ./ (i ^ 2), [1, num]);
		wimgs = warpimg(frame, affparam2mat(param.param), sz);
		
		dif = repmat(tmpl.mean(:), [1, num]) - reshape(wimgs, [N, num]);
		errTh = 0.05;

		%% Compute the maximum likelihood function using L2-RLS
		if size(tmpl.basis, 2) > 0
			if size(tmpl.basis, 2) == opt.maxbasis
				alpha = zeros(size(P, 1), num);
				alpha = P * dif;
				coeff = alpha(1:size(tmpl.basis, 2), :);

				alphaOcc = alpha(size(tmpl.basis, 2) + 1:end, :);
				err = dict.square * alphaOcc(1:size(dict.square, 2), :);
				dif = dif - tmpl.basis * coeff - err;
				dif = dif .* (abs(err) < errTh);

				param.conf = exp(-(sum(dif .^ 2) + 0.05 * sum(abs(err))) ./ 0.1)';
			else
				coeff = tmpl.basis' * dif;
				dif = dif - tmpl.basis * coeff;

				param.conf = exp(-sum(dif .^ 2) ./ opt.condenssig)';
			end
		else
			param.conf = exp(-sum(dif .^ 2) ./ opt.condenssig)';
		end
		param.conf = param.conf ./ sum(param.conf);
		param.likelihood = zeros(5, 4);

		%% Start the Harris corner features extraction
		kp = detectHarrisFeatures(tmpl.mean);
		dict.kpoint = kp.Location;
		%% Compute the similarity for top 5 particles
		for j = 1:5
			[maxProb, maxIdx] = max(param.conf);
			param.conf(maxIdx) = 0;
			param.likelihood(j, 4) = maxIdx;
			param.likelihood(j, 3) = maxProb;

			release(dict.track);
			initialize(dict.track, dict.kpoint, tmpl.mean);
			wimg = wimgs(:, :, maxIdx);
			[curPoints, isFound] = step(dict.track, wimg);
			cur = curPoints(isFound, :);
			prev = dict.kpoint(isFound, :);

			dist = mean(abs(cur - prev), 1);
			param.likelihood(j, 2) = size(cur, 1) / sqrt(dist(1) ^ 2 + dist(2) ^ 2);
		end

		%% Perform particle filter
		param.likelihood(:, 2) = param.likelihood(:, 2) ./ sum(param.likelihood(:, 2));
		param.likelihood(:, 1) = param.likelihood(:, 2) + param.likelihood(:, 3);
		[maxProb, maxTotal] = max(param.likelihood(:, 1));
		maxIdx = param.likelihood(maxTotal, 4);

		param.est = affparam2mat(param.param(:, maxIdx));
	end

	%% Update tracker according to the occlusion ratio
	if size(tmpl.basis, 2) == opt.maxbasis
		alphaOcc = abs(alpha(size(tmpl.basis, 2) + 1:end, maxIdx));
		occ = dict.square * alphaOcc(1:size(dict.square, 2));
		occ = 255 * abs(occ);

		errRatio = sum(occ > errTh * 255) / length(occ);
		opt.occMatrix = [opt.occMatrix, occ];
		opt.errRatio = [opt.errRatio, errRatio];

		wimg = wimgs(:, :, maxIdx);
		if errRatio < opt.threshold.low 
			param.wimg = wimg;
		elseif errRatio > opt.threshold.high & maxProb < 0.4
			param.wimg = zeros(opt.tmplsize(1), opt.tmplsize(2));
		else
			param.wimg = (1 - (occ > errTh * 255)) .* wimg(:) + (occ > errTh * 255) .* tmpl.mean(:);
			param.wimg = reshape(param.wimg, size(wimg));
		end
	else
		param.wimg = wimgs(:, :, maxIdx);
	end

	%% Get the particle with maximum likelihood for Long-lifespan dictionary
	if (maxProb > param.prob) & (param.wimg ~= zeros(opt.tmplsize(1), opt.tmplsize(2)));
		param.prob = maxProb;
		param.temp = wimg;
	end