//
//  SlideBannerViewController.swift
//  Kakaopay
//
//  Created by kali_company on 14/04/2019.
//

import UIKit

protocol BannerScrollViewDelegate: UIScrollViewDelegate {
    func scrollViewDidChangeContentOffset(_ scrollView: UIScrollView, offset: CGPoint)
}

class BannerScrollView: UIScrollView {
    override var contentOffset: CGPoint {
        didSet {
            (delegate as? BannerScrollViewDelegate)?.scrollViewDidChangeContentOffset(self, offset: contentOffset)
        }
    }
}

class SlideBannerViewController: UIViewController {
    @IBOutlet private weak var baseView: UIView!
    @IBOutlet private var backgroundImageViews: [UIImageView]!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var pageControl: UIPageControl!
    @IBOutlet private weak var pageControlTop: NSLayoutConstraint!
    @IBOutlet private weak var pageControlLeft: NSLayoutConstraint!
    @IBOutlet private weak var pageControlRight: NSLayoutConstraint!
    @IBOutlet private weak var pageControlBottom: NSLayoutConstraint!
    @IBOutlet private weak var pageControlCenter: NSLayoutConstraint!
    
    private var timer: Timer?
    private var isDragging = false
    private var isFixedOffset = false
    
    private var bannerViews: [UIView] = []
    
    private var configuration: BannerSlideConfiguration! {
        didSet {
            var contents = [PayAdContent]()
            for index in 0..<configuration.unit.displayCount {
                if index < configuration.unit.contents.count {
                    contents.append(configuration.unit.contents[index])
                }
            }
            
            if contents.count >= 2 {
                let firstLast = (contents.first!, contents.last!)
                contents.append(firstLast.0)
                contents.insert(firstLast.1, at: 0)
            }
            
            self.contents = contents
        }
    }
    private var contents = [PayAdContent]()
    private var currentContent: PayAdContent? {
        willSet {
            if let content = currentContent, currentContent?.contentId != newValue?.contentId {
                self.configuration.didDisappear?(content)
            }
        }
        didSet {
            if let content = currentContent, currentContent?.contentId != oldValue?.contentId {
                self.configuration.didAppear?(content)
                currentBackgroundImageViewIndex = (currentBackgroundImageViewIndex == 0 ? 1 : 0)
                currentBackgroundImageView.setImage(url: content.bgImageUrl, useCache: .memory, completion: nil)
                nextBackgroundImageView.setImage(url: nil)
                currentBackgroundImageView.alpha = 1.0
                nextBackgroundImageView.alpha = 0.0
            }
        }
    }
    private var prevContentOffset: CGPoint = CGPoint(x: 0.0, y: 0.0)
    private var currentBackgroundImageViewIndex: Int = 0 {
        didSet {
            backgroundImageViews[currentBackgroundImageViewIndex].alpha = 1.0
            backgroundImageViews[oldValue].alpha = 0.0
        }
    }
    
    private var currentBackgroundImageView: UIImageView {
        return backgroundImageViews[currentBackgroundImageViewIndex]
    }
    private var nextBackgroundImageView: UIImageView {
        get {
            if currentBackgroundImageViewIndex == 0 {
                return backgroundImageViews[1]
            } else {
                return backgroundImageViews[0]
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        preparePageControl()
        
        if scrollView.subviews.count == 0 {
            prepareBannerItems()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        adjustBannerViews()
        startTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopTimer()
    }
    
    private func preparePageControl() {
        let position = configuration.pageControlPosition
        
        if (position == .hidden || contents.count < 2) {
            pageControl.isHidden = true
            if contents.count < 2 {
                scrollView.isScrollEnabled = false
            }
            return
        }
        pageControl.numberOfPages = contents.count - 2
        pageControlTop.priority = (position == .topLeft || position == .topRight || position == .topCenter) ? .defaultHigh : .defaultLow
        pageControlLeft.priority = (position == .topLeft || position == .bottomLeft) ? .defaultHigh : .defaultLow
        pageControlRight.priority = (position == .topRight || position == .bottomRight) ? .defaultHigh : .defaultLow
        pageControlBottom.priority = (position == .bottomLeft || position == .bottomRight || position == .bottomCenter) ? .defaultHigh : .defaultLow
        pageControlCenter.priority = (position == .topCenter || position == .bottomCenter) ? .defaultHigh : .defaultLow
    }
    
    private func prepareBannerItems() {
        guard !contents.isEmpty else { return }
        
        let subviews = scrollView.subviews
        for subview in subviews {
            subview.removeFromSuperview()
        }
        
        for i in 0..<contents.count {
            let banner = BannerHelper.loadBanner(content: contents[i], cachePolicy: configuration.imageCachePolicy, didReady: { _, error in
                if i == 0 {
                    self.configuration.didReady?(self.contents[i], error)
                    self.configuration.didReady = nil
                }
            })
            if let banner = banner as? ImageBannerView {
                banner.updateContentMode(configuration.contentMode)
            }
            bannerViews.append(banner)
            self.scrollView.addSubview(banner)
        }
    }
    
    private func adjustBannerViews() {
        scrollView.contentSize = CGSize(width: scrollView.bounds.width * CGFloat(contents.count), height: scrollView.bounds.size.height)
        
        if contents.count == 0 { return }
        
        for i in 0..<bannerViews.count {
            let frame = CGRect(x: scrollView.frame.width * CGFloat(i), y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
            bannerViews[i].frame = frame
        }
        
        let index = contents.count < 2 ? 0 : 1
        scrollView.contentOffset = CGPoint(x: (scrollView.frame.width * CGFloat(index)), y: 0)
        currentContent = contents[index]
        prevContentOffset = scrollView.contentOffset
    }
    
    private func startTimer() {
        if contents.count >= 2 && !(timer?.isValid ?? false) {
            timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true, block: { [weak self] timer in
                self?.scrollToNextBanner()
            })
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateCurrentContent() {
        guard prevContentOffset != scrollView.contentOffset else { return }
        
        if scrollView.contentOffset.x.remainder(dividingBy: scrollView.frame.width) == 0.0 {
            let index = Int(scrollView.contentOffset.x / scrollView.frame.width)
            guard index < contents.count else {
                return
            }
            pageControl.currentPage = index - 1
            self.currentContent = contents[index]
            prevContentOffset = scrollView.contentOffset
            isFixedOffset = false
        } else {
            let delta = isFixedOffset ? abs(scrollView.frame.size.width * CGFloat(contents.count - 1) - scrollView.contentOffset.x) : abs(prevContentOffset.x - scrollView.contentOffset.x)
            let ratio = delta / scrollView.frame.width
            currentBackgroundImageView.alpha = (1.0 - ratio)
            nextBackgroundImageView.alpha = ratio
            
            if nextBackgroundImageView.imageUrl == nil {
                var index = Int(scrollView.contentOffset.x / scrollView.frame.width)
                if prevContentOffset.x < scrollView.contentOffset.x {
                    let prevIndex = Int(prevContentOffset.x / scrollView.frame.width)
                    index = index + ((prevIndex == 1 && isFixedOffset) ? 0 : 1)
                }
                nextBackgroundImageView.setImage(url: contents[index].bgImageUrl, useCache: .memory, completion: nil)
            }
        }
    }
    
    private func fixScrollOffset() {
        guard contents.count >= 2 else { return }
        
        let x = scrollView.contentOffset.x
        if x >= scrollView.frame.size.width * CGFloat(contents.count - 1) {
            let delta = x - scrollView.frame.size.width * CGFloat(contents.count - 1)
            self.scrollView.contentOffset = CGPoint(x: scrollView.frame.size.width + delta, y: 0)
        } else if x < scrollView.frame.size.width {
            isFixedOffset = true
            let delta = x - scrollView.frame.size.width
            self.scrollView.contentOffset = CGPoint(x: scrollView.frame.size.width * CGFloat(contents.count - 1) + delta, y: 0)
        }
    }
    
    private func scrollToNextBanner() {
        guard !isDragging else { return }
        
        let x = scrollView.contentOffset.x
        let nextRect = CGRect(x: x + scrollView.frame.width,
                              y: 0,
                              width: scrollView.frame.width,
                              height: scrollView.frame.height)
        
        scrollView.scrollRectToVisible(nextRect, animated: true)
    }
    
    @IBAction private func actionToBannerItem(_ sender: UITapGestureRecognizer) {
        if let currentContent = currentContent {
            configuration.didSelect?(currentContent)
        }
    }
    
    @IBAction private func actionToPage(_ sender: UIPageControl) {
        guard !contents.isEmpty else { return }
        
        let page = sender.currentPage

        scrollView.scrollRectToVisible(CGRect(origin: CGPoint(x: (scrollView.frame.width * CGFloat(page + 1)), y: 0), size: scrollView.frame.size), animated: true)
        currentContent = contents[page + 1]
    }
}

extension SlideBannerViewController {
    static func instantiate(configuration: BannerSlideConfiguration) -> SlideBannerViewController {
        let viewController = UIStoryboard(name: "PayBanner", bundle: Bundle(for: self)).instantiateViewController(withIdentifier: "SlideBannerViewController") as? SlideBannerViewController
        viewController?.configuration = configuration
        return viewController!
    }
}

extension SlideBannerViewController: BannerScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isDragging = true
        stopTimer()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else { return }
        
        isDragging = false
        startTimer()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isDragging = false
        startTimer()
    }
    
    func scrollViewDidChangeContentOffset(_ scrollView: UIScrollView, offset: CGPoint) {
        fixScrollOffset()
        
        updateCurrentContent()
    }
}
