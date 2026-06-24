import UIKit
import SwiftUI

class UbicacionMapViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    private func configureUI() {
        title = "Mapa de Ubicaciones"
        view.backgroundColor = .systemGroupedBackground

        // Top UIKit Header Label
        let headerLabel = UILabel()
        headerLabel.text = "Geolocalización de Clientes y Puntos"
        headerLabel.font = .systemFont(ofSize: 16, weight: .bold)
        headerLabel.textColor = .label
        headerLabel.textAlignment = .center
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerLabel)

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Visualiza en el mapa los puntos de entrega y despacho"
        subtitleLabel.font = .systemFont(ofSize: 12)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subtitleLabel)

        // Map Container View
        let mapContainerView = UIView()
        mapContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapContainerView)

        // Embed SwiftUI Map
        let context = CoreDataManager.shared.context
        let hostedView = UbicacionMapView().environment(\.managedObjectContext, context)
        let hostingController = UIHostingController(rootView: hostedView)

        addChild(hostingController)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        mapContainerView.addSubview(hostingController.view)

        NSLayoutConstraint.activate([
            // UIKit Controls Constraints
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            subtitleLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            // Map Container Constraints
            mapContainerView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 12),
            mapContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Embedded view to stretch over container
            hostingController.view.topAnchor.constraint(equalTo: mapContainerView.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: mapContainerView.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: mapContainerView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: mapContainerView.trailingAnchor)
        ])

        hostingController.didMove(toParent: self)
    }
}
