# iOS KPCommon Framework
[![iOS](https://img.shields.io/badge/ios-10.0+-lightgray.svg)](https://img.shields.io/badge/ios-10.0+-lightgray.svg)
[![Swift](https://img.shields.io/badge/swift-4.0-lightgray.svg)](https://img.shields.io/badge/swift-4.0-lightgray.svg)
[![CocoaPods](https://img.shields.io/badge/pod-true-blue.svg)](https://github.kakaocorp.com/kakaopay-client/ios-pay-common/blob/develop/KPCommon.podspec)
[![Build](https://img.shields.io/badge/build-tbd-red.svg)](https://mobil.daumkakao.io/#/app/979)

- "공동체깃헙" 저장소(private): https://github.kakaocorp.com/kakaopay-client/ios-pay-common
- "카카오깃헙" 미러 저장소(public): https://github.daumkakao.com/mirror/kakaopay-client_ios-pay-common

## 목적
카카오페이의 [Stand Alone앱](https://kakaopay.agit.in/g/300017571/wall)(이후 페이앱) 이 만들어 짐에 따라 톡과 페이앱 공통적으로 사용되는 코드를 묶어 유지보수의 장점을 누릴 수 있도록 하는 것이 주 목적입니다.

## 배포
톡과 페이앱 모두 pods 을 통하여 배포하는 것이 목표이며, 현재(2019년 2월 이터)는 페이앱에만 적용되어 있습니다.
[배포 가이드](https://github.kakaocorp.com/kakaopay-client/ios-pay-common/wiki/KPCommon-%EB%B0%B0%ED%8F%AC-%EA%B0%80%EC%9D%B4%EB%93%9C)

## 내용
### Internal Libraries
- KPCommon:
  - HTTPClient, File, Cache, Observable 등의 Core 라이브러리와 Extensions 유틸리티
  - ModalAnimator, Container, RemoteImageView, Overlay, Toast, Picker, DataCode 등의 UI 관련 라이브러리

### External Libraries (업체로 부터 직접 제공받는 외부 라이브러리들)
- KPFido: 생체인증 모듈 사용을 위한 wrapper class (업체의 dynamic framework 파일 2개 포함)
- KPNFilter: 암호화 키보드 사용을 위한 wrapper class (업체의 static lib(.a) 파일 포함)
- KPKInsight(?): 로그 수집을 위한 wrapper class. (예정)
- KPF2Pay(?): 오프라인 결제 모듈 사용을 위한 wrapper class. (예정)
- KPScrapping(?): 스크래핑 모듈 사용을 위한 wrapper class. (예정)

## 사용
### [카카오톡](https://github.kakaocorp.com/cooperation/kakaotalk-iphone-dev_KakaoTalk-Iphone)
KPCommon 에서 생성된 framework 파일들이 repository 안에 물리적으로 존재하고 KakaoTalk 타겟의 embedded binaries 에 추가되어 있습니다. 조만간 pods 을 통한 배포 방식으로 변경될 예정 입니다.

### [페이앱](https://github.kakaocorp.com/kakaopay-client/ios-pay-app/issues)
pods 을 통한 배포 방식을 사용합니다.

## 컨벤션
### 프로젝트 레벨
- KPCommon / KPFido / KPNFilter 등등 타겟 단위의 물리적인 폴더로 구성 되어 있으며 모듈 추가시 각각의 도메인에 맞는 폴더 하위에 위치 시킵니다.
- KPCommon 의 경우에는 KPCore / KPUI 로 폴더가 구분되어 있는데, 물리적인 폴더일 뿐이고 파일의 성격에 따라 위치 시키면 됩니다.
- Fido, NFilter 와 같은 외부 모듈은 wrapper 클래스와 함께 각각의 타겟으로 생성하는 것을 권장 합니다.

### 코드 레벨
- swift 로 작성하는 것을 원칙으로 하며, 디펜던시 문제로 부득히 하게 obj-c 를 사용하게 될 경우 swift wrapping 작업을 진행 하는 것을 원칙으로 합니다.
- Foundation 클래스에 대한 Extension 을 추가 하려는 경우, 이름 충돌과 불필요한 interface 노출을 피하기 위해 PayCompatible 을 컨펌하여 .pay 로 접근 되도록 하는 것을 권장 합니다.
- 세부적인 코딩 컨벤션은 페이앱에서 정한 내용과 동일합니다.
