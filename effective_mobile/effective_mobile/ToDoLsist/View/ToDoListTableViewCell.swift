//
//  ToDoListTableViewCell.swift
//  effective_mobile
//
//  Created by Vermut xxx on 28.08.2024.
//


import UIKit

class ToDoTableViewCell: UITableViewCell {

    static let identifier = "ToDoTableViewCell"

    // UI components
    private let titleLabel = UILabel.makeLabel(fontSize: 18, weight: .bold)
    private let descriptionLabel = UILabel.makeLabel(fontSize: 14, weight: .regular)
    private let dateLabel = UILabel.makeLabel(fontSize: 12, weight: .light)
    private let completedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private var currentToDoItem: ToDoItem?

    // Static DateFormatter to reuse
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
        setupConstraints()
        setupGestureRecognizer()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Configure cell with ToDo data
    func configure(with todo: ToDoItem) {
        currentToDoItem = todo
        titleLabel.text = todo.title
        descriptionLabel.text = todo.todoDescription
        dateLabel.text = Self.dateFormatter.string(from: todo.createdDate ?? Date())
        updateCompletionStatus(isCompleted: todo.isCompleted)
    }

    private func setupViews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(completedImageView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),

            dateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 5),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),

            completedImageView.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
            completedImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            completedImageView.widthAnchor.constraint(equalToConstant: 34),
            completedImageView.heightAnchor.constraint(equalToConstant: 34),
            completedImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }

    private func setupGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCompletedImage))
        completedImageView.addGestureRecognizer(tapGesture)
    }

    private func updateCompletionStatus(isCompleted: Bool) {
        let imageName = isCompleted ? "checkmark.circle.fill" : "circle"
        completedImageView.image = UIImage(systemName: imageName)
        completedImageView.tintColor = isCompleted ? .systemGreen : .systemRed
    }

    @objc private func didTapCompletedImage() {
        guard let todo = currentToDoItem else { return }
        let newStatus = !todo.isCompleted
        CoreDataManager.shared.updateToDo(
            toDo: todo,
            title: todo.title ?? "",
            description: todo.todoDescription,
            isCompleted: newStatus
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.updateCompletionStatus(isCompleted: newStatus)
                case .failure(let error):
                    print("Error updating ToDo item: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - UILabel Extension

private extension UILabel {
    static func makeLabel(fontSize: CGFloat, weight: UIFont.Weight) -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: fontSize, weight: weight)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }
}
