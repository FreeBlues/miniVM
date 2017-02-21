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
