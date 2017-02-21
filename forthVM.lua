-- Forth VM

-- 求值函数
eval = function (str) return assert(load(str))() end

-- 语法解析, 把代码文本解析为一个个的字 word 和空格
parser = function (pat)
    local capture, newpos = string.match(subj, pat, pos)
    if newpos then pos = newpos; return capture end
  end
parseSpaces     = function () return parser("^([ \t]*)()") end
parseWord       = function () return parser("^([^ \t\n]+)()") end
parseNewline    = function () return parser("^(\n)()") end
parseRestOfLine = function () return parser("^([^\n]*)()") end
parseWordOrNewline = function () return parseWord() or parseNewline() end

-- 在 Forth 中, 一个字是一个非空字符序列, 外部解释器每次读取一个字然后执行它
getWord          = function () parseSpaces(); return parseWord() end
getWordOrNewline = function () parseSpaces(); return parseWordOrNewline() end


-- 栈和入栈,出栈函数的定义
DS = { n = 0 }
push = function (stack, x) stack.n = stack.n + 1; stack[stack.n] = x end
pop  = function (stack) local x = stack[stack.n]; stack[stack.n] = nil;
                          stack.n = stack.n - 1; return x end

-- 字典的定义, 这里暂时直接把 5 DUP * . 每个字都当做原语来定义
_F = {}
_F["\n"] = function () end
_F[""]   = function () mode = "stop" end
_F["5"]   = function () push(DS, 5) end
_F["DUP"] = function () push(DS, DS[DS.n]) end
_F["*"]   = function () push(DS, pop(DS) * pop(DS)) end
_F["."]   = function () print(" "..pop(DS)) end

-- 对于以 %L 打头的代码行, 直接对本行剩余内容进行求值, 提供了一种动态加载字典内容的途径
_F["%L"] = function () eval(parseRestOfLine()) end

-- 对于位于 [L ... L] 之内的代码块的处理
_F["[L"] = function () eval(parser("^(.-)%sL]()")) end


-- 定义模式表
modes = {}
mode = "interpret"

-- 分别处理当前字 word 为原语,非原语,数字的函数
interpretPrimitive = function ()
    if type(_F[word]) == "function" then _F[word](); return true end
  end
interpretNonPrimitive = function () return false end
interpretNumber       = function () return true end
printStatusInterpret = function () end

-- 定义 interpret 模式的具体行为
modes.interpret = function ()
	-- 从 subj 中依次取得当前字, 若没有则使用空串 "" 表示已执行到程序末尾
	word = getWordOrNewline() or ""
	printStatusInterpret()
	local _ = interpretPrimitive() or
		interpretNonPrimitive() or
		interpretNumber() or
		print("Can't interpret: "..word)
end

-- 新增返回栈 DS, 存储器 memory
RS     = { n = 0 }
memory = { n = 0 }
here = 1

-- 编译多个字, 依次编译
compile  = function (...) 
	local arg = {...}; arg.n = select("#", ...)
	for i = 1,arg.n do compile1(arg[i]) end 
end

-- 编译单个字, 放入内存 memory
compile1 = function (x)
    memory[here] = x; here = here + 1
    memory.n = math.max(memory.n, here)
  end

compile  = function (...) for i, v in ipaires{...} do compile1(v) end end

_H = {}

-- 在 _H 中定义字节码的首部 DOCOL 对应的字节码, 切换模式为 forth
_H["DOCOL"] = function ()
    -- RS[RS.n] = RS[RS.n] + 1
    mode = "forth"
  end
  
-- 在字典 _F 中定义字节码的结束标志 EXIT 对应的行为 
_F["EXIT"] = function ()
    pop(RS)
    if type(RS[RS.n]) == "string" then mode = pop(RS) end
    -- if mode == nil then mode = "stop" end    -- hack
  end

-- 新增状态打印函数:
printStatusHead = function () end
printStatusForth = function () end

-- 新增模式: head, 
modes.head = function ()
    head = memory[RS[RS.n]]
    printStatusHead()
    RS[RS.n] = RS[RS.n] + 1
    _H[head]()
  end
  
-- 新增模式: forth,   
modes.forth = function ()
    instr = memory[RS[RS.n]]
    printStatusForth()
    RS[RS.n] = RS[RS.n] + 1
    if type(instr) == "number" then push(RS, instr); mode = "head"; return end
    if type(instr) == "string" then _F[instr](); return end
    print("Can't run forth instr: "..mytostring(instr))
  end

--
interpretNonPrimitive = function ()
    if type(_F[word]) == "number" then
      push(RS, "interpret")
      push(RS, _F[word])
      mode = "head"
      return true
    end
  end

-- 在字典中新增字 : 作为
_F[":"] = function ()
    _F[getword()] = here
    compile("DOCOL")
    mode = "compile"
  end
  
-- 在字典中新增字 ; 作为定义新字的结束标志  
_F[";"] = function ()
    compile("EXIT")
    mode = "interpret"
  end
  
-- 定义立即表, 作为判断立即字的标准
IMMEDIATE = {}
IMMEDIATE[";"] = true

-- 打印编译模式的状态, 暂时为空
printStatusCompile = function () end

-- 编译立即字:
compileImmediateWord = function ()
    if word and _F[word] and IMMEDIATE[word] then
      if type(_F[word]) == "function" then   -- 原语
        _F[word]()
      else
        push(RS, mode)
        push(RS, _F[word])
        mode = "head"
      end
      return true
    end
  end
  
-- 编译非立即字  
compileNonImmediateword = function ()
    if word and _F[word] and not IMMEDIATE[word] then
      if type(_F[word]) == "function" then
        compile1(word)	    -- 原语: compile its name (string)
      else
        compile1(_F[word])  -- 非原语: compile its address (a number)
      end
      return true
    end
  end
  
-- 编译数字:   
compileNumber = function ()
    if word and tonumber(word) then
      compile1("LIT"); compile1(tonumber(word)); return true
    end
  end

-- 定义编译模式的行为, 分别处理立即字, 非立即字以及数字
modes.compile = function ()
    word = getword()
    printStatusCompile()
    local _ = compileImmediateWord() or
              compileNonImmediateWord() or
              compileNumber() or
              print("Can't compile: "..(word or EOT))
  end

-- 处理任意数字: 直接把数字压入 DS 栈
interpretNumber = function ()
    if word and tonumber(word) then push(DS, tonumber(word)); return true end
  end


-- 在字典 _F 中新增 LIT
_F["LIT"] = function ()
    push(DS, memory[RS[RS.n]])
    RS[RS.n] = RS[RS.n] + 1
  end

_F["LIT"] = function () mode = "lit" end
modes.lit = function ()
    data = memory[RS[RS.n]]
    p_s_lit()
    push(DS, memory[RS[RS.n]])
    RS[RS.n] = RS[RS.n] + 1
    mode = "forth"
  end

_F["+"] = function () push(DS, pop(DS) + pop(DS)) end




-- 虚拟机主循环函数
run = function () while mode ~= "stop" do modes[mode]() end end

-- 用户输入的代码文本, 也就是准备在虚拟机中执行的程序
subj = [==[
	5 DUP * .
	5 DUP * .
]==]
    
pos  = 1

-- 运行虚拟机
mode = "interpret"
run() 
