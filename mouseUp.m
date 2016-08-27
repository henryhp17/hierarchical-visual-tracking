function [mouse, param0, pos] = mouseUp(fig, mouse)
    cur = get(fig, 'CurrentPoint');
    mouse.right = cur(1, 1);
    mouse.bottom = cur(1, 2);
    
    pos(1) = (mouse.right + mouse.left) / 2; 
    pos(2) = (mouse.bottom + mouse.top) / 2;
    pos(3) = mouse.right - mouse.left;
    pos(4) = mouse.bottom - mouse.top;
    pos(5) = 0;

    param0 = [pos(1), pos(2), pos(3) / 32, pos(5), pos(4) / pos(3), 0];
	param0 = affparam2mat(param0);