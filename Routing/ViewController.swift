//
//  ViewController.swift
//  Routing
//
//  Created by Chris Eidhof on 18.10.18.
//  Copyright © 2018 objc.io. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    let mapView = MKMapView()
    var tracks: [Track:MKPolygon] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        view.addSubview(mapView, constraints: [
            equal(\.leadingAnchor), equal(\.trailingAnchor),
            equal(\.topAnchor), equal(\.bottomAnchor)
        ])
        DispatchQueue.global(qos: .userInitiated).async {
            let tracks = Track.load()
            DispatchQueue.main.async {
                self.updateMapView(tracks)
            }
        }
    }
    
    func updateMapView(_ newTracks: [Track]) {
        for t in newTracks {
            let coords = t.coordinates.map { CLLocationCoordinate2D($0.coordinate) }
            let polygon = MKPolygon(coordinates: coords, count: coords.count)
            tracks[t] = polygon
            mapView.addOverlay(polygon)
        }
        let boundingRects = tracks.values.map { $0.boundingMapRect }
        let boundingRect = boundingRects.reduce(MKMapRect.null) { $0.union($1) }
        mapView.setVisibleMapRect(boundingRect, edgePadding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), animated: true)
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let p = overlay as? MKPolygon else {
            return MKOverlayRenderer(overlay: overlay)
        }
        let (track, _) = tracks.first(where: { (track, poly) in poly == p })!
        let r = MKPolygonRenderer(polygon: p)
        r.lineWidth = 1
        r.strokeColor = track.color.uiColor
        r.fillColor = track.color.uiColor.withAlphaComponent(0.2)
        return r
    }
}

extension CLLocationCoordinate2D {
    init(_ coord: Coordinate) {
        self.init(latitude: coord.latitude, longitude: coord.longitude)
    }
}
