# miniVM

A mini virtual machine written by lua

## Instructions

```
op   val    usage               function
---------------------------------------------------------------------
HLT  0      hlt                 halts program
PSH  1      psh val             pushes <val> to stack
POP  2      pop                 pops value from stack
ADD  3      add                 adds top two vals on stack
```

## Visual

Use [Love2D](https://love2d.org) for the visual.

The sceenshot:

![](./pic/p05.png)
![](./pic/p06.png)
![](./pic/p07.png)
![](./pic/p08.png)
![](./pic/p09.png)

BLOG [用 Lua 实现一个微型虚拟机-基本篇](https://github.com/FreeBlues/miniVM/blob/master/用%20Lua%20实现一个微型虚拟机-基本篇.md)

## Reference 

From this project [MAC](https://github.com/felixangell/mac)
