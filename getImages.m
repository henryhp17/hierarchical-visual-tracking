clear all;
close all;
addpath('./Functions');

title = 'test2';
cam = webcam();

mouse.left = 0;
mouse.top = 0;
mouse.bottom = 0;
mouse.right = 0;
color = [1 0 0];

figure('position',[100 100 640 480]); 
set(gcf,'DoubleBuffer','on','MenuBar','none');
set(gcf,'WindowButtonDownFcn', 'mouse = mouseDown(gca, mouse);');
set(gcf,'WindowButtonUpFcn', '[mouse, param0, pos] = mouseUp(gca, mouse);');

pos = [0 0 0 0 0];
loop = false;
while ~loop
	img = snapshot(cam);
	imshow(img);
	hold on;

	if sum(pos ~= 0)
		param0 = [pos(1), pos(2), pos(3) / 32, pos(5), pos(4) / pos(3), 0];
		param0 = affparam2mat(param0);

		drawbox2([32 32], param0, 'Color', color, 'LineWidth', 2.5);
		hold off;
		drawnow;
	end

	key = get(gcf, 'CurrentCharacter');
	if key == 'z' & sum(pos ~= 0)
		loop = true;
	end
end

dataPath = ['../Datasets/' title '/img/'];
mkdir(dataPath);
for i = 1:750
	img = snapshot(cam);
	name = sprintf('%04d.jpg', i);
	imwrite(img, [dataPath name]);
	imshow(img);
	hold on;
	numStr = sprintf('#%03d', i);
	text(10, 20, numStr, 'Color', 'r', 'FontWeight', 'bold', 'FontSize', 20);
	hold off;
	drawnow;
end

startPos = ['../Datasets/' title '/' title '.txt'];
fid = fopen(startPos, 'w+');
fprintf(fid, '%.0f ', pos);
fclose(fid);

close all;
clear all;