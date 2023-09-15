# 📔 일기장
프로젝트 기간: 2023.8.28 ~ 2023.9.15

## 📖 목차
1. [🍀 소개](#1.)
2. [👨‍💻 팀원](#2.)
3. [📅 타임라인](#3.)
4. [👀 시각화된 프로젝트 구조](#4.)
5. [💻 실행 화면](#5.)
6. [🪄 핵심 경험](#6.)
7. [🧨 트러블 슈팅](#7.)
8. [📚 참고 링크](#8.)

</br>

<a id="1."></a></br>
## 🍀 소개
일기를 생성, 수정, 삭제할 수 있는 앱
</br>

<a id="2."></a></br>
## 👨‍💻 팀원
| Max | hamg |
| :--------: | :--------: |
| <Img src = "https://hackmd.io/_uploads/B1FqbcBAn.png" width="200" height="200"> |<Img src="https://hackmd.io/_uploads/BknBM9rC2.jpg" width="200" height="200"> |
|[Github Profile](https://github.com/maxhyunm)|[Github Profile](https://github.com/hemg2) |


</br>

<a id="3."></a></br>
## 📅 타임라인
|날짜|내용|
|:--:|--|
|2023.08.28| `SwiftLint` 라이브러리 추가|
|2023.08.29| `SwiftLint` 조건 변경 |
|2023.08.30| `DiaryEntity` `CreateDiaryViewController `생성<br> `keyboard` `NotificationCenter` 생성 및 구현 | 
|2023.09.01| `CoreData`: `Create` 구현|
|2023.09.05| `CoreData`: `UpDate`, `Delete` 구현 <br> `Swipe` `share`, `delete` 구현 <br> `AlertController` 생성  |
|2023.09.06| `CoreData`: `fetchDiary` 구현 |
|2023.09.07| 개인 학습 및 `README` 작성 |
|2023.09.10| `CoreDataError` 생성, 예외처리 추가<br>`AlertVC`로직수정, `Namespace`생성 |
|2023.09.13| `WeatherAPI`통신 진행<br> `WeatherIcon Cache` 구현 <br> `CoreLocation` 생성 <br> `Migration-DiaryV2` 구현 |


</br>

<a id="4."></a></br>
## 👀 시각화된 프로젝트 구조
### FileTree
    ├── Diary
    │   ├── Protocol
    │   │   ├── AlertDisplayble.swift
    │   │   └── ShareDisplayable.swift
    │   ├── Extension
    │   │   └── DateFormatter+.swift
    │   ├── Error
    │   │   ├── APIError.swift
    │   │   ├── CoreDataError.swift
    │   │   └── DecodingError.swift
    │   ├── Model
    │   │   ├── CoreData
    │   │   │   ├── CoreDataManager.swift
    │   │   │   ├── Diary+CoreDataClass.swift
    │   │   │   └── Diary+CoreDataProperties.swift
    │   │   ├── DTO
    │   │   │   ├── DecodingManager.swift
    │   │   │   └── WeatherResult.swift
    │   │   ├── ImageCache
    │   │   │   └── ImageCachingManager.swift
    │   │   └── Namespace
    │   │       ├── AlertNamespace.swift
    │   │       └── ButtonNamespace.swift
    │   ├── Network
    │   │   ├── NetworkConfiguration.swift
    │   │   └── NetworkManager.swift
    │   ├── Controller
    │   │   ├── DiaryDetailViewController.swift
    │   │   └── DiaryListViewController.swift
    │   ├── View
    │   │   └── DiaryListTableViewCell.swift
    │   ├── App
    │   │   ├── AppDelegate.swift
    │   │   └── SceneDelegate.swift
    │   ├── Assets.xcassets
    │   ├── Info.plist
    │   └── Diary.xcdatamodeld
    ├── Diary.xcodeproj
    └── README.md

</br>

<a id="5."></a></br>
## 💻 실행 화면

| 작동화면 |
|:--:|
|<img src="https://hackmd.io/_uploads/H1kYxge1T.gif" width="300"/>|

</br>

<a id="6."></a></br>
## 🪄 핵심 경험
#### 🌟 CoreData를 활용한 데이터 저장
일기 데이터를 위한 저장소로 CoreData를 활용하였습니다.
#### 🌟 MappingModel 파일을 활용한 CoreData Migration 진행
CoreData의 버전 정보를 추가하고 이를 MappingModel로 연결하여 DB 변경사항에 대한 Migration을 진행하였습니다.
#### 🌟 Singleton 패턴을 활용한 CoreDataManager 구현
데이터 처리를 위한 로직 전반을 Singleton 패턴으로 구현하여 앱 전역에서 활용 가능하도록 하였습니다.
#### 🌟 NotificationCenter를 활용한 키보드 인식
키보드 활성화 여부에 따라 뷰의 크기를 변경하여 커서 위치가 가려지지 않도록 NotificationCenter를 활용하였습니다.
#### 🌟 여러 개의 생성자를 통한 상황별 데이터 전달
상황에 따라 ViewController에서 다른 데이터를 표시해야 하는 경우에 대비해 생성자를 활용하였습니다.
#### 🌟 Protocol과 Extension을 활용한 코드 분리
Alert, Swipe 등 별개의 작업으로 분리할 수 있는 내용들은 Protocol과 Extension을 통해 분리하였습니다.
#### 🌟 URLSessionDataTask를 활용한 NetworkManager 구현
하나의 NetworkManager 타입을 구현하여 날씨 API 데이터 통신과 아이콘 이미지 관련 통신에 모두 활용하였습니다.

</br>

<a id="7."></a></br>
## 🧨 트러블 슈팅

### 1️⃣ **반복적인 날짜 포매팅 처리**
🔒 **문제점** </br>
 일기 리스트 화면과 새로운 일기를 생성하는 화면에서 모두 아래와 같이 날짜 포매팅을 사용해야 하는 것을 알 수 있었습니다.
```swift
 private let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_kr")
    formatter.dateFormat = "yyyy년MM월dd일"
    return formatter
}()
```
동일한 코드가 두 개의 `ViewController`에서 반복되어 사용하고 있었으며
반복되는 것을 막기 위해 해당 코드를 분리하고자 했습니다.
</br></br>

🔑 **해결방법** </br>
저장 프로퍼티가 아닌 메서드로 사용하여 재사용성을 높히게 되었습니다.
```swift
extension DateFormatter {
    func formatToString(from date: Date, with format: String) -> String {
        self.dateFormat = format
        
        return self.string(from: date)
    }
}

DateFormatter().formatToString(from: entity.createdAt, with: "YYYY년 MM월 dd일")
```
</br>

### 2️⃣ **화면이 꺼질 때 자동 저장 처리**
🔒 **문제점**</br>
요구사항에 따르면 사용자가 화면을 벗어날 때마다 자동 저장을 진행해야 했습니다. 이를 구현하기 위해 처음에는 `CreateViewController`의 `viewWillDisappear` 메서드에서 저장처리를 진행할 수 있도록 작업했습니다.
```swift
override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    saveDiary()
}
```
하지만 이렇게 하니 일기 삭제 처리를 한 뒤 뷰컨트롤러를 pop할 때에도 저장처리를 거치게 되어 오류가 발생하였습니다.
</br></br>

🔑 **해결방법**</br>
`TextView`가 수정될 때마다 뷰컨트롤러가 가지고 있는 일기 객체의 내용을 바꿔주고, 저장이 필요한 순간에 `saveContext` 처리만 진행할 수 있도록 아래와 같이 구현하였습니다.
```swift
func textViewDidChange(_ textView: UITextView) {
    let contents = textView.text.split(separator: "\n")
    guard !contents.isEmpty,
          let title = contents.first else { return }

    let body = contents.dropFirst().joined(separator: "\n")

    diary.title = "\(title)"
    diary.body = body
}
```
</br>

### 3️⃣ **빈 일기가 저장되는 현상**
🔒 **문제점(1)**</br>
처음에는 키보드가 비활성화되면 무조건 내용을 저장하도록 구현을 하였습니다. 하지만 이렇게 하니, 신규 생성 버튼(+)을 누른 뒤 아무런 내용도 입력하지 않고 뒤로 가기 처리를 하면 제목과 내용이 모두 비어있는 일기가 생성이 되었습니다.
```swift
func textViewDidEndEditing(_ textView: UITextView) {
    CoreDataManager.shared.saveContext()
}
```
|빈일기 생성 화면|
|:--:|
|<img src="https://cdn.discordapp.com/attachments/1148871276677562388/1148871347871686706/3639304423dabd43.gif" width="200" height="400"/>|

</br></br>

🔑 **해결방법(1)**</br>
빈 일기가 생성되는것을 막기 위해 title 이 없을 경우 저장 되지 않게 진행하였습니다.
```swift
func textViewDidEndEditing(_ textView: UITextView) {
        let contents = textView.text.split(separator: "\n")
        guard !contents.isEmpty else { return }
        
        CoreDataManager.shared.saveContext()
    }
```
</br></br>
🔒 **문제점(2)**</br>
위의 처리를 통해 더 이상 데이터베이스에 빈 일기가 저장되지는 않았지만, saveContext 되지 않은 객체가 여전히 context 내부에 남아 일시적으로 빈 일기가 리스트에 보이는 현상이 생겼습니다. 
```swift
func readCoreData() {
        do {
            diaryList = try container.viewContext.fetch(Diary.fetchRequest())
            tableView.reloadData()
        } catch {
           ....
        }
    }
```
</br></br>

🔑 **해결방법(2)**</br>
fetch해 온 일기들 중에 title이 비어있는 건은 걸러낼 수 있도록 filter 처리를 추가하였습니다.
```swift
 private func readCoreData() {
        do {
            let fetchedDiaries = try CoreDataManager.shared.fetchDiary()
            diaryList = fetchedDiaries.filter { $0.title != nil }
            tableView.reloadData()
        } catch {
           .....
        }
    }
```
</br></br>

### 4️⃣ **아이콘 이미지 통신**
🔒 **문제점**</br>
일기장 앱은 모든 셀이 서버통신을 통해 아이콘을 가지고 오도록 구현되어 있습니다. 하지만 날씨 아이콘은 몇 개의 정해진 아이콘을 반복하여 활용합니다. 따라서 동일한 이미지를 매번 통신을 통해 가져오는 것은 비효율적이라고 생각되었습니다.
</br></br>

🔑 **해결방법**</br>
한 번 활용된 이미지는 `NSCache`를 통해 캐싱 처리하여 바로 보여줄 수 있도록 구현하였습니다.

```swift
class ImageCachingManager {
    static let shared = NSCache<NSString, UIImage>()
   ...
}
```

```swift
guard let image = UIImage(data: data) else { return }
DispatchQueue.main.async {
    ImageCachingManager.shared.setObject(image, forKey: NSString(string: icon))
    self?.weatherIconImageView.image = image
}
```
</br></br>

### 5️⃣ **CoreLocation**
🔒 **문제점 (1) - CoreLocation을 통해 정보를 받아오는 위치**</br>

실질적으로 Location 정보가 필요한 것은 `DiaryDetailViewController`에서 날씨 API를 호출할 때입니다. 때문에 처음에는 `DiaryDetailViewController`에서 활용 동의를 받고 위치 정보를 업데이트하도록 구현하려 하였습니다. 하지만 이렇게 하면 앱을 실행한 뒤 일기장 생성 화면에 넘어가서야 위치정보 활용 동의 창이 활성화되어 흐름상 어색해지고, 또 위치 정보가 제때 업데이트되지 않아 API 호출이 이루어지지 않는 등 다양한 문제가 발생했습니다.
</br></br>

🔑 **해결방법 (1)**</br>
위치 정보 업데이트 자체는 첫 화면인 `DiaryListViewController`에서 진행하고, `DiaryDetailViewController`에서는 API 통신에 필요한 위도, 경도 데이터만 넘겨받을 수 있도록 구현하였습니다.
```swift
let createDiaryView = DiaryDetailViewController(latitude: self.latitude, longitude: self.longitude)
self.navigationController?.pushViewController(createDiaryView, animated: true)
```

또한 위치정보 활용에 동의하지 않은 경우에도 일기 자체는 작성 가능하도록 구현하기 위해(날씨 이모티콘만 제외) 위도, 경도 데이터는 nil로도 전달될 수 있도록 하였습니다.

```swift
init(latitude: Double?, longitude: Double?) {
    self.diary = CoreDataManager.shared.createDiary()
    self.isNew = true
    self.latitude = latitude
    self.longitude = longitude

    super.init(nibName: nil, bundle: nil)
    fetchWeather()
}
```
</br></br>

🔒 **문제점 (2) - 시뮬레이터의 위치 정보 설정**</br>

시뮬레이터로 `CoreLocation` 기능을 테스트하면 시뮬레이터 자체에 설정된 Location 정보에 따라 위치를 표시하게 됩니다. 따라서 이 설정이 None으로 되어있을 경우에는 위치가 정상적으로 불러와지지 않습니다. 이 사실을 간과하여 테스트 과정에서 많은 시행착오를 거쳤습니다.
</br></br>

🔑 **해결방법 (2)**</br>

Custom Location을 활용하여 정상적으로 테스트를 진행할 수 있었습니다.</br>
<img src="https://hackmd.io/_uploads/BJ20Xkgyp.png" width="500">
</br>


<a id="8."></a></br>
## 📚 참고 링크

- [Apple Docs: Adaptivity and Layout](https://developer.apple.com/design/human-interface-guidelines/layout)
- [Apple Docs: DateFormatter](https://developer.apple.com/documentation/foundation/dateformatter)
- [Apple Docs: UITextView](https://developer.apple.com/documentation/uikit/uitextview) 
- [Apple Docs: Core Data](https://developer.apple.com/documentation/coredata) 
- [Apple Docs: Making Apps with Core Data](https://developer.apple.com/videos/play/wwdc2019/230/)
- [Apple Docs: NSFetchedResultsController](https://developer.apple.com/documentation/coredata/nsfetchedresultscontroller)
- [Apple Docs: UITextViewDelegate](https://developer.apple.com/documentation/uikit/uitextviewdelegate)
- [Apple Docs: UISwipeActionsConfiguration](https://developer.apple.com/documentation/uikit/uiswipeactionsconfiguration)
- [Apple Docs: CoreLocation](https://developer.apple.com/documentation/corelocation)
- [Apple Docs: Migrating your data model automatically](https://developer.apple.com/documentation/coredata/migrating_your_data_model_automatically)
- [Apple Docs: NSCache](https://openweathermap.org/current)
- [Open Weather API](https://openweathermap.org/current)

</br>

