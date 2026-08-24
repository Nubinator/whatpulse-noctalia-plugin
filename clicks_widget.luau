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
local function render(clicksToday: number?)
  local count = clicksToday or 0
  if count > 0 then
    local formattedCount = formatNumber(count)
    barWidget.setText(formattedCount)
    barWidget.setTooltip("Today's Clicks: " .. formattedCount)
  else
    barWidget.setText("0")
    barWidget.setTooltip("No Clicks recorded today")
  end
end

-- Fetch Clicks Strokes
local function fetchStats()
  local cmd = 'sqlite3 -readonly "$HOME/.local/share/WhatPulse/whatpulse.db" "SELECT COALESCE(SUM(count), 0) FROM mouseclicks WHERE day = DATE(\'now\', \'localtime\');" 2>/dev/null'

  noctalia.runAsync(cmd, function(result)
    local rawOutput = result and result.stdout or ""
    local count = tonumber(string.match(rawOutput, "^%s*(%d+)%s*$")) or 0
    render(count)
  end)
end

-- Mouse Widget
function update()
  noctalia.setUpdateInterval(2000)
  fetchStats()
  barWidget.setGlyph("mouse")
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