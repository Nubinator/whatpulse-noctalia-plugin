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
local function render(scrollsToday: number?)
  local count = scrollsToday or 0
  if count > 0 then
    local formattedCount = formatNumber(count)
    barWidget.setText(formattedCount)
    barWidget.setTooltip("Today's Scrolls: " .. formattedCount)
  else
    barWidget.setText("0")
    barWidget.setTooltip("No Scrolls recorded today")
  end
end

-- Fetch Clicks Strokes
local function fetchStats()
  local cmd = 'sqlite3 -readonly "$HOME/.local/share/WhatPulse/whatpulse.db" "SELECT COALESCE(SUM(count), 0) FROM mousescrolls WHERE day = DATE(\'now\', \'localtime\');" 2>/dev/null'
  noctalia.runAsync(cmd, function(result)
    local rawOutput = result and result.stdout or ""
    local count = tonumber(string.match(rawOutput, "^%s*(%d+)%s*$"))
    if count then
      render(count)
    end
  end)
end

-- Scrolls Widget
function update()
  local polling = noctalia.getConfig("polling_frequency")
  noctalia.setUpdateInterval((tonumber(polling))*1000)
  fetchStats()
  barWidget.setGlyph("mouse")
end

-- Pulse
function onClick()
  local wsport = noctalia.getConfig("websocket_port")
  noctalia.runAsync("echo '{\"source\":\"plugin\",\"action\":\"pulse\"}' | websocat ws://localhost:" .. wsport .." >/dev/null 2>&1", function() end)
  fetchStats()
end

-- Open Whatpulse
function onRightClick()
  local wsport = noctalia.getConfig("websocket_port")
  noctalia.runAsync("echo '{\"source\":\"plugin\",\"action\":\"open-window\"}' | websocat ws://localhost:" .. wsport .." >/dev/null 2>&1", function() end)
end

-- Initial render on load
fetchStats()