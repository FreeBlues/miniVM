-- 项目名称: miniVM
-- 项目描述: 用 Lua 实现的一个基于栈的微型虚拟机
-- 项目地址: https://github.com/FreeBlues/miniVM
-- 项目作者: FreeBlues

function love.load()
    -- 指令集
    InstructionSet = {"PSH", "ADD", "POP", "SET", "HLT"}
    Register = {A, B, C, D, E, F, NUM_OF_REGISTERS}

    -- 测试程序代码
    program = {"PSH", "5", "PSH", "6", "ADD", "POP", "HLT"}

    -- 指令指针, 栈顶指针, 栈数组
    IP = 1
    SP = 0
    stack = {0, 0, 0, 0, 0}

    running = true
    step = false
end

function love.keyreleased(key)
    if key == "s" then
        step = true
    end

    if key == "q" then
        love.event.quit(0)
    end

    if key == "r" then
        love.event.quit("restart")
    end

end


function love.update(dt)
    -- 虚拟机主体
    if running then
        if step then
            step = false
            eval(fetch())
            IP = IP + 1
        end
    end
end

function love.draw()
    love.graphics.print("Welcome to our miniVM!\n\n's': step\n'r': reload\n'q': quit", 300, 100)
    drawMemory()
    drawStack()
end


-- 取指令函数
function fetch()
    return program[IP]
end

-- 求值函数
function eval(instr)
    if instr == "HLT" then
        running = false
    elseif instr == "PSH" then
        -- 这里处理 PSH 指令, 具体处理如下
        SP = SP + 1
        -- 指令指针跳到下一个, 取得 PSH 的操作数
        IP = IP + 1
        stack[SP] = program[IP]
    elseif instr == "POP" then
        -- 这里处理 POP 指令, 具体处理后面添加
        local val_popped = stack[SP]
        SP = SP - 1
    elseif instr == "ADD" then
        -- 这里处理 ADD 指令, 具体处理如下
        -- 先从栈中弹出一个值
        local a = stack[SP]
        stack[SP] = 0
        SP = SP - 1

        -- 再从栈中弹出一个值
        local b = stack[SP]
        stack[SP] = 0
        SP = SP - 1

        -- 把两个值相加
        local result = a + b

           -- 把相加结果压入栈中
        SP = SP + 1
        stack[SP] = result

        -- 为方便查看测试程序运行结果, 这里增加一条打印语句
        print(stack[SP])
    end
end

-- 绘制存储器中指令代码的变化
function drawMemory()
    local x,y = 500, 300
    local w,h = 60, 20
    for k,v in ipairs(program) do
        -- 绘制存储器右侧矩形地址
        love.graphics.setColor(0, 255, 50)
        love.graphics.rectangle("line", x, y+(k-1)*h, w, h)

        -- 绘制存储器中要执行的指令代码
        love.graphics.setColor(200, 100, 100)
        love.graphics.print(v, x+15,y+(k-1)*h+5)

        -- 绘制存储器左侧矩形
        love.graphics.setColor(0, 255, 50)
         love.graphics.rectangle("line", x-w/3-10,y+(k-1)*h,w/3+10, h)

         -- 绘制表示存储器地址的数字序号
        love.graphics.setColor(200, 100, 100)
        love.graphics.print(k,x-w/3-10+10,y+(k-1)*h+5)

        -- 绘制指令指针 IP
        love.graphics.setColor(255, 10, 10)
        love.graphics.print("IP".."["..IP.."] ->",x-w-10+10-20,y+(IP-1)*h+5)
   end
end


-- 绘制栈的变化
function drawStack()
    local x,y = 300, 300
    local w,h = 60, 20
    for k,v in ipairs(stack) do
        -- 显示栈右侧矩形
        love.graphics.setColor(0, 255, 50)
        love.graphics.rectangle("line", x,y+(k-1)*h,w, h)

       -- 绘制被压入栈内的值
        love.graphics.setColor(200, 100, 100)
        love.graphics.print(v, x+10,y+(k-1)*h+5)


       -- 绘制栈左侧矩形
        love.graphics.setColor(0, 255, 50)
        love.graphics.rectangle("line", x-w/3-10,y+(k-1)*h,w/3+10, h)

        -- 绘制表示栈地址的数字序号
        love.graphics.setColor(200, 100, 100)
        love.graphics.print(k,x-w/3-10+10,y+(k-1)*h+5)


        -- 绘制栈顶指针 SP
        love.graphics.setColor(255, 10, 10)
        love.graphics.print("SP".."["..SP.."] ->",x-w-10+10-25,y+(SP-1)*h+5)
    end
end
