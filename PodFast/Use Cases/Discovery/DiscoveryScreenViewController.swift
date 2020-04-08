//
//  DiscoveryScreenViewController.swift
//  PodFast
//
//  Created by Orestis on 30/07/2019.
//  Copyright © 2019 Orestis Papadopoulos. All rights reserved.
//

import UIKit
import Foundation
import TTTAttributedLabel

protocol DiscoveryViewDelegate: NSObjectProtocol {
    func displayDetails(forPodcast podcast: Podcast, _ episode: Episode)
    func hidePodcastInformation()
    func reloadData()
    func playBackStarted()
    func setTimeElapsed(_ timeElapsed: String)
}

class DiscoveryScreenViewController: UIViewController, DiscoveryViewDelegate {

    @IBOutlet weak var podcastCollection: UICollectionView!
    @IBOutlet weak var podcastInformationView: UIStackView!
    @IBOutlet weak var podcastTitleLabel: TTTAttributedLabel!
    @IBOutlet weak var episodeDescriptionLabel: UILabel!
    @IBOutlet weak var podcastTimeElapsed: UILabel!

    @IBOutlet weak var episodeTitleLabel: UILabel!

    private weak var collidedCell: PodcastCollectionViewCell?
    private var visibleCells = [Int]()

    private let presenter = DiscoveryScreenPresenter()

    override func viewDidLoad() {
        super.viewDidLoad()

        podcastInformationView.isHidden = true

        podcastCollection.dataSource = self
        podcastCollection.delegate = self
        podcastCollection.decelerationRate = UIScrollViewDecelerationRateFast

        presenter.setViewDelegate(discoveryViewDelegate: self)
        presenter.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        let frame = self.podcastCollection.frame
        let lineView = UIView(frame: CGRect(x: frame.width/2,
                                            y: frame.minY, width: 2.0, height: frame.height))
        lineView.backgroundColor = .red
        self.view.addSubview(lineView)
    }

    override func viewDidAppear(_ animated: Bool) {
        let visibleCellRows = podcastCollection.visibleCells.compactMap { cell in
            return podcastCollection.indexPath(for: cell)?.row
        }
        presenter.categoriesVisibilityChanged(added: Set(visibleCellRows), removed: Set<Int> ())
        visibleCells = visibleCellRows
    }

    func reloadData() {
        podcastCollection.reloadData()
    }

    // TODO Not working at the moment
    func playBackStarted() {
        collidedCell?.isHighlighted = false
        collidedCell?.titleLabel.textColor = .green
    }

    func displayDetails(forPodcast podcast: Podcast, _ episode: Episode) {

        podcastInformationView.isHidden = false

        podcastTitleLabel.text = podcast.title
        episodeTitleLabel.text = episode.title
        episodeDescriptionLabel.text = episode.episodeDescription?.stripHtml().replacingOccurrences(of: "\n", with: "").limitTo(numberOfSentences: 2)

        if let itunesUrl = podcast.itunesUrl {
            guard let title = podcast.title else {
                return
            }
            let linkWithRemovedOrigin = itunesUrl.replacingOccurrences(of: "?uo=4", with: "")
            let nstitle = title as NSString
            podcastTitleLabel.addLink(to: URL(string: linkWithRemovedOrigin), with: nstitle.range(of: title))
            podcastTitleLabel.delegate = self
        }
    }

    func hidePodcastInformation(){
        podcastInformationView.isHidden = true
    }

    func setTimeElapsed(_ timeElapsed: String) {
        podcastTimeElapsed.text = timeElapsed
    }
}

extension DiscoveryScreenViewController: TTTAttributedLabelDelegate {
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

extension DiscoveryScreenViewController: UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.getCategoriesCount()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = podcastCollection.dequeueReusableCell(
            withReuseIdentifier: "podcast",
            for: indexPath
        ) as! PodcastCollectionViewCell

        cell.titleLabel.text = presenter.getCategoryName(forRow: indexPath.row) ?? " "
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.didSelectCategory(atRow: indexPath.row)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let center = self.view.center
        let cellsInView = podcastCollection.visibleCells.map({$0 as! PodcastCollectionViewCell})
        let rowsOfCellsInView = cellsInView.compactMap { podcastCollection.indexPath(for: $0)?.row }

        // detect change in visible cells
        if !visibleCells.elementsEqual(rowsOfCellsInView) {
            presenter.categoriesVisibilityChanged(added: Set(rowsOfCellsInView).subtracting(visibleCells),
                                               removed: Set(visibleCells).subtracting(rowsOfCellsInView))
            visibleCells = rowsOfCellsInView
        }

        for cell in cellsInView {
            // detect collision
            let cellFrame = podcastCollection.convert(cell.frame, to: self.view)
            cell.titleLabel.textColor = .black
            if cellFrame.contains(center) {
                cell.titleLabel.isHighlighted = true
                if(collidedCell != cell){
                    collidedCell = cell
                    collisionDetected(forCell: cell)
                    presenter.didSelectCategory(atRow: podcastCollection.indexPath(for: cell)!.row)
                }
            } else {
                cell.titleLabel.isHighlighted = false
            }
        }
    }

    func collisionDetected(forCell cell: PodcastCollectionViewCell){
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    }
}
