require('util ')
local module = {}
module.test = {}

-- returns a list of all elements matching the entry
local function enumerate_entry(entry)
  local parts = {}

  -- split into parts separated by comma
  while string.match(entry, ',') do
    head, entry = string.match(entry, '^(.-),(.*)$')
    table.insert(parts, head)
  end

  table.insert(parts, entry)

  local rv = {}

  -- deal with ranges
  for _, part in pairs(parts) do
    from, to = string.match(part, '^(%d-)%-(%d*)$')
    if from and to then
      for i = from, to do table.insert(rv, i) end
    else
      table.insert(rv, part)
    end
  end

  -- convert everything into numbers
  for i in pairs(rv) do rv[i] = 0 + rv[i] end

  return rv
end

module.test.enumerate_entry = enumerate_entry

local function expand_list(list)
  rv = {}
  for _, v in pairs(list) do rv[v] = true end

  return rv
end

module.test.expand_list = expand_list

-- `entry` is a table representing a cron entry using keys
--
-- * weekday (0..6, Sunday is 0)
-- * hour (0..23)
-- * minute (0..59)
-- * day (1..31)
-- * month (1..12)
--
-- `parse_cronentry` returns a version more easily used
local function parse_cronentry(entry)
  local rv = {}
  rv.weekday = expand_list(enumerate_entry(entry.weekday or '0-6'))
  rv.hour = expand_list(enumerate_entry(entry.hour or '0-23'))
  rv.minute = expand_list(enumerate_entry(entry.minute or '0-59'))
  rv.day = expand_list(enumerate_entry(entry.day or '1-31'))
  rv.month = expand_list(enumerate_entry(entry.month or '1-12'))

  return rv
end

module.test.parse_cronentry = parse_cronentry

-- uses `os.date` to turn `time` into a table similar to the
-- format of `parse_cronentry`
local function unpack_time(time)
  return {
    weekday = 0 + os.date('%w', time),
    hour = 0 + os.date('%H', time),
    minute = 0 + os.date('%M', time),
    day = 0 + os.date('%d', time),
    month = 0 + os.date('%m', time),
  }
end

-- `cronentry` is a cronentry as constructed by
-- `parse_cronentry`; `date` is a date as constructed by
-- `unpack_time`. Checks if `cronentry` should fire at `date`.
local function match_cronentry_with_date(cronentry, date)
  local rv = cronentry.weekday[date.weekday] and cronentry.hour[date.hour] and
               cronentry.minute[date.minute] and cronentry.day[date.day] and
               cronentry.month[date.month]
  return not (not rv)
end

module.test.match_cronentry_with_date = match_cronentry_with_date

-- This function cannot be tested reliably in isolation!
--
-- module.test.unpack_time = unpack_time

-- `entry` is a cronentry as constructed by `parse_cronentry`.
-- Returns the next time which `entry` matches. Requires the
-- granularity of `os.time` to be at least seconds -- which
-- holds on POSIX, Windows and almost everywhere.
local function next_activation(entry)
  time = os.time() + 1 -- start in the future, not now

  -- round to next full minute
  time = time + 59
  time = time - time % 60

  while not match_cronentry_with_date(entry, unpack_time(time)) do
    time = time + 60
  end

  return time
end

-- This function cannot be tested reliably in isolation!
--
-- module.test.next_activation = next_activation

-- Cron daemon. The only user function. Entries is a list of
-- cron table entries, using similar conventions to crontab(5).
-- The fields `weekday`, `hour`, `minute`, `day`, `month` are
-- defined more precisely at the function `parse_cronentry`. The
-- field `callback` is a function that is run (without
-- arguments) as soon as the corresponding cron entry fires.
local function cron(entries, verbose)
  local extra = {}
  for i, v in pairs(entries) do
    extra[i] = {}
    extra[i].cronentry = parse_cronentry(v)
    extra[i].next_activation = next_activation(extra[i].cronentry)
    if verbose then
      print(string.format('Entry #%d is activated at %d', i,
                          extra[i].next_activation))
    end
  end

  -- main loop
  while true do
    -- find next entry to run
    local min = math.huge
    for i = 1, #extra do min = math.min(min, extra[i].next_activation) end

    -- list of indices into entries that are to be run next
    --
    -- this is necessary because several jobs could fire at
    -- the same time
    allNextEntries = {}

    for i, v in pairs(extra) do
      if v.next_activation == min then table.insert(allNextEntries, i) end
    end

    local sleepTime = math.max(min - os.time(), 0)
    local withS = 's'
    if sleepTime == 1 then withS = '' end

    if verbose then
      print(
        string.format('Activating next job in %d second%s', sleepTime, withS))
    end

    sleep(sleepTime)

    for _, i in pairs(allNextEntries) do
      extra[i].next_activation = next_activation(extra[i].cronentry)
      local when_next_activation = math.max(
                                     extra[i].next_activation - os.time(), 0)
      if verbose then
        print(string.format('Activating #%d; next activation in %d seconds', i,
                            when_next_activation))
      end

      entries[i].callback()
    end
  end
end

module.cron = cron

return module
