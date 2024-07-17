//
//  InfoCollectionViewCell.swift
//  NetworkTracker
//
//  Created by Volodymyr Pysarenko on 11.07.2024.
//

import UIKit

protocol MyCollectionViewCellDelegate: AnyObject {
    func didTapDeleteButton(in cell: InfoCollectionViewCell, id: String)
}

final class InfoCollectionViewCell: UICollectionViewCell {
    
    private enum Constants {
        static let linkFontSize: CGFloat = 17
        static let queryFontSize: CGFloat = 13
        static let dateFontSize: CGFloat = 15
        static let cellCornerRadius: CGFloat = 12
    }
    
    private let linkLabel = UILabel(font: UIFont.systemFont(ofSize: Constants.linkFontSize, weight: .bold))
    private let queryLabel = UILabel(font: UIFont.systemFont(ofSize: Constants.queryFontSize, weight: .regular))
    private let dateLabel = UILabel(font: UIFont.systemFont(ofSize: Constants.dateFontSize, weight: .semibold))
    
    private let deleteButton: UIButton = {
        var button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "delete"), for: .normal)
        return button
    }()
    
    private let containerView: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = Constants.cellCornerRadius
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
        queryLabel.text = nil
        dateLabel.text = nil
        linkLabel.text = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.drawShadow()
    }
    
    func configureCell(with info: QueryInfoModel) {
        self.infoModelID = info.id
        self.queryLabel.text = info.text
        self.dateLabel.text = info.date
        self.linkLabel.text = info.url ?? "No link data"
    }
    
    private func setupView() {
        contentView.backgroundColor = .clear
    }
    
    private func setupButton() {
        let deleteAction = UIAction { [weak self] action in
            guard let self, let infoModelID else { return }
            delegate?.didTapDeleteButton(in: self, id: infoModelID)
        }
        
        deleteButton.addAction(deleteAction, for: .touchUpInside)
    }
    
    private func setConstraints() {
        enum ConstraintConstants {
            static let containerInset: CGFloat = 10
            static let verticalInset: CGFloat = 15
            static let horizontalInset: CGFloat = 15
            static let buttonSize: CGFloat = 24
        }
        
        contentView.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: ConstraintConstants.containerInset),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ConstraintConstants.containerInset),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ConstraintConstants.containerInset),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -ConstraintConstants.containerInset)
        ])

        containerView.addSubview(linkLabel)
        NSLayoutConstraint.activate([
            linkLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: ConstraintConstants.verticalInset),
            linkLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstants.horizontalInset),
            linkLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstants.horizontalInset)
        ])
        
        containerView.addSubview(deleteButton)
        NSLayoutConstraint.activate([
            deleteButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: ConstraintConstants.verticalInset),
            deleteButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstants.horizontalInset),
            deleteButton.widthAnchor.constraint(equalToConstant: ConstraintConstants.buttonSize),
            deleteButton.heightAnchor.constraint(equalToConstant: ConstraintConstants.buttonSize)
        ])
        
        containerView.addSubview(dateLabel)
        NSLayoutConstraint.activate([
            dateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstants.horizontalInset),
            dateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstants.horizontalInset),
            dateLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -ConstraintConstants.verticalInset)
        ])
        
        containerView.addSubview(queryLabel)
        NSLayoutConstraint.activate([
            queryLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstants.horizontalInset),
            queryLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstants.horizontalInset),
            queryLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }
}
