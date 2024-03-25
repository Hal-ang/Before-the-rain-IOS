<p align="center">
	<img src="https://github.com/Hal-ang/Before-the-rain-server/assets/68503014/77578c4b-6b1d-4438-8abd-c70ab5088775" width="80" align="center">
</p>


<h1 align="center">비가 오기 전에 - IOS</h1>

[앱스토어 링크](https://apps.apple.com/app/%EB%B9%84%EA%B0%80-%EC%98%A4%EA%B8%B0-%EC%A0%84%EC%97%90/id6479691792)

### @everyone 이런 적.... 있으시죠?

<br>

**#1**

👩🏼‍🦳: 어? 오늘 비 온다 했어요?

🧑: 네 예보에서 비 온다더라고요

👩🏼‍🦳: 아…..

<br>

<br>

**#2**

👩🏼‍🦳: (오늘은 대충 이거 입고 나가야지..)

*외출 후*

👩🏼‍🦳: 아..큰일 났다 엄청 춥네..

<br>

<br>

**#3**

👩🏼‍🦳: (우중충 하긴 한데.. 몰라 정신 없어 일단 출근 해)

*지하철 출구 앞*

👩🏼‍🦳 : 아…..비 오네……….

---



### 귀찮은 당신을 위해 준비했습니다!

### **비가 오기 전에** 강수량을 확인하고, 오늘의 옷차림을 확인하세요!

- 맞춤 설정을 통해 날씨 알람을 받아 볼 수 있어요!
    - 시간대 별 미리 알림 / 요약 알림
- 옷차림 고민은 그만! 기온에 맞는 옷차림도 확인할 수 있어요!



<br>

## 주요 기능 설명


### 1. 알림 설정
![survey](https://github.com/Hal-ang/Before-the-rain-client/assets/68503014/4b267368-dc00-47b7-be6d-813a4ae4e5e8) | ![push](https://github.com/Hal-ang/Before-the-rain-server/assets/68503014/08423474-6d16-4add-9877-de3a13be8dc3)
--- | --- |



맞춤 설문을 통해 입맛에 맞게 알람을 설정할 수 있어요!

- 시간대 별 푸시 알림
- 요약 알림

현재 두 가지 알림을 지원합니다!

<br>


### 2. 날씨와 옷차림 확인

<p align="center">
	<img src="https://github.com/Hal-ang/Before-the-rain-client/assets/68503014/d51d66ea-f214-4386-ad28-65f5cf60d2db" align="center" width="33%">
</p>


오늘의 날씨와 강수량을 간단하게 확인할 수 있어요!

기온별 옷차림을 빠르게 확인하고 계절 감각을 유지하세요!

<br>

### 3. IOS 위젯

![image.jpg1](https://d1j05o5l6xx0ft.cloudfront.net/IMG_0728.jpg) |![image.jpg2](https://d1j05o5l6xx0ft.cloudfront.net/IMG_0694.jpg)
--- | --- |

위젯을 통해 시간 단위로 현재 위치의 날씨 정보와 옷차림을 확인할 수 있어요!

<br>

<br>

## 프로젝트 설명 ( IOS 웹뷰 앱 )

### 1. 제작 배경
평소에 날씨 확인을 잘 안하다 보니 운에 모든 걸 맡기곤 했습니다.
서두에 서술한 과거 회상은 제 이야기입니다.

갖고 있는 우산을 다 합치면 족히 10개는 될 것 같습니다.
더불어 계절 감각도 없는데 추위는 또 많이 타는 바람에 혼자 추운 날도 많은 편입니다.

여유가 있을 땐 외출 전 '기온 별 옷차림'을 검색하고 오늘 날씨와 비교하며 옷을 고르곤 했는데 이 과정이 항상 귀찮았고, 그냥 위젯으로 바로 보면 편하지 않을까 하는 생각에 바로 기획을 시작했습니다.

<br>

### 2. 규모 및 구동 방식
참여 인원 - 1명
작업 기간 - 14일 (기획 ~ 앱스토어 심사 요청)
구동 방식 -  스위프트 기반 IOS 웹뷰 앱

<br>

### 3. 사용 기술

**3-1. 🌏 인프라** 
|-|스택|
|------|---|
|CDN (에셋, 폰트 관리) |CloudFront, S3|
|서버 배포|EC2, RDS, Route53, ACM (AWS certificate Manager)|
|클라이언트 배포| Vercel |

<br>

**3-2. 📱 IOS** - [IOS Repo](https://github.com/Hal-ang/Before-the-rain-IOS)
|-|스택|
|------|---|
|언어|Swift|
|웹뷰|WKWebview|

- 디바이스 권한 처리 (위치 정보, 푸시 알림)
- 위젯 기능 (http 통신 + xcode WidgetExtension + 백그라운드 위치 정보 확인)
- 위젯 제외, 앱 스크린 전체 웹뷰 구현

<br>

**3-3. 🎇 클라이언트** - [Client Repo](https://github.com/Hal-ang/Before-the-rain-client) 
|-|스택|
|------|---|
|렌더 도구| React, NextJS (v14)|
|언어|Typescript|
|스타일링|TailwindCSS|
|상태 관리|React-Query, Jotai|
|개발 도구| Storybook (+Chromatic), MSW (+Express), SVGR|
|번들러|Webpack|

- SSR 기반
- 네이티브와의 브릿지 통신 (디바이스 권한 처리, 유저 위치 정보, fcm토큰)
- 스토리북 기반 크로마틱 배포 환경 구성 (+ github Actions)
	- [스토리 북 URL](https://65ef57f9ccb44b74669d9b0b-flbhhlqmrm.chromatic.com/?path=/docs/common-checkbox--docs)
	- [크로마틱 URL ](https://www.chromatic.com/builds?appId=65ef57f9ccb44b74669d9b0b)

<br>

**3-4. 🎛️ 서버** - [Server Repo](https://github.com/Hal-ang/Before-the-rain-server) 

|-|스택|
|------|---|
|런타임 / 프레임워크 | Node, NestJS|
|언어|Typescript|
|DB|Mysql|
|ORM|TypeORM|
|푸시 알림|Firebase admin|

- 위치 기반 날씨 정보 제공 (openWeather API)
- Nest 스케줄러를 이용한 유저 별 fcm 푸시 알림

[API 명세](https://documenter.getpostman.com/view/33447528/2sA358e5qA)

