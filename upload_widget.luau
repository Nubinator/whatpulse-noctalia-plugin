-- Format bytes
local function formatBytes(bytes: number): string
  if bytes >= 1073741824 then
    return string.format("%.2f GB", bytes / 1073741824)
  elseif bytes >= 1048576 then
    return string.format("%.2f MB", bytes / 1048576)
  elseif bytes >= 1024 then
    return string.format("%.2f KB", bytes / 1024)
  else
    return tostring(bytes) .. " B"
  end
end

-- Hover Display
local function render(uploadToday: number?)
  local bytes = uploadToday or 0
  local formatted = formatBytes(bytes)

  barWidget.setText(formatted)
  barWidget.setTooltip("Today's Upload: " .. formatted)
end

-- Fetch Upload Stats
local function fetchStats()
  local cmd = 'sqlite3 -readonly "$HOME/.local/share/WhatPulse/whatpulse.db" "SELECT COALESCE(SUM(upload), 0) FROM network_interface_bandwidth WHERE day = DATE(\'now\', \'localtime\');" 2>/dev/null'

  noctalia.runAsync(cmd, function(result)
    local rawOutput = result and result.stdout or ""
    local bytes = tonumber(string.match(rawOutput, "^%s*(%d+)%s*$"))
    if bytes then
      render(bytes)
    end
  end)
end

-- Upload Widget
function update()
  noctalia.setUpdateInterval(5000)
  barWidget.setGlyph("upload")
  fetchStats()
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

-- Initial render
fetchStats()