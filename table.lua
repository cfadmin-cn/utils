local type = type
local pairs = pairs
local ipairs = ipairs
local rawlen = rawlen
local assert = assert
local select = select

local sformat = string.format

local tsort = table.sort
local tconcat = table.concat

---comment 获取`table`长度
---@param tab table
---@return integer
function table.len (tab)
  assert(type(tab) == 'table', "Invalid table.")
  return #tab
end

---comment 获取`table`长度(跳过元方法)
---@param tab table
---@return integer
function table.rawlen (tab)
  assert(type(tab) == 'table', "Invalid table.")
  return rawlen(tab)
end

---comment 返回数组内最大`value`
---@param tab table
---@return number
function table.max(tab)
  assert(type(tab) == 'table', "Invalid table.")
  local s, e = 2, #tab
  local max_value = nil
  if e < 1 then
    return max_value
  end
  max_value = tab[1]
  while s < e do
    if max_value < tab[s] then
      max_value = tab[s]
    end
    s = s + 1
    if max_value < tab[e] then
      max_value = tab[e]
    end
    e = e - 1
  end
  return max_value
end

---comment 返回数组内最小`value`
---@param tab table
---@return number
function table.min(tab)
  assert(type(tab) == 'table', "Invalid table.")
  local s, e = 2, #tab
  local min_value = nil
  if e < 1 then
    return min_value
  end
  min_value = tab[1]
  while s < e do
    if min_value > tab[s] then
      min_value = tab[s]
    end
    s = s + 1
    if min_value > tab[e] then
      min_value = tab[e]
    end
    e = e - 1
  end
  return min_value
end

---comment 获取`table`所有`key`
---@param tab table
---@return table @返回`keys`数组
function table.keys (tab)
  assert(type(tab) == 'table', "Invalid table.")
  local list = {}
  for k, _ in pairs(tab) do
    list[#list+1] = k
  end
  return list
end

---comment 获取`table`所有`value`
---@param tab table
---@return table @返回`value`数组
function table.values (tab)
  assert(type(tab) == 'table', "Invalid table.")
  local list = {}
  for _, v in pairs(tab) do
    list[#list+1] = v
  end
  return list
end

---comment 向左旋转数组
---@param tab table
---@return table @返回旋转完成后的数组
function table.lrotate(tab)
  assert(type(tab) == 'table', "Invalid table.")
  local last = tab[1]
  for i = 2, #tab do
    tab[i-1] = tab[i]
  end
  tab[#tab] = last
  return tab
end

---comment 向右旋转数组
---@param tab table
---@return table @返回旋转完成后的数组
function table.rrotate(tab)
  assert(type(tab) == 'table', "Invalid table.")
  local last = tab[#tab]
  for i = #tab - 1, 1, -1 do
    tab[i+1] = tab[i]
  end
  tab[1] = last
  return tab
end

---comment 反转数组
---@param tab table @待反转的数组
---@return table    @返回`tab`
function table.reverse (tab)
  assert(type(tab) == 'table', "Invalid table.")
  local s, e = 1, #tab
  while s < e do
    tab[s], tab[e] = tab[e], tab[s]
    s = s + 1
    e = e - 1
  end
  return tab
end

local sorts = {
  [1] = function (list1, list2)
    return list1[1] < list2[1]
  end,
  [2] = function (list1, list2)
    return list2[1] < list1[1]
  end,
  [3] = function (list1, list2)
    return list1[2] < list2[2]
  end,
  [4] = function (list1, list2)
    return list2[2] < list1[2]
  end,
}

---comment 格式化输出表内容
---@param tab    table          @原始表
---@param fmt    string  | nil  @可自定义`key`、`value`格式内容
---@param sep    string  | nil  @如果表内字段多, 多个`format`字符串连接时候可能会需要用到.
---@param sort   integer | nil  @默认为(1.key升序)，可选:(2.key降序)、(3.value升序)、(4.value降序)
---@return string               @最终的输出内容
function table.format (tab, fmt, sep, sort)
  assert(type(tab) == 'table', "Invalid table.")
  local list = {}
  for k, v in pairs(tab) do
    list[#list+1] = {k, v}
  end
  -- 根据key进行升序排列
  tsort(list, sorts[tonumber(sort) or 1] or sort[1])
  -- 开始合并数据
  for idx, item in ipairs(list) do
    list[idx] = sformat(fmt or "%s=%s", item[1], item[2])
  end
  return tconcat(list, sep)
end

---comment 合并2个表
---@param table1  table | nil @`table1`和`table2`只能有一个为空
---@param table2  table | nil @`table1`和`table2`只能有一个为空
---@param new_tab table | nil @可以外部传入或者内部创建
---@return table
local function table_merge(table1, table2, new_tab)
  local tab = new_tab or {}
  if type(table1) == 'table' then
    for k, v in pairs(table1) do
      tab[k] = type(v) ~= 'table' and v or table_merge(v, {})
    end
  end
  if type(table2) == 'table' then
    for k, v in pairs(table2) do
      tab[k] = type(v) ~= 'table' and v or table_merge(v, {})
    end
  end
  return tab
end

---comment 创建新表来合并2个字典表(不存在引用问题)
---@param table1 table
---@param table2 table
---@return table @始终返回新表
function table.new (table1, table2)
  assert(table1 ~= table2, "You cannot merge two tables of the same type.")
  return table_merge(table1, table2, {})
end

---comment 合并表`table2`内容到表`table1`内(不存在引用问题)
---@param table1 table
---@param table2 table
---@return table  @返回`table1`
function table.lmerge (table1, table2)
  assert(table1 ~= table2, "You cannot merge two tables of the same type.")
  return table_merge(nil, table2, table1)
end

---comment 合并表`table1`内容到表`table2`内(不存在引用问题)
---@param table1 table
---@param table2 table
---@return table  @返回`table2`
function table.rmerge (table1, table2)
  assert(table1 ~= table2, "You cannot merge two tables of the same type.")
  return table_merge(nil, table1, table2)
end

---comment 数组转哈希表
---@param tab table @待转换的数组
---@return table    @返回转换后的哈希表
function table.tohash(tab)
  assert(type(tab) == 'table', "Invalid table.")
  local len = #tab
  assert(len & 0x01 == 0x00, "Invalid table len.")
  local hashtab = {}
  for idx = 1, len, 2 do
    hashtab[tab[idx]] = tab[idx+1]
  end
  return hashtab
end

---comment 哈希表转数组(列表)
---@param tab table @待转换的哈希表
---@return table    @返回转换后的数组(列表)
function table.tolist(tab)
  assert(type(tab) == 'table', "Invalid table.")
  local idx = 1
  local list = {}
  for k, v in pairs(tab) do
    list[idx] = k
    idx = idx + 1
    list[idx] = v
    idx = idx + 1
  end
  return list
end

---comment 将一个或者多可`key`->`value`构建为哈希表或者数组
---@return table    @返回构建好的table
function table.wrap(...)
  local len = select("#", ...)
  assert(len & 0x01 == 0x00, "Invalid key value amount.")
  local list = {...}
  local tab = {}
  for idx = 1, len, 2 do
    tab[list[idx]] = list[idx+1]
  end
  return tab
end
