function dict = genDictionary(imSize, blkSize, blkNum)
	temp = imSize(1) / blkSize(1);
	blkTot = prod(imSize) / prod(blkSize);
	blkIdx = randperm(blkTot);

	for i = 1:blkNum
		zeroMetric = zeros(imSize);
		r = floor(blkIdx(i) / temp);
		c = blkIdx(i) - r * temp;

		if c == 0
			zeroMetric(blkSize(1) * (r - 1) + 1:blkSize(1) * r, imSize(2) - blkSize(1) + 1:imSize(2)) = 1;
		else
			zeroMetric(blkSize(1) * r + 1:blkSize(1) * (r + 1), blkSize(1) * (c - 1) + 1:blkSize(1) * c) = 1;
		end

		dict.square(:, i) = reshape(zeroMetric, prod(imSize), 1);
	end

	dict.track = vision.PointTracker;