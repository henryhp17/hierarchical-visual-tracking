function mouse = mouseDown(fig, mouse)
    cur = get(fig, 'CurrentPoint');
    mouse.left = cur(1, 1);
    mouse.top = cur(1, 2);