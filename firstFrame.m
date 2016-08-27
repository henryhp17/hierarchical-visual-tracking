function [param, tmpl] = firstFrame(frame, param0, tmplsize)
	tmpl.mean = warpimg(frame, param0, tmplsize);
	tmpl.basis = [];
	tmpl.eigval = [];
	tmpl.numsample = 0;

	param = [];
	param.est = param0;
	param.wimg = tmpl.mean;
	param.prob = 0;