# WalkieTalkie

Приложение для общения в режиме рации с помощью двух iPhone.

![wk](https://user-images.githubusercontent.com/4405543/202900735-051723e2-1d1a-4072-bd6f-b7e8f765b20c.PNG)

## Установка

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
