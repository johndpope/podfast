//
//  DiscoveryScreenViewController.swift
//  PodFast
//
//  Created by Orestis on 30/07/2019.
//  Copyright © 2019 Orestis Papadopoulos. All rights reserved.
//

import UIKit

protocol DiscoveryViewDelegate: NSObjectProtocol {
    func reloadData()
}

class DiscoveryScreenViewController: UIViewController, DiscoveryViewDelegate {

    @IBOutlet weak var podcastCollection: UICollectionView!

    private let presenter = DiscoveryScreenPresenter()

    override func viewDidLoad() {
        super.viewDidLoad()
        podcastCollection.dataSource = self

        podcastCollection.delegate = self
        presenter.setViewDelegate(discoveryViewDelegate: self)
        presenter.viewDidLoad()

    }

    func reloadData() {
        podcastCollection.reloadData()
    }

}

extension DiscoveryScreenViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.getPodcastCount()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let podcast = presenter.getPodcast(forRow: indexPath.row)
        let cell = podcastCollection.dequeueReusableCell(
            withReuseIdentifier: "podcast",
            for: indexPath
        ) as! PodcastCollectionViewCell

        cell.titleLabel.text = podcast.categories.first?.name
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.selectedPodcast(atRow: indexPath.row)
    }
}
