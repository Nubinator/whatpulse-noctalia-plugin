-- Add commas to the number
local function formatNumber(n: number): string
  local formatted = tostring(n)
  while true do
    local k
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
    if k == 0 then break end
  end
  return formatted
end

-- Hover Display
local function render(keysToday: number?)
  local count = keysToday or 0
  if count > 0 then
    local formattedCount = formatNumber(count)
    barWidget.setText(formattedCount)
    barWidget.setTooltip("Today's Keypresses: " .. formattedCount)
  else
    barWidget.setText("0")
    barWidget.setTooltip("No Keypresss recorded today")
  end
end

-- Fetch Key Storkes
local function fetchStats()
  local cmd = 'sqlite3 -readonly "$HOME/.local/share/WhatPulse/whatpulse.db" "SELECT COALESCE(SUM(count), 0) FROM keypresses WHERE day = DATE(\'now\', \'localtime\');" 2>/dev/null'

  noctalia.runAsync(cmd, function(result)
    local rawOutput = result and result.stdout or ""
    local count = tonumber(string.match(rawOutput, "^%s*(%d+)%s*$")) or 0
    render(count)
  end)
end

-- Key Widget
function update()
  noctalia.setUpdateInterval(2000)
  fetchStats()
  barWidget.setGlyph("keyboard")
end

-- Pulse
function onClick()
  noctalia.runAsync("echo '{\"source\":\"plugin\",\"action\":\"pulse\"}' | websocat ws://localhost:3489 >/dev/null 2>&1", function() end)
  fetchStats()
end

-- Open Whatpulse
function onRightClick()
  noctalia.runAsync("echo '{\"source\":\"plugin\",\"action\":\"open-window\"}' | websocat ws://localhost:3489 >/dev/null 2>&1", function() end)
end

-- Initial render on load
fetchStats()