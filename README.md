# mac-battery-home

맥북을 집에서는 충전 한도 50% 로, 밖에서는 100% 까지 충전하도록 자동 전환한다.

## 구성

- `battery-home.sh`: 공유기 주소로 집/밖을 판정하고 한도를 바꾼다. 집에서 한도보다 높으면 방전한다.
- `install.sh`: 스크립트를 `~/bin` 에 두고 1분마다 도는 LaunchAgent 를 등록한다.
- `uninstall.sh`: LaunchAgent 와 스크립트를 걷어 낸다.

## 필요한 것

- [AlDente](https://apphousekitchen.com/): 충전 한도를 지킨다. 로그인 항목에 넣어 항상 켜 둔다.
- [battery CLI](https://github.com/actuallymentor/battery): 방전(전원 차단)에 쓴다. 설치할 때 관리자 비밀번호가 필요하다.

## 설치

```bash
./install.sh
```

집 공유기 주소는 `~/.config/battery-home/config` 의 `HOME_GATEWAY` 에 적는다. 설치 때 지금 연결된 공유기 주소를 기본값으로 넣는다. 한도는 `HOME_LIMIT`, `AWAY_LIMIT` 으로 바꾼다.

## 알려진 한계

- 판정은 공유기 주소(IP)로 한다. 공유기 주소가 바뀌면 설정을 고쳐야 한다.
- 집에서 방전이 시작되면 그동안 AlDente 를 끈다. 방전이 끝나고 다시 켜지는 사이 한두 퍼센트가 다시 오를 수 있다.
- 재부팅 중 방전은 이어지지 않는다.
- macOS 업데이트 뒤에는 battery CLI 의 SMC 키가 바뀔 수 있으니 `battery status` 로 확인한다.
- 이 맥의 펌웨어에서 확인한 내용이다. 다른 맥에서는 다르게 동작할 수 있다.
