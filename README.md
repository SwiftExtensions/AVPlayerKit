# AVPlayerKit

AVPlayerKit — набор расширений и UI-компонентов для построения медиаплееров на базе `AVFoundation`. Пакет упрощает работу с `AVPlayer`, предоставляет готовые представления управления воспроизведением и инструменты для интеграции с системным `Now Playing` и `MPRemoteCommandCenter`.

## Возможности
- **Расширения AVFoundation**. Удобные инициализаторы и вспомогательные методы для `AVPlayer`, `AVPlayerItem` и `AVAsset`.
- **Контроллер плеера**. `PlayerViewController` объединяет `PlayerView`, `PlayerStatusView` и `PlayerControlsView` для быстрого создания интерфейса воспроизведения.
- **Статусы и задержки**. `PlayerStatusView` выводит состояние плеера, а `PlayerStallsObserver` отслеживает буферизацию.
- **Now Playing**. `NowPlayingInfoBuilder` подготавливает словарь для `MPNowPlayingInfoCenter`.
- **Дистанционное управление**. `RemoteCommandCenter` регистрирует действия в `MPRemoteCommandCenter`.

## Установка

### Swift Package Manager

Добавьте зависимость в `Package.swift` проекта:

```swift
dependencies: [
    .package(url: "https://github.com/<your-org>/AVPlayerKit.git", branch: "main")
]
```

и подключите продукт `AVPlayerKit` к целевой сборке:

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "AVPlayerKit", package: "AVPlayerKit")
    ]
)
```

## Быстрый старт

```swift
import AVFoundation
import AVPlayerKit

let urlString = "https://example.com/video.mp4"
guard let player = AVPlayer(urlString: urlString) else {
    return
}

player.play()
```

`AVPlayer(urlString:)` вернёт `nil`, если передан некорректный URL.

## Использование `PlayerViewController`

```swift
import AVPlayerKit

// Инициализируем `AVPlayer` медиапотоком, который требуется воспроизвести.
let player = AVPlayer(url: streamURL)
// Создаём `PlayerViewController` и привязываем к нему плеер.
let playerViewController = PlayerViewController()
playerViewController.playerView.player = player
// Включаем встроенную кнопку AirPlay.
playerViewController.enableRoutePickerView()

// Добавляем контроллер плеера в текущую иерархию `UIViewController`.
addChild(playerViewController)
view.addSubview(playerViewController.view)
// Растягиваем представление плеера на всю область и завершаем добавление контроллера.
playerViewController.view.frame = view.bounds
playerViewController.didMove(toParent: self)
```

`PlayerViewController` автоматически отслеживает состояние `AVPlayer`, отображает ошибки и анимацию буферизации.

## AVRoutePickerView

![Демонстрация AVRoutePickerView](Images/av-route-picker-view-demo.gif)

```swift
import AVPlayerKit

let playerViewController = PlayerViewController()
playerViewController.enableRoutePickerView()
```

`AVRoutePickerView` автоматически отслеживает наличие нескольких доступных маршрутов воспроизведения и отображает список доступных маршрутов при необходимости.

## Интеграция с Now Playing

![Демонстрация Now Playing](Images/now-playing-info-demo.gif)

```swift
import MediaPlayer
import AVPlayerKit

var nowPlaying = NowPlayingInfoBuilder(title: "AVPlayer Demo", artist: "Bridge TV")
nowPlaying.mediaType = .video
nowPlaying.setArtwork(UIImage(named: "cover"))

MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlaying.build()
```

`NowPlayingInfoBuilder` поддерживает установку обложки через `UIImage` или `Data` и флаг прямого эфира `isLiveStream`.

## Дистанционное управление воспроизведением

```swift
import AVPlayerKit

let remoteCommandCenter = RemoteCommandCenter()

// Регистрируем обработчик команды воспроизведения.
remoteCommandCenter.addAction(\.playCommand) { _ in
    // Запускаем воспроизведение при сигнале от внешнего пульта.
    player.play()
    return .success
}

// Регистрируем обработчик команды паузы.
remoteCommandCenter.addAction(\.pauseCommand) { _ in
    // Приостанавливаем воспроизведение при сигнале от внешнего пульта.
    player.pause()
    return .success
}
```

При необходимости отключите обработчики, например, в `deinit` контроллера.

```swift
deinit {
    remoteCommandCenter.removeAction(\.playCommand)
    remoteCommandCenter.removeAction(\.pauseCommand)
}
```

Чтобы временно отключить ответ на команды без удаления обработчиков, установите `isEnabled = false`:

```swift
remoteCommandCenter.isEnabled = false
// ... выполняем действия, во время которых не нужно реагировать на команды.
remoteCommandCenter.isEnabled = true
```

## Диагностика потоков

```swift
import AVFoundation
import AVPlayerKit

let asset = AVAsset(url: streamURL)
asset.validate { error in
    if let error {
        print(error.localizedDescription)
    }
}
```

Метод `validate(completion:)` проверяет готовность потока к воспроизведению и защищённость контента.

## Аналитика просмотра

```swift
if let watched = player.currentItem?.durationWatched() {
    print("Просмотрено: \(watched) секунд")
}
```

`durationWatched()` суммирует длительность просмотра по данным `AVPlayerItemAccessLog`.

## Документация

Дополнительные материалы находятся в каталоге `Sources/AVPlayerKit.docc/`. Откройте проект в Xcode и соберите документацию через **Product → Build Documentation**.
