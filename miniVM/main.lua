function love.load()
    -- 指令集
	InstructionSet = {"PSH","ADD","POP","SET","HLT"}
	Register = {A, B, C, D, E, F,NUM_OF_REGISTERS}

	--	测试程序代码
	program = {"PSH", "5", "PSH", "6", "ADD", "POP", "HLT"}

	-- 指令指针, 栈顶指针, 栈数组
	IP = 1
	SP = 0
	stack = {}
	
	running = true
end

function love.update(dt)
    -- 虚拟机主体
	if running then
		eval(fetch())
		IP = IP + 1
	end
end

function love.draw()
    love.graphics.print("Welcome to our miniVM!", 400, 300)
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

