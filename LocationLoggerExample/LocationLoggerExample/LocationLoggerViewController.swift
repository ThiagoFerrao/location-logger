import UIKit
import LocationLogger
import RxSwift
import RxCocoa

class LocationLoggerViewController: UIViewController {

    private let buttonStack = UIStackView()
    private let executeLogButton = UIButton(type: .system)
    private let executeAuthorizationButton = UIButton(type: .system)
    private let executeAuthorizationAndAccuracyButton = UIButton(type: .system)

    private let disposeBag = DisposeBag()
    private let locationLogger = LocationLogger.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupBindings()
    }

    private func setupViews() {
        view.backgroundColor = .lightGray

        buttonStack.addArrangedSubview(executeLogButton)
        buttonStack.addArrangedSubview(executeAuthorizationButton)
        buttonStack.addArrangedSubview(executeAuthorizationAndAccuracyButton)

        view.addSubview(buttonStack)

        NSLayoutConstraint.activate([
            buttonStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            buttonStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonStack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40),
            buttonStack.leftAnchor.constraint(equalTo: view.rightAnchor, constant: 40)
        ])

        buttonStack.axis = .vertical
        buttonStack.alignment = .center
        buttonStack.spacing = 25
        buttonStack.distribution = .equalSpacing
        buttonStack.translatesAutoresizingMaskIntoConstraints = false

        executeLogButton.backgroundColor = .darkGray
        executeLogButton.setTitle("Execute Log", for: .normal)

        executeAuthorizationButton.backgroundColor = .blue
        executeAuthorizationButton.setTitle("Execute Authorization", for: .normal)

        executeAuthorizationAndAccuracyButton.backgroundColor = .red
        executeAuthorizationAndAccuracyButton.setTitle("Execute Authorization to iOS 14+", for: .normal)

        [executeLogButton, executeAuthorizationButton, executeAuthorizationAndAccuracyButton].forEach { button in
            button.contentEdgeInsets = .init(top: 12, left: 12, bottom: 12, right: 12)
            button.layer.cornerRadius = 10
            button.clipsToBounds = true
            button.tintColor = .white
        }
    }

    private func setupBindings() {
        executeLogButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.locationLogger.log(
                    requestDomain: "https://httpbin.org/post",
                    callback: { data in
                        let title = "Log Executed"
                        let message = data.descripton()
                        self?.presentAlert(with: title, and: message)
                    }
                )
            })
            .disposed(by: disposeBag)

        executeAuthorizationButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.locationLogger.requestLocationAuthorization(
                    callback: { data in
                        let title = "Authorization Executed"
                        let message = data.descripton()
                        self?.presentAlert(with: title, and: message)
                    }
                )
            })
            .disposed(by: disposeBag)

        executeAuthorizationAndAccuracyButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.locationLogger.requestLocationAuthorizationAndAccuracy(
                    purposeKey: "HighAccuracyLocationRequest",
                    callback: { data in
                        let title = "Authorization Executed"
                        let message = data.descripton()
                        self?.presentAlert(with: title, and: message)
                    }
                )
            })
            .disposed(by: disposeBag)
    }
}
