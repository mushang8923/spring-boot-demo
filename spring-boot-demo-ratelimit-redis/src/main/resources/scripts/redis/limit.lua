-- 下标从 1 开始
local key = KEYS[1]
local now = tonumber(ARGV[1])
local ttl = tonumber(ARGV[2])
local expired = tonumber(ARGV[3])
-- 最大访问量
local max = tonumber(ARGV[4])


-- 清除过期的数据
-- 移除指定分数区间内的所有元素，expired 即已经过期的 score
-- 根据当前时间毫秒数 - 超时毫秒数，得到过期时间 expired
-- redis.call('zremrangebyscore', key, 0, expired)

-- 得到所有的键值对
local total=redis.call('HGETALL',key)

local current=0

local needAdd=0

for i,v in pairs(total)
 do
    if i % 2 == 0 then
      if needAdd == 0 then
       current = current + v
      end
       needAdd = 0
   else
      if tonumber(v) < expired then
        redis.call('HDEL',key,v)
        needAdd=1
      end
   end
end

-- 获取 zset 中的当前元素个数
-- local current = tonumber(redis.call('zcard', key))
local next = current + 1

if next > max then
  -- 达到限流大小 返回 0
  return 0;
else
  -- 往 zset 中添加一个值、得分均为当前时间戳的元素，[value,score]
  redis.call("HINCRBY", key, now, 1)
  -- 每次访问均重新设置 zset 的过期时间，单位毫秒
 -- redis.call("pexpire", key, ttl)
  return next
end
