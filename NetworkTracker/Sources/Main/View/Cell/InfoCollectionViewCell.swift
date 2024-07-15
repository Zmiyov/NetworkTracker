//
//  InfoCollectionViewCell.swift
//  NetworkTracker
//
//  Created by Volodymyr Pysarenko on 11.07.2024.
//

import UIKit

protocol MyCollectionViewCellDelegate: AnyObject {
    func didTapButton(in cell: InfoCollectionViewCell, id: String)
}

final class InfoCollectionViewCell: UICollectionViewCell {
    
    private let textLabel = UILabel(font: UIFont.systemFont(ofSize: 17, weight: .bold))
    private let dateLabel = UILabel(font: UIFont.systemFont(ofSize: 15, weight: .semibold))
    private let linkLabel = UILabel(font: UIFont.systemFont(ofSize: 13, weight: .regular))
    
    private let deleteButton: UIButton = {
        var button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "delete"), for: .normal)
        return button
    }()
    
    private let containerView: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 12
        view.backgroundColor = .white
        return view
    }()
    
    weak var delegate: MyCollectionViewCellDelegate?
    
    private var infoModelID: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setConstraints()
        setupButton()
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
        self.infoModelID = info.id
        self.textLabel.text = info.text
        self.dateLabel.text = info.date
        self.linkLabel.text = info.url ?? "No link data"
    }
    
    private func setupView() {
        contentView.backgroundColor = .clear
    }
    
    private func setupButton() {
        let deleteAction = UIAction { [weak self] action in
            guard let self, let infoModelID else { return }
            delegate?.didTapButton(in: self, id: infoModelID)
        }
        
        deleteButton.addAction(deleteAction, for: .touchUpInside)
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
        
        containerView.addSubview(deleteButton)
        NSLayoutConstraint.activate([
            deleteButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15),
            deleteButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            deleteButton.widthAnchor.constraint(equalToConstant: 24),
            deleteButton.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        containerView.addSubview(dateLabel)
        NSLayoutConstraint.activate([
            dateLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -15),
            dateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            dateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15)
        ])
        
        containerView.addSubview(linkLabel)
        NSLayoutConstraint.activate([
            linkLabel.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 15),
            linkLabel.bottomAnchor.constraint(equalTo: dateLabel.topAnchor, constant: -15),
            linkLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            linkLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15)
        ])
    }
}

