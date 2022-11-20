# WalkieTalkie

Приложение для общения в режиме рации с помощью двух iPhone.

![wk](https://user-images.githubusercontent.com/4405543/202902129-da0f9b6a-93d2-450a-a0b6-a8569d8cf736.PNG)

## Развертывание

- Клонировать проект: `git clone https://github.com/RuslanIskhakov/WalkieTalkie`
- Настроить зависимости проекта: `pod install`
- Открыть файл `WalkieTalkie.xcworkspace` в X code

## Советы по использованию
- Для работы приложения требуется сеть Wi-Fi
- Если в качестве сети Wi-Fi используется Personal Hotspot, IP-адрес iPhone, на котором включена Personal Hotspot, будет иметь последний четвертый октет равный 1: `xxx.xxx.xxx.1`

## Технологический стек
- Swift
- CocoaPods
- UIKit
- WebSockets (server/client)
- RxSwift
- MVVM
- Core Audio
- Core Location
