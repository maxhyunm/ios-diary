//
//  DiaryDetailViewController.swift
//  Diary
//
//  Created by Maxhyunm, Hamg on 2023/08/29.
//

import UIKit

final class DiaryDetailViewController: UIViewController, ShareDisplayable {
    private let textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = .preferredFont(forTextStyle: .body)
        
        return textView
    }()
    
    private let diaryManager: DiaryManager<Diary>
    private var diary: Diary
    private var isNew: Bool
    private var latitude: Double?
    private var longitude: Double?
    
    init(latitude: Double?, longitude: Double?, diaryManager: DiaryManager<Diary>) {
        self.diaryManager = diaryManager
        self.diary = diaryManager.createDiary()
        self.isNew = true
        self.latitude = latitude
        self.longitude = longitude
        
        super.init(nibName: nil, bundle: nil)
        fetchWeather()
    }
    
    init(_ diary: Diary, diaryManager: DiaryManager<Diary>) {
        self.diaryManager = diaryManager
        self.diary = diary
        self.isNew = false
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupBodyText()
        setupNavigationBarButton()
        setupNotification()
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        self.title = dateFormatter.string(from: diary.createdAt ?? Date())
        view.addSubview(textView)
        textView.delegate = self
        
        if isNew {
            textView.becomeFirstResponder()
        }
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    private func setupBodyText() {
        guard let title = diary.title,
              let body = diary.body else {
            return
        }
        
        textView.text = "\(title)\n\(body)"
        setupFontStyle(title: title, body: body)
    }
    
    private func splitTitleAndBody() -> (title: String, body: String) {
        let contents = textView.text.components(separatedBy: "\n")
        guard !contents.isEmpty,
              let title = contents.first else {
            return (title: "", body: "")
        }
        
        let body = contents.dropFirst().joined(separator: "\n")
        
        return (title: title, body: body)
    }
    
    private func setupFontStyle(title: String, body: String) {
        let attributeString = NSMutableAttributedString(string: textView.text)
        attributeString.addAttribute(.font,
                                     value: UIFont.preferredFont(forTextStyle: .title1),
                                     range: (textView.text as NSString).range(of: title))
        attributeString.addAttribute(.font,
                                     value: UIFont.preferredFont(forTextStyle: .body),
                                     range: (textView.text as NSString).range(of: body))
        textView.attributedText = attributeString
    }
    
    private func setupNavigationBarButton() {
        let moreButton = UIBarButtonItem(title: NSLocalizedString("moreOptions", comment: ""),
                                         style: .plain,
                                         target: self,
                                         action: #selector(showMoreOptions))
        navigationItem.rightBarButtonItem = moreButton
    }
    
    private func setupNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil
        )
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil
        )
    }
    
    private func showDeleteAlert() {
        let alertBuilder = AlertBuilder(viewController: self, prefferedStyle: .alert)
        alertBuilder.setType(.delete)
        alertBuilder.addAction(.cancel)
        alertBuilder.addAction(.delete) { [weak self] _ in
            guard let self else { return }
            do {
                try diaryManager.deleteData(self.diary)
                self.navigationController?.popViewController(animated: true)
            } catch CoreDataError.deleteFailure {
                let additionalAlertBuilder = AlertBuilder(viewController: self, prefferedStyle: .alert)
                additionalAlertBuilder.setType(.coreDataError(error: .deleteFailure))
                additionalAlertBuilder.addAction(.confirm)
                additionalAlertBuilder.show()
            } catch {
                let additionalAlertBuilder = AlertBuilder(viewController: self, prefferedStyle: .alert)
                additionalAlertBuilder.setType(.coreDataError(error: .unknown))
                additionalAlertBuilder.addAction(.confirm)
                additionalAlertBuilder.show()
            }
        }
        
        alertBuilder.show()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension DiaryDetailViewController {
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
                as? CGRect else { return }
        
        textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.size.height, right: 0)
    }
    
    @objc private func showMoreOptions() {
        let alertBuilder = AlertBuilder(viewController: self, prefferedStyle: .actionSheet)
        alertBuilder.setType(.actionSheet)
        alertBuilder.addAction(.delete) { [weak self] _ in
            guard let self else { return }
            self.showDeleteAlert()
        }
        alertBuilder.addAction(.share) { [weak self] _ in
            guard let self else { return }
            self.shareDiary(self.diary)
        }
        alertBuilder.addAction(.cancel)
        alertBuilder.show()
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        textView.contentInset = .zero
    }
}

extension DiaryDetailViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        let contents = textView.text.split(separator: "\n")
        guard !contents.isEmpty else { return }
        
        do {
            try diaryManager.saveContext()
        } catch CoreDataError.saveFailure {
            let alertBulder = AlertBuilder(viewController: self, prefferedStyle: .alert)
            alertBulder.setType(.coreDataError(error: .saveFailure))
            alertBulder.addAction(.confirm)
            alertBulder.show()
        } catch {
            let alertBulder = AlertBuilder(viewController: self, prefferedStyle: .alert)
            alertBulder.setType(.coreDataError(error: .unknown))
            alertBulder.addAction(.confirm)
            alertBulder.show()
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let splitText = splitTitleAndBody()
        
        diary.title = splitText.title
        diary.body = splitText.body
        
        setupFontStyle(title: splitText.title, body: splitText.body)
    }
}

extension DiaryDetailViewController {
    func fetchWeather() {
        guard let latitude, let longitude else { return }
        
        NetworkManager.shared.fetchData(
            NetworkConfiguration.weatherAPI(latitude: latitude, longitude: longitude)
        ) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let data):
                do {
                    let decodingData: WeatherResult = try DecodingManager.decodeData(from: data)
                    guard let weatherMain = decodingData.weather.first?.main,
                          let weatherIcon = decodingData.weather.first?.icon else {
                        return
                    }
                    self.diary.weatherMain = weatherMain
                    self.diary.weatherIcon = weatherIcon
                } catch {
                    DispatchQueue.main.async {
                        let alertBulder = AlertBuilder(viewController: self, prefferedStyle: .alert)
                        alertBulder.setType(.decodingError(error: .decodingFailure))
                        alertBulder.addAction(.confirm)
                        alertBulder.show()
                    }
                }
            case .failure:
                DispatchQueue.main.async {
                    let alertBulder = AlertBuilder(viewController: self, prefferedStyle: .alert)
                    alertBulder.setType(.apiError(error: .requestFailure))
                    alertBulder.addAction(.confirm)
                    alertBulder.show()
                }
            }
        }
    }
}
