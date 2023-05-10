//
//  ViewController.swift
//  iOSAss3
//
//  Created by John Wang on 3/5/2023.
//

import UIKit

class HomeController: UIViewController, UIScrollViewDelegate {
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var addButton: UIButton!
    @IBOutlet var scrollView: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()

        let pages = 3

        scrollView.contentSize = CGSize(width: scrollView.frame.width * CGFloat(pages), height: scrollView.frame.height)

        for i in 0 ..< pages {
            let view = UIView(frame: CGRect(x: scrollView.frame.width * CGFloat(i), y: 0, width: scrollView.frame.width, height: scrollView.frame.height))

            let label = UILabel(frame: view.bounds)
            label.text = "pages \(i + 1)"
            label.textAlignment = .center
            view.addSubview(label)

            scrollView.addSubview(view)
        }
        scrollView.delegate = self
        addButton.layer.cornerRadius = addButton.frame.size.width / 2
        addButton.clipsToBounds = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Make the button circular
        addButton.layer.cornerRadius = addButton.frame.size.width / 2
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }
}
