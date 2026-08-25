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
local function render(scoreToday: number?)
  local count = scoreToday or 0
  if count > 0 then
    local formattedCount = formatNumber(count)
    barWidget.setText(formattedCount)
    barWidget.setTooltip("Today's Score: " .. formattedCount)
  else
    barWidget.setText("0")
    barWidget.setTooltip("No Clicks/Keypresses recorded today")
  end
end

-- Fetch (Clicks * 3 ) + (Keys)
local function fetchStats()
  local cmd = 'sqlite3 -readonly "$HOME/.local/share/WhatPulse/whatpulse.db" "SELECT (SELECT (COALESCE(SUM(count), 0)*3) FROM mouseclicks WHERE day = DATE(\'now\', \'localtime\'))+(SELECT (COALESCE(SUM(count), 0)*1) FROM keypresses WHERE day = DATE(\'now\', \'localtime\'))[32  7141];" 2>/dev/null'

  noctalia.runAsync(cmd, function(result)
    local rawOutput = result and result.stdout or ""
    local count = tonumber(string.match(rawOutput, "^%s*(%d+)%s*$"))
    if count then
      render(count)
    end
  end)
end

-- Score Widget
function update()
  local polling = noctalia.getConfig("polling_frequency")
  noctalia.setUpdateInterval((tonumber(polling))*1000)
  fetchStats()
  barWidget.setGlyph("stars")
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