local CreateTemplate = [[
        private static GObject CreateGObject()
        {
            return UIPackage.CreateObject(UIPackageName, UIResName);
        }

        public static {className} CreateInstance()
        {
            return Create(CreateGObject());
        }
]]

---@type string UI代码模板
local FUITemplate = [[
#if ENABLE_UI_FAIRYGUI
using FairyGUI;
using FairyGUI.Utils;
using GameFrameX.UI.Runtime;
using GameFrameX.UI.FairyGUI.Runtime;
using GameFrameX.Runtime;
using UnityEngine;

namespace {namespaceName}
{
    [OptionUIConfig(UIPackageName)]
    public sealed partial class {className} : FUI
    {
        public const string UIPackageName = "{codePkgName}";
        public const string UIResName = "{resName}";
        public const string URL = "{URL}";

        /// <summary>
        /// {uiResName}的组件类型(GComponent、GButton、GProcessBar等)，它们都是GObject的子类。
        /// </summary>
        public {superClassName} self { get; private set; }

__PROPERTY__

__CREATETEMPLATE__
        public static {className} Create(GObject go)
        {
            var fui = go.displayObject.gameObject.GetOrAddComponent<{className}>();
            fui?.SetGObject(go);
            fui?.InitView();
            return fui;
        }

        /// <summary>
        /// 通过此方法获取的FUI，在Dispose时不会释放GObject，需要自行管理（一般在配合FGUI的Pool机制时使用）。
        /// </summary>
        public static {className} GetFormPool(GObject go)
        {
            var fui = go.Get<{className}>();
            if (fui == null)
            {
                fui = Create(go);
            }

            fui.IsFromPool = true;
            return fui;
        }

        protected override void InitView()
        {
            if(GObject == null)
            {
                return;
            }

            self = ({superClassName})GObject;
            self.Add(this);
            {comAdd}
            var com = GObject.asCom;
            if (com != null)
            {
__AWAKE__
            }
        }

        public override void Dispose()
        {
            if (IsDisposed)
            {
                return;
            }

            base.Dispose();
            self.Remove();
__DISPOSE__
            self = null;
        }

        private {className}(GObject gObject) : base(gObject)
        {
        }
    }
}
#endif]]
---@type string UI包资源模板
local FUIPackageTemplate = [[
#if ENABLE_UI_FAIRYGUI

namespace {namespaceName}
{
    public static partial class FUIPackage
    {
__PKGNAMES__
    }
}
#endif]]

--- 将输入字符串按指定分隔符分割成数组
---@param input: 输入的字符串
---@param delimiter: 分隔符
local function split(input, delimiter)
    -- 检查分隔符是否为字符串且长度大于0
    if type(delimiter) ~= "string" or #delimiter <= 0 then
        return -- 如果不是，返回空
    end
    local start = 1 -- 定义起始位置
    local arr = {} -- 创建空数组
    while true do -- 进入循环
        local pos = string.find(input, delimiter, start, true) -- 查找分隔符位置
        if not pos then -- 如果没有找到
            break -- 退出循环
        end
        table.insert(arr, string.sub(input, start, pos - 1)) -- 将分隔符之前的部分插入数组
        start = pos + string.len(delimiter) -- 更新起始位置
    end
    table.insert(arr, string.sub(input, start)) -- 插入剩余部分到数组
    return arr -- 返回数组
end

--- 判断是否为自定义组件
--- @param classes table 包含类信息的表
--- @param typeName string 待检查的类型名称
--- @return boolean 如果是自定义组件则返回true，否则返回false
local function IsCustomComponent(classes, typeName)
    -- classes 为 lua table（genCode 函数中已统一转换），按 1-indexed 遍历
    local classCnt = #classes -- 获取类的数量
    for i = 1, classCnt do -- 遍历类表
        local classInfo = classes[i] -- 获取当前类信息
        if typeName == classInfo.className then -- 检查类型名称是否匹配
            return true; -- 如果匹配则返回true
        end
    end
    return false; -- 类型名称未匹配则返回false
end

--- 判断跨包成员是否应绑定到包装类（生成 Wrapper.Create(...)）
--- @param handler table PublishHandler
--- @param memberInfo table MemberInfo
--- @return string|nil 包装类名；不满足返回 nil（沿用原 memberInfo.type 强转）
local function TryGetCrossPackageWrapper(handler, memberInfo)
    if memberInfo.res == nil then return nil end
    if memberInfo.res.owner.name == handler.pkg.name then return nil end
    if memberInfo.res.type ~= CS.FairyEditor.FPackageItemType.COMPONENT then return nil end
    local resName = memberInfo.res.name
    if not string.match(resName, "^UI%a+$") then return nil end
    local sourceCodePkgName = handler:ToFilename(memberInfo.res.owner.name)
    if not string.match(resName, "^" .. sourceCodePkgName .. "%a*$") then return nil end
    return resName
end

--- 安全获取组件的 ComponentAsset（XLua 可能不暴露 GetAsset/ComponentAsset.New，双通道 pcall 防御）
local function GetAssetSafe(item)
    local ok, asset = pcall(function() return item:GetAsset() end)
    if ok and asset ~= nil then return asset end
    local ok2, asset2 = pcall(function() return CS.FairyEditor.ComponentAsset.New(item) end)
    if ok2 and asset2 ~= nil then return asset2 end
    return nil
end

--- 判断 FPackageItem 是否有 wrapper 类（同包/跨包统一判定，命名规则与代码生成一致）
local function GetWrapperName(handler, item)
    if item == nil or not item.exported then return nil end
    if item.type ~= CS.FairyEditor.FPackageItemType.COMPONENT then return nil end
    local name = item.name
    if not string.match(name, "^UI%a+$") then return nil end
    local ownerCodeName = handler:ToFilename(item.owner.name)
    if not string.match(name, "^" .. ownerCodeName .. "%a*$") then return nil end
    return name
end

--- xml tag 到 FGUI 类型的映射（component 特判，不在表内）
local TAG_TYPE_MAP = {
    image = "GImage", text = "GTextField", richtext = "GRichTextField",
    input = "GTextInput", loader = "GLoader", loader3d = "GLoader3D",
    list = "GList", graph = "GGraph", group = "GGroup", swfobject = "GSwfObject",
}

--- 解析组件 xml 的 controller/transition 名（controller 附带页面名）
local function GetComponentMeta(asset)
    local controllers = {}
    local transitions = {}
    if asset ~= nil and asset.xml ~= nil then
        local okC, ctrlList = pcall(function() return asset.xml:Elements("controller") end)
        if okC and ctrlList ~= nil and ctrlList.rawList ~= nil then
            local raw = ctrlList.rawList
            for i = 0, raw.Count - 1 do
                local cname = raw[i]:GetAttribute("name", "")
                if cname ~= "" then
                    local pagesStr = raw[i]:GetAttribute("pages", "")
                    local names = {}
                    if pagesStr ~= "" then
                        local parts = split(pagesStr, ",")
                        for pi = 2, #parts, 2 do
                            table.insert(names, parts[pi])
                        end
                    end
                    if #names > 0 then
                        table.insert(controllers, cname .. "(" .. table.concat(names, ", ") .. ")")
                    else
                        table.insert(controllers, cname)
                    end
                end
            end
        end
        local okT, transList = pcall(function() return asset.xml:Elements("transition") end)
        if okT and transList ~= nil and transList.rawList ~= nil then
            local raw = transList.rawList
            for i = 0, raw.Count - 1 do
                local tname = raw[i]:GetAttribute("name", "")
                if tname ~= "" then
                    table.insert(transitions, tname)
                end
            end
        end
    end
    return controllers, transitions
end

--- 取 Button 扩展的 mode 属性（Check/Radio 等，影响事件选择）
local function GetButtonMode(asset)
    if asset == nil or asset.xml == nil then return nil end
    if asset.extension ~= "Button" then return nil end
    local okB, btnList = pcall(function() return asset.xml:Elements("Button") end)
    if not okB or btnList == nil or btnList.rawList == nil or btnList.rawList.Count == 0 then return nil end
    local mode = btnList.rawList[0]:GetAttribute("mode", "")
    if mode == "" then return nil end
    return mode
end

--- 渲染 displayList 一层子节点为树行（递归展开嵌套组件；visited 为路径栈，兄弟可重复引用，只拦真环）
local function AppendChildren(handler, displayList, prefix, lines, visited, depth, curVarMap)
    if depth > 32 then
        table.insert(lines, prefix .. "…(超过最大深度已省略)")
        return
    end
    local cnt = displayList.Count
    for k = 0, cnt - 1 do
        local di = displayList[k]
        local last = (k == cnt - 1)
        local branch = last and "└─ " or "├─ "
        local childPrefix = prefix .. (last and "   " or "│  ")
        -- 节点名：name 属性，无则用 desc id 属性
        local name = di.desc:GetAttribute("name", "")
        local nodeId = di.desc:GetAttribute("id", "")
        local label = (name ~= "" and name) or nodeId
        -- 类型：component 特判（extension → G+ext / wrapper 名 / Button mode）；其余查映射表，未知原样 tag
        local fguiType = TAG_TYPE_MAP[di.type] or di.type
        local wrapper = nil
        local asset = nil
        local modeSuffix = ""
        if di.type == "component" and di.packageItem ~= nil then
            wrapper = GetWrapperName(handler, di.packageItem)
            asset = GetAssetSafe(di.packageItem)
            if asset ~= nil and asset.extension ~= nil and asset.extension ~= "" then
                fguiType = "G" .. asset.extension
            else
                fguiType = "GComponent"
            end
            local mode = GetButtonMode(asset)
            if mode ~= nil then modeSuffix = "·" .. mode end
        end
        -- 尺寸：desc size 属性，无则 packageItem 的原始 width/height
        local sizeStr = di.desc:GetAttribute("size", "")
        if sizeStr == "" and di.packageItem ~= nil then
            sizeStr = string.format("%d,%d", di.packageItem.width, di.packageItem.height)
        end
        sizeStr = string.gsub(sizeStr, ",", "x")
        -- 跨包标注
        local pkgTag = ""
        if di.packageItem ~= nil and di.packageItem.owner.name ~= handler.pkg.name then
            pkgTag = string.format(" [pkg=%s]", di.packageItem.owner.name)
        end
        -- 绑定标注：depth==1 以 varNameMap 为事实来源——命中 → → varName（C# 属性名），未命中 → [无绑定]
        -- （CollectClasses 不收集无名称与 n+数字 自动名成员，这些节点不生成 C# 属性）
        local bindTag = ""
        if depth == 1 then
            if curVarMap ~= nil and curVarMap[name] ~= nil then
                bindTag = " → " .. curVarMap[name]
            else
                bindTag = " [无绑定]"
            end
        end
        -- 图片资源名（视觉意图提示）
        local resTag = ""
        if di.type == "image" and di.packageItem ~= nil then
            resTag = " ← " .. string.gsub(di.packageItem.name, "%.%w+$", "")
        end
        -- 文本内容（最强的意图信号）
        local textTag = ""
        if di.type == "text" or di.type == "richtext" then
            local txt = di.desc:GetAttribute("text", "")
            txt = string.gsub(txt, "[\r\n]+", " ")
            if txt ~= "" then
                if #txt > 24 then
                    local cut = string.sub(txt, 1, 24)
                    while #cut > 0 do
                        local b = string.byte(cut, #cut)
                        if b < 128 then break end
                        if b >= 192 then cut = string.sub(cut, 1, #cut - 1) break end
                        cut = string.sub(cut, 1, #cut - 1)
                    end
                    txt = cut .. "…"
                end
                textTag = ' "' .. txt .. '"'
            end
        end
        -- 类型显示：wrapper 名·FGUI类型·mode 或 FGUI类型·mode
        local typeStr = wrapper and (wrapper .. "·" .. fguiType .. modeSuffix) or (fguiType .. modeSuffix)
        table.insert(lines, string.format("%s%s%s (%s, %s)%s%s%s%s", prefix, branch, label, typeStr, sizeStr, pkgTag, bindTag, resTag, textTag))
        -- 递归：component 展开 displayList（含其 controllers/transitions）；list 标注 defaultItem
        if di.type == "component" and di.packageItem ~= nil then
            local key = di.packageItem.owner.id .. "/" .. di.packageItem.id
            if visited[key] then
                table.insert(lines, childPrefix .. "└─ (↺ 循环引用已省略)")
            else
                visited[key] = true
                if asset == nil then asset = GetAssetSafe(di.packageItem) end
                if asset ~= nil then
                    local ctrls, trans = GetComponentMeta(asset)
                    if #ctrls > 0 then
                        table.insert(lines, childPrefix .. "Controllers: " .. table.concat(ctrls, ", "))
                    end
                    if #trans > 0 then
                        table.insert(lines, childPrefix .. "Transitions: " .. table.concat(trans, ", "))
                    end
                    if asset.displayList ~= nil and asset.displayList.Count > 0 then
                        AppendChildren(handler, asset.displayList, childPrefix, lines, visited, depth + 1, curVarMap)
                    end
                end
                visited[key] = nil -- 回溯
            end
        elseif di.type == "list" then
            local defUrl = di.desc:GetAttribute("defaultItem", "")
            if defUrl ~= "" then
                local okD, defItem = pcall(function() return handler.project:GetItemByURL(defUrl) end)
                if okD and defItem ~= nil then
                    local dWrapper = GetWrapperName(handler, defItem)
                    local dType = dWrapper ~= nil and (dWrapper .. "·GComponent") or "GComponent"
                    table.insert(lines, string.format("%s   └─ defaultItem: %s (%s)", childPrefix, defItem.name, dType))
                end
            end
        end
    end
end

--- 导出包结构树 markdown（全部 component，含未导出）
local function ExportStructure(handler, exportCodePath, codePkgName, varNameMap)
    local dir = exportCodePath .. '/' .. codePkgName
    CS.System.IO.Directory.CreateDirectory(dir)
    local lines = {}
    table.insert(lines, string.format("# %s 包结构", codePkgName))
    table.insert(lines, "")
    table.insert(lines, "> 由 gencode 插件自动生成（发布时更新），请勿手改。")
    table.insert(lines, "> 标注说明：`Wrapper·FGUI类型·mode`；`→ varName` 为生成的 C# 属性名（m_ 前缀）；`[无绑定]` 表示该节点未生成 C# 属性（无名称或 n+数字 自动名）；`[pkg=X]` 跨包引用；`← 资源名` 图片资源；`\"文本\"` 文案；`(↺)` 循环引用已省略。")
    local exportedCnt = 0
    for i = 0, handler.items.Count - 1 do
        local item = handler.items[i]
        if item.type == CS.FairyEditor.FPackageItemType.COMPONENT then
            local asset = GetAssetSafe(item)
            if asset ~= nil then
                local gType = (asset.extension ~= nil and asset.extension ~= "") and ("G" .. asset.extension) or "GComponent"
                local wrapper = GetWrapperName(handler, item)
                local headType = wrapper ~= nil and (wrapper .. "·" .. gType) or gType
                local tag = item.exported and " [exported]" or ""
                table.insert(lines, "")
                table.insert(lines, string.format("## %s (%s, %dx%d)%s", item.name, headType, item.width, item.height, tag))
                table.insert(lines, "")
                table.insert(lines, "```text")
                local ctrls, trans = GetComponentMeta(asset)
                if #ctrls > 0 then
                    table.insert(lines, "Controllers: " .. table.concat(ctrls, ", "))
                end
                if #trans > 0 then
                    table.insert(lines, "Transitions: " .. table.concat(trans, ", "))
                end
                if asset.displayList ~= nil and asset.displayList.Count > 0 then
                    local visited = { [item.owner.id .. "/" .. item.id] = true } -- 根自身防环
                    AppendChildren(handler, asset.displayList, "", lines, visited, 1, varNameMap[item.name])
                else
                    table.insert(lines, "(空组件)")
                end
                table.insert(lines, "```")
                if item.exported then exportedCnt = exportedCnt + 1 end
            end
        end
    end
    CS.System.IO.File.WriteAllText(dir .. '/Structure.md', table.concat(lines, "\n") .. "\n")
    return exportedCnt
end

--- 生成代码
--- @param handler table 处理程序
local function genCode(handler)
    local settings = handler.project:GetSettings("Publish").codeGeneration -- 获取发布设置中的代码生成选项
    local codePkgName = handler:ToFilename(handler.pkg.name); -- 将包名转换为文件名格式（拼音），去除特殊字符等

    -- 判断codePkgName必须以UI开头
    if not string.match(codePkgName, "^UI%a+$") then
        error(string.format("包名 '%s' 必须以'UI'开头并且只能包含字母的大写驼峰命名", codePkgName))
    end

    ---@type string
    local exportCodePath = handler.exportCodePath; -- 导出代码路径
    -- 规范化路径
    exportCodePath = string.gsub(exportCodePath, '\\', '/') -- 将路径中的反斜杠替换为斜杠
    -- UI组件
    local exportCodeComponentPath = handler.exportCodePath .. '/' .. codePkgName .. '/Components'; -- 导出代码的组件路径
    handler:SetupCodeFolder(exportCodeComponentPath, "cs") -- 设置代码文件夹
    local namespaceName = codePkgName -- 命名空间名称

    if settings.packageName ~= nil and settings.packageName ~= '' then
        namespaceName = settings.packageName .. '.' .. namespaceName; -- 如果设置中有包名，则使用设置中的包名
    end

    namespaceName = "Hotfix.UI"; -- 命名空间名称为"Hotfix.UI"
    if string.find(exportCodePath, "Unity/Assets/Scripts") then
        namespaceName = "Unity.Startup"; -- 如果导出路径包含"Unity/Assets/Scripts"，则命名空间名称为"Unity.Startup"
    end
    -- CollectClasses(stripeMemeber, stripeClass, fguiNamespace)
    -- FGUI Editor 的 CollectClasses 会漏掉部分 exported component（例如纯皮肤按钮如 UICommonBtn），
    -- 漏掉的组件不会被生成为 wrapper 类，跨包引用该组件的上层业务无法拿到包装类。
    -- 根治：先调 CollectClasses 拿到的 classes 转 lua table，再从 handler.items 补全未收集的 exported component。
    local csClasses = handler:CollectClasses(settings.ignoreNoname, settings.ignoreNoname, nil) -- 收集类信息（忽略无名称的类）
    local collectedNames = {}
    for i = 0, csClasses.Count - 1 do
        collectedNames[csClasses[i].className] = true
    end
    local classes = {}
    for i = 0, csClasses.Count - 1 do
        table.insert(classes, csClasses[i])
    end
    for i = 0, handler.items.Count - 1 do
        local item = handler.items[i]
        if item.exported and item.type == CS.FairyEditor.FPackageItemType.COMPONENT then
            local itemName = item.name
            if not collectedNames[itemName] then
                -- XLua 未暴露 ClassInfo.New()，改用 lua table 模拟（下游只访问字段，兼容）
                local ci = {}
                ci.className = itemName
                ci.resId = item.id
                ci.resName = itemName
                ci.res = item
                -- 纯皮肤组件无子成员，fake empty list 让下游 for 循环不执行
                ci.members = { Count = 0 }
                ci.superClassName = "GComponent" -- 默认
                local ok, asset = pcall(function() return item:GetAsset() end)
                if ok and asset ~= nil then
                    local ext = asset.extension
                    if ext ~= nil and ext ~= "" then
                        ci.superClassName = "G" .. ext
                    end
                end
                table.insert(classes, ci)
            end
        end
    end
    -- 检查目标文件夹是否存在，并删除旧文件

    local templeteString = FUITemplate; -- 模板字符串

    local classCnt = #classes -- 类的数量
    local writer = CodeWriter.new() -- 代码写入器
    for i = 1, classCnt do
        local classInfo = classes[i] -- 获取类信息
        
        -- 检查className是否以"UI"开头并只包含字母
        if not string.match(classInfo.className, "^UI%a+$") then
            error(string.format("组件名称 '%s' 必须以'UI'开头并且只能包含字母的大写驼峰命名", classInfo.className))
        end

        -- 检查className是否以codePkgName开头
        if not string.match(classInfo.className, "^" .. codePkgName .. "%a*$") then
            error(string.format("组件名称 '%s' 必须以'%s'开头", classInfo.className, codePkgName))
        end

        local com_width = classInfo.res.width
        local com_height = classInfo.res.height
        -- 检查宽度和高度是否为偶数
        if com_width % 2 ~= 0 then
            error(string.format("类 '%s' 的宽度必须为偶数，当前宽度为: %d", classInfo.className, com_width))
        end
        if com_height % 2 ~= 0 then
            error(string.format("类 '%s' 的高度必须为偶数，当前高度为: %d", classInfo.className, com_height))
        end

        local members = classInfo.members -- 成员变量
        local memberInfoExported = classInfo.res.exported; -- 成员信息是否导出
        writer:reset() -- 重置写入器

        local genCreateString = CreateTemplate; -- 生成创建字符串

        local genCodeString = templeteString; -- 生成代码字符串
        --- 处理导出的差异
        if memberInfoExported then
            genCodeString = string.gsub(genCodeString, '__CREATETEMPLATE__', genCreateString) -- 如果成员信息导出，则替换模板字符串中的__CREATETEMPLATE__
        else
            genCodeString = string.gsub(genCodeString, '__CREATETEMPLATE__', '') -- 否则移除__CREATETEMPLATE__
        end

        genCodeString = string.gsub(genCodeString, '{namespaceName}', namespaceName) -- 替换命名空间名称
        genCodeString = string.gsub(genCodeString, '{className}', classInfo.className) -- 替换类名
        genCodeString = string.gsub(genCodeString, '{superClassName}', classInfo.superClassName) -- 替换父类名
        genCodeString = string.gsub(genCodeString, '{codePkgName}', handler.pkg.name) -- 替换包名
        genCodeString = string.gsub(genCodeString, '{resName}', classInfo.resName) -- 替换资源名
        genCodeString = string.gsub(genCodeString, '{URL}', 'ui://' .. handler.pkg.id .. classInfo.resId) -- 替换资源URL

        local propertyStr = ""; -- 属性字符串
        local propertyTable = {}; -- 属性表
        local AwakeStr = ""; -- Awake字符串
        local AwakeTable = {}; -- Awake表
        local DisposeStr = ""; -- Dispose字符串
        local disposeTable = {}; -- Dispose表
        local memberCnt = members.Count -- 成员数量
        for j = 0, memberCnt - 1 do
            local memberInfo = members[j] -- 获取成员信息
            local typeName = memberInfo.type -- 类型名称
            local varName = memberInfo.varName -- 变量名
            local memberInfoName = memberInfo.name; -- 成员信息名称
            if memberInfo.res ~= nil then
                local width = memberInfo.res.width -- 宽度
                local height = memberInfo.res.height -- 高度
                -- 检查宽度和高度是否为偶数
                if width % 2 ~= 0 then
                    error(string.format("类 '%s' 中的成员 '%s' 的宽度必须为偶数，当前宽度为: %d", classInfo.className, memberInfoName, width))
                end
                if height % 2 ~= 0 then
                    error(string.format("类 '%s' 中的成员 '%s' 的高度必须为偶数，当前高度为: %d", classInfo.className, memberInfoName, height))
                end
            end

            if memberInfo.group ~= 1 then
                -- 判断不是Controller
                -- 排除特殊名称
                if memberInfoName ~= "closeButton" and memberInfoName ~= "dragArea" and memberInfoName ~= "contentArea" then
                    if memberInfoName ~= string.lower(memberInfoName) then
                        error(string.format("类 '%s' 中的成员名称 '%s' 必须使用小写字母+下划线分割的方式命名", classInfo.className, memberInfoName))
                    end
                end
            end

            -- 这里查找组件是否是其他包里的资源
            local isWhetherToCrossPackages = false; -- 是否跨包引用
            local crossWrapperName = nil  -- 包装类名（UICommonBtn / UICommonBottomFix ...）
            if memberInfo.res ~= nil then
                if memberInfo.res.owner.name ~= handler.pkg.name then -- 判断是不是本包的资源
                    -- 跨包引用的组件必须导出；未导出的强制导出，所属包下次发布时才能生成包装类。
                    if memberInfo.res.type == CS.FairyEditor.FPackageItemType.COMPONENT and not memberInfo.res.exported then
                        memberInfo.res.exported = true; -- 强制导出
                        fprint(string.format("警告: 类 '%s' 跨包引用的组件 '%s'(包 '%s') 未设置导出，已强制导出。请保存项目并重新发布 '%s' 包。",
                            classInfo.className, memberInfo.res.name, memberInfo.res.owner.name, memberInfo.res.owner.name));
                    end
                    isWhetherToCrossPackages = true;
                    -- 判定跨包组件所属包是否会为其生成包装类代码：
                    -- 组件名符合 'UI<sourceCodePkgName>...' 命名规则则绑定包装类（生成 UICommonBtn.Create(...)）；
                    -- 否则保持 memberInfo.type 强转（普通组件给类名/基础类型，扩展组件给扩展类型 GButton/GLabel 等）。
                    -- 注意：CollectClasses 只收集当前发布包，故跨包判断必须基于 memberInfo.res 自身信息。
                    crossWrapperName = TryGetCrossPackageWrapper(handler, memberInfo)
                    if crossWrapperName == nil and memberInfo.res.type == CS.FairyEditor.FPackageItemType.COMPONENT then
                        fprint(string.format("警告: 类 '%s' 跨包引用的组件 '%s'(包 '%s') 命名不符合 'UI<包名>...' 规则，回退为强转 '%s'。",
                            classInfo.className, memberInfo.res.name, memberInfo.res.owner.name, typeName));
                    end
                end
            end

            -- 属性类型：跨包且有包装类 → 用包装类名；否则维持原 typeName
            local propType = typeName
            if crossWrapperName ~= nil then propType = crossWrapperName end
            table.insert(propertyTable, '\t\tpublic ' .. propType .. ' ' .. varName .. ' { get; private set; }'); -- 插入属性表

            if string.find(typeName, "Scene") then
                table.insert(disposeTable, '\t\t\t' .. varName .. '.Dispose();'); -- 如果类型名称中包含"Scene"，则插入Dispose表
            end
            table.insert(disposeTable, '\t\t\t' .. varName .. ' = null;'); -- 插入Dispose表

            if memberInfo.group == 0 then
                -- 跨包包装类优先;其次同包自定义组件;最后基础/扩展类型强转兜底
                if crossWrapperName ~= nil then
                    table.insert(AwakeTable, '\t\t\t\t' .. varName .. ' = ' .. crossWrapperName .. '.Create(com.GetChild("' ..
                        memberInfoName .. '"));'); -- 跨包包装类:UICommonBtn.Create(com.GetChild("rebirth_button"))
                elseif IsCustomComponent(classes, typeName) then
                    table.insert(AwakeTable, '\t\t\t\t' .. varName .. ' = ' .. typeName .. '.Create(com.GetChild("' ..
                        memberInfoName .. '"));'); -- 同包自定义组件
                else
                    table.insert(AwakeTable, '\t\t\t\t' .. varName .. ' = (' .. typeName .. ')com.GetChild("' ..
                        memberInfoName .. '");'); -- 基础/扩展类型强转(含跨包命名不合规)
                end
            elseif memberInfo.group == 1 then
                table.insert(AwakeTable, '\t\t\t\t' .. varName .. ' = com.GetController("' .. memberInfoName .. '");'); -- 插入Awake表
            else
                table.insert(AwakeTable, '\t\t\t\t' .. varName .. ' = com.GetTransition("' .. memberInfoName .. '");'); -- 插入Awake表
            end
        end
        propertyStr = table.concat(propertyTable, '\n') -- 属性字符串连接
        DisposeStr = table.concat(disposeTable, '\n') -- Dispose字符串连接
        AwakeStr = table.concat(AwakeTable, '\n') -- Awake字符串连接
        genCodeString = string.gsub(genCodeString, '__PROPERTY__', propertyStr) -- 替换属性字符串
        genCodeString = string.gsub(genCodeString, '__AWAKE__', AwakeStr) -- 替换Awake字符串
        genCodeString = string.gsub(genCodeString, '__DISPOSE__', DisposeStr) -- 替换Dispose字符串
        if string.find(namespaceName, ".Model") then
            genCodeString = string.gsub(genCodeString, '{comB}', '/***') -- 替换字符串
            genCodeString = string.gsub(genCodeString, '{comE}', '***/') -- 替换字符串

            genCodeString = string.gsub(genCodeString, '{comAdd}', '') -- 替换字符串
            -- genCodeString = string.gsub(genCodeString, '{comRemove}', '') -- 替换字符串

        else
            genCodeString = string.gsub(genCodeString, '{comB}', '') -- 替换字符串
            genCodeString = string.gsub(genCodeString, '{comE}', '') -- 替换字符串

            genCodeString = string.gsub(genCodeString, '{comAdd}', '') -- 替换字符串
            -- genCodeString = string.gsub(genCodeString, '{comRemove}', '') -- 替换字符串
        end
        writer:writeln(genCodeString); -- 写入生成的代码字符串
        writer:save(exportCodeComponentPath .. '/' .. classInfo.className .. '.cs'); -- 保存生成的代码文件
    end

    writer:reset() -- 重置写入器

    local packageTempleteString = FUIPackageTemplate; -- 包模板字符串
    local pkgNamesStr = ""; -- 包名字符串
    local pkgNamesTable = {}; -- 包名表
    packageTempleteString = string.gsub(packageTempleteString, '{namespaceName}', namespaceName) -- 替换命名空间名称

    table.insert(pkgNamesTable, '\t\tpublic const string ' .. codePkgName .. ' = "' .. codePkgName .. '";'); -- 插入包名表
    -- for i = 0, classCnt - 1 do
    --     local classInfo = classes[i];
    --     table.insert(pkgNamesTable,'\t\tpublic const string ' .. codePkgName .. '_' .. classInfo.resName .. ' = "ui://' .. codePkgName .. '/' .. classInfo.resName .. '";'); -- 插入包名表
    -- end
    pkgNamesStr = table.concat(pkgNamesTable, '\n'); -- 包名字符串连接
    packageTempleteString = string.gsub(packageTempleteString, '__PKGNAMES__', pkgNamesStr) -- 替换包名字符串

    local binderName = 'Package' .. codePkgName; -- 绑定器名称
    writer:writeln(packageTempleteString); -- 写入包模板字符串
    writer:save(exportCodeComponentPath .. '/' .. binderName .. '.cs'); -- 保存包绑定器文件

    -- 导出包结构树（独立于代码生成，失败不阻断发布）
    -- xml name → C# varName 映射（按组件名分组），供树上标注绑定属性名
    local varNameMap = {}
    for i = 0, csClasses.Count - 1 do
        local ci = csClasses[i]
        local m = {}
        if ci.members ~= nil then
            for j = 0, ci.members.Count - 1 do
                m[ci.members[j].name] = ci.members[j].varName
            end
        end
        varNameMap[ci.className] = m
    end
    local okS, resultS = pcall(ExportStructure, handler, exportCodePath, codePkgName, varNameMap)
    if okS then
        fprint(string.format("已导出包结构树: %s/%s/Structure.md (exported 组件 %d 个)", exportCodePath, codePkgName, resultS))
    else
        fprint("警告: 导出包结构树失败: " .. tostring(resultS))
    end
end

return genCode
