#!/bin/zsh
# 집에서는 충전 한도를 낮추고(기본 50%), 밖에서는 100% 까지 충전한다.
#
# 집 판정은 와이파이 이름(SSID) 대신 집 공유기 주소로 한다.
# macOS 가 위치 권한 없는 프로세스에는 SSID 를 가리고 "not associated" 를 내서 이름으로는 판정이 안 된다.
# 공유기가 바뀔 때만 동작한다. 같은 상태가 유지되면 아무것도 하지 않아서 직접 바꾼 값을 되돌리지 않는다.
#
# 역할 분담(실측):
# - 충전 한도: AlDente. 켜져 있어야 80% 아래 한도가 지켜진다(끄면 macOS 기본 한도만 남아 50% 에서 다시 충전됐다).
#   battery CLI 는 일부 펌웨어에 충전 차단 SMC 키(CHTE·CH0B·CH0C)가 없어 충전을 못 막는다.
# - 방전: battery CLI 의 전원 차단(CHIE). AlDente 가 켜져 있으면 약 100초 뒤 차단을 풀어 버리므로
#   방전하는 동안만 AlDente 를 끄고, 끝나면 다시 켠다.
CONFIG="$HOME/.config/battery-home/config"
HOME_GATEWAY=""
HOME_LIMIT=50
AWAY_LIMIT=100
[[ -f "$CONFIG" ]] && source "$CONFIG"
[[ -z "$HOME_GATEWAY" ]] && exit 0

STATE="$HOME/.battery-home-state"
BATTERY="/usr/local/bin/battery"
ALDENTE_ID="com.apphousekitchen.aldente-pro"

gw=$(ipconfig getoption en0 router 2>/dev/null)
if [[ "$gw" == "$HOME_GATEWAY" ]]; then cur="home"; else cur="away"; fi
prev=$(cat "$STATE" 2>/dev/null)
[[ "$cur" == "$prev" ]] && exit 0
echo "$cur" > "$STATE"

set_limit() {
  open -g -b "$ALDENTE_ID"
  sleep 5
  open -g "aldente://limit/$1"
}

if [[ "$cur" == "home" ]]; then
  set_limit "$HOME_LIMIT"
  # 한도는 충전만 멈춰서 충전기를 꽂은 채로는 그 자리에 머문다. 한도보다 높으면 방전을 따로 건다.
  pct=$(pmset -g batt | grep -Eo '[0-9]+%' | head -1 | tr -d '%')
  if [[ -n "$pct" && "$pct" -gt "$HOME_LIMIT" ]] && ! pgrep -f "battery discharge" >/dev/null; then
    # BATTERY_HELPER_MODE=1: 방전이 끝난 뒤 battery CLI 가 자기 유지 모드(maintain)를 되살리지 않게 한다.
    nohup zsh -c "
      osascript -e 'quit app id \"$ALDENTE_ID\"'
      sleep 3
      BATTERY_HELPER_MODE=1 '$BATTERY' discharge $HOME_LIMIT
      open -g -b '$ALDENTE_ID'
      sleep 5
      open -g 'aldente://limit/$HOME_LIMIT'
    " >/dev/null 2>&1 &
  fi
else
  pkill -f "battery discharge" 2>/dev/null
  "$BATTERY" adapter on
  set_limit "$AWAY_LIMIT"
fi
