# Whatpulse (UNOFFICIAL)

Unofficial Noctalia Plugin to view your Whatpulse Stats from the local whatpulse database.

## Plugin

| Field | Value |
| --- | --- |
| ID | `Nubinator/whatpulse-plugin` |
| Entries | Bar widget: `keypress`, `clicks`, `download`, `upload`, `score` |

## Requirements

1. Whatpulse Account at [whatpulse.org](https://whatpulse.org/register)
2. Whatpulse Desktop [Client](https://whatpulse.org/downloads) **v5.6** or above.  
3. (Optional, only if you need network stats) Whatpulse [Network Service](https://github.com/whatpulse/linux-external-pcap-service)

## Usage

1) Download and login to the [Client](https://whatpulse.org/downloads)
2) Navigate to Client API section over on the Settings tab and enable the "Enable Client API" checkbox
3) Take note of the "WebSocket port" which you will need in the plugin settings page. (`3489` is the default so if you haven't changed it, you can probably skip this step)

## Setting

| Setting | Type | Default| Description |
| --- | --- | --- | --- |
| `WebSocket Port` | `string` | `3489` | Configured WebSocket Port in the Whatpulse Client |
| `Update Frequency` | `int` | `5` | The Frequency at which the widget updates in seconds. Min = 2, Recommended = 5, Max = 120 |


## FAQ

1) Why are my key presses and clicks not being counted?
- Make sure you have given the nessasary permissions to the whatpulse application. [Insturctions](https://whatpulse.org/help/docs/getting-started/installing-the-linux-client/)

2) What is the WebSocket used for, if the stats are taken from the database?
- The WebSocket is used for the click actions for the widget (ie. Right Click to open the whatpulse window and Left Click to Manually Pulse)