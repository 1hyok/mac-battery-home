#!/bin/zsh
# LaunchAgent 와 설치한 스크립트를 걷어 낸다. 설정 파일과 AlDente·battery CLI 는 그대로 둔다.
LABEL="local.battery-home"
launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null
rm -f "$HOME/Library/LaunchAgents/$LABEL.plist" "$HOME/bin/battery-home.sh" "$HOME/.battery-home-state"
pkill -f "battery discharge" 2>/dev/null
/usr/local/bin/battery adapter on 2>/dev/null
echo "제거 완료"
