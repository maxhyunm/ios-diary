//
//  DiaryListTableViewCell.swift
//  Diary
//
//  Created by by Maxhyunm, Hamg on 2023/08/29.
//

import UIKit
import CoreLocation

final class DiaryListTableViewCell: UITableViewCell {
    static let identifier: String = "cell"
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .body)
        
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .callout)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        return label
    }()
    
    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .caption2)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        return label
    }()
    
    private let weatherImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLabel()
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLabel() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(weatherImageView)
        contentView.addSubview(bodyLabel)
    }
    
    private func configureUI() {
        accessoryType = .disclosureIndicator
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            
            weatherImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            weatherImageView.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor, constant: 4),
            weatherImageView.widthAnchor.constraint(equalToConstant: 20),
            weatherImageView.heightAnchor.constraint(equalToConstant: 20),
            weatherImageView.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
            
            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            bodyLabel.leadingAnchor.constraint(equalTo: weatherImageView.trailingAnchor, constant: 4),
            bodyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            bodyLabel.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor)
        ])
    }
    
    func setModel(title: String, date: String, body: String) {
        titleLabel.text = title
        dateLabel.text = date
        bodyLabel.text = body
        
        setModel()
    }
    
    private func setModel() {
        let weather = WeatherRepository()
        let location = CLLocation(latitude: 37.498206, longitude: 127.02761)
        weather.fetchLocation(location: location) { [weak self] result in
            switch result {
            case .success(let weather):
                DispatchQueue.main.async {
                    guard let weather = weather.weather.first else { return }
                    let model = Weather(id: weather.id,
                                        main: weather.main,
                                        description: weather.description,
                                        icon: weather.icon)
                    self?.updateIcon(model.icon)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func updateIcon(_ icon: String) {
        guard let iconURL = URL(string: "https://openweathermap.org/img/wn/\(icon).png") else {
            return
        }
        
        loadImage(imageURL: iconURL) { [weak self] result in
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    self?.weatherImageView.image = image
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func loadImage(imageURL: URL, completion: @escaping (Result<UIImage, Error>) -> Void) {
        URLSession.shared.dataTask(with: imageURL) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let data = data,
               let image = UIImage(data: data) {
                completion(.success(image))
            } else {
                completion(.failure(NSError(domain: "ImageLoadingError", code: 0, userInfo: nil)))
            }
        }.resume()
    }
}
