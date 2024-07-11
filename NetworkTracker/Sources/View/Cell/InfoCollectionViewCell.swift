//
//  InfoCollectionViewCell.swift
//  NetworkTracker
//
//  Created by Volodymyr Pysarenko on 11.07.2024.
//

import UIKit

final class InfoCollectionViewCell: UICollectionViewCell {
    
    private let textLabel = UILabel(font: UIFont.systemFont(ofSize: 17, weight: .bold))
    private let dateLabel = UILabel(font: UIFont.systemFont(ofSize: 15, weight: .semibold))
    private let linkLabel = UILabel(font: UIFont.systemFont(ofSize: 13, weight: .regular), alighment: .right)
    
    private let containerView: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 12
        view.backgroundColor = .white
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        textLabel.text = nil
        dateLabel.text = nil
        linkLabel.text = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.drawShadow()
    }
    
    func configure(with info: QueryInfoModel) {
        self.textLabel.text = info.text
        self.dateLabel.text = info.date
        self.linkLabel.text = info.url ?? "No link data"
    }
    
    private func setupView() {
        contentView.backgroundColor = .clear
    }
    
    private func setConstraints() {
        contentView.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])

        containerView.addSubview(textLabel)
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15),
            textLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            textLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15)
        ])

        containerView.addSubview(dateLabel)
        NSLayoutConstraint.activate([
            dateLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -15),
            dateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15)
        ])

        containerView.addSubview(linkLabel)
        NSLayoutConstraint.activate([
            linkLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -15),
            linkLabel.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor, constant: 15),
            linkLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            linkLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.25)
        ])
        
        
    }
}

