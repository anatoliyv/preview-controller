//
//  PreviewController.swift
//  Pods
//
//  Created by Anatoliy Voropay on 5/1/17.
//
//

import UIKit

/// Delegate to handle `ImagePreviewController` events
@objc public protocol ImagePreviewControllerDelegate {

    /// User did pressed close button
    @objc optional func imagePreviewControllerDidPressedClose(_ controller: ImagePreviewController)
    
    /// User did pressed close button
    @objc optional func imagePreviewControllerDidPressedShare(_ controller: ImagePreviewController, withImage image: UIImage)
}

/// This class is used to preview images with
public class ImagePreviewController: UIViewController {
    
    /// Delegate to track events from users
    public weak var delegate: ImagePreviewControllerDelegate?
    
    /// If you do not need share button set it to `false`
    public var showShareButton: Bool = true
    
    /// URL to image that will be previewed
    fileprivate(set) var url: URL?
    
    /// Close button in navigation bar
    fileprivate(set) var closeButton: UIButton?
    
    /// Share button in navigation bar
    fileprivate(set) var shareButton: UIButton?
    
    fileprivate var scrollView: UIScrollView?
    fileprivate var imageView: UIImageView?
    fileprivate var navigationBar: UIView?
    
    // MARK: Lifecycle
    
    deinit {
        imageView?.removeFromSuperview()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        scrollView = UIScrollView(frame: view.bounds)
        scrollView?.backgroundColor = .black
        scrollView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView?.maximumZoomScale = 4.0
        scrollView?.delegate = self
        view.addSubview(scrollView!)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        scrollView?.addGestureRecognizer(tapRecognizer)
        
        setupNavigationBar()
    }
    
    // MARK: Preview image
    
    public func preview(byURL url: URL) {
        self.url = url
        resetLoadedData()
        loadImageData()
    }
    
    public func preview(byPath path: String) {
        guard let url = URL(string: path) else { return }
        preview(byURL: url)
    }
    
    public func preview(image: UIImage) {
        resetLoadedData()
        setupImageView(withImage: image)
    }
    
    // MARK: Size handling
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        customizeScrollView()
    }
}

/// Actions
extension ImagePreviewController {

    @IBAction public func pressedClose(sender: AnyObject?) {
        delegate?.imagePreviewControllerDidPressedClose?(self)
    }
    
    @IBAction public func pressedShare(sender: AnyObject?) {
        guard let image = imageView?.image else { return }
        delegate?.imagePreviewControllerDidPressedShare?(self, withImage: image)
    }
}

/// Working with data
extension ImagePreviewController {
    
    fileprivate func resetLoadedData() {
        imageView?.image = nil
    }
    
    fileprivate func loadImageData() {
        guard let url = url else { return }
        
        URLSession.shared.dataTask(
            with: url,
            completionHandler: { (data, _, error) in
                DispatchQueue.main.async(execute: { () -> Void in
                    if let message = error?.localizedDescription {
                        self.showAlert(withMessage: message)
                    } else if let data = data,
                        let image = UIImage(data: data)
                    {
                        self.setupImageView(withImage: image)
                    }
                })
            }).resume()
    }
    
    private func showAlert(withMessage message: String) {
        let alert = UIAlertController(
            title: NSLocalizedString("Error", comment: ""),
            message: NSLocalizedString(message, comment: ""),
            preferredStyle: .alert)

        let action = UIAlertAction(title: NSLocalizedString("Close", comment: ""), style: .cancel, handler: nil)
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func setupImageView(withImage image: UIImage) {
        imageView?.removeFromSuperview()
        imageView = UIImageView(image: image)
        imageView?.autoresizingMask = [ .flexibleBottomMargin, .flexibleTopMargin, .flexibleRightMargin, .flexibleLeftMargin ]
        customizeScrollView()
    }
}

/// Scrolling
extension ImagePreviewController {
    
    fileprivate func customizeScrollView() {
        guard let image = imageView?.image else { return }
        var minZoom = fmin(self.view.frame.width / image.size.width, self.view.frame.height / image.size.height)
        minZoom = fmin(1.0, minZoom)
        
        scrollView?.contentSize = image.size
        scrollView?.minimumZoomScale = minZoom
        scrollView?.addSubview(self.imageView!)
        scrollView?.setZoomScale(minZoom, animated: false)
        centerImageView()
    }
    
    fileprivate func centerImageView() {
        guard let imageView = imageView else { return }
        guard let scrollView = scrollView else { return }
        
        let boundsSize = scrollView.bounds.size
        var frameToCenter = imageView.frame
        
        // Center horizontally
        if frameToCenter.size.width < boundsSize.width {
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2
        } else {
            frameToCenter.origin.x = 0
        }
        
        // Center vertically
        if frameToCenter.size.height < boundsSize.height {
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2
        } else {
            frameToCenter.origin.y = 0
        }
        
        imageView.frame = frameToCenter
    }
    
    @objc fileprivate func handleTap() {
        guard let navigationBar = navigationBar else { return }
        makeNavigationBarVisible(navigationBar.frame.origin.y < 0)
    }
}

/// `UIScrollViewDelegate` protocol implementation
extension ImagePreviewController: UIScrollViewDelegate {
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImageView()
    }
}

/// Top navigation bar
extension ImagePreviewController {

    fileprivate func setupNavigationBar() {
        navigationBar = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
        navigationBar?.autoresizingMask = [ .flexibleWidth, .flexibleBottomMargin ]
        
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            navigationBar?.backgroundColor = .clear
            
            let blurEffect = UIBlurEffect(style: .dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = navigationBar!.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            navigationBar?.addSubview(blurEffectView)
        } else {
            navigationBar?.backgroundColor = .black
        }
        
        view.addSubview(navigationBar!)
        setupNavigationBarButtons()
    }
    
    private func setupNavigationBarButtons() {
        guard let navigationBar = navigationBar else { return }
        
        let closeButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        closeButton.autoresizingMask = .flexibleRightMargin
        closeButton.setImage(UIImage(named: "Close", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
        closeButton.addTarget(self, action: #selector(pressedClose(sender:)), for: .touchUpInside)
        
        let shareButton = UIButton(frame: CGRect(x: view.frame.width - 44, y: 0, width: 44, height: 44))
        shareButton.autoresizingMask = .flexibleLeftMargin
        shareButton.setImage(UIImage(named: "Share", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
        shareButton.addTarget(self, action: #selector(pressedShare(sender:)), for: .touchUpInside)
        
        navigationBar.addSubview(closeButton)
        navigationBar.addSubview(shareButton)
    }
    
    fileprivate func makeNavigationBarVisible(_ visible: Bool = true) {
        guard let navigationBar = navigationBar else { return }
        
        UIView.animate(
            withDuration: 0.2,
            animations: {
                self.navigationBar?.frame = CGRect(
                    x: 0, y: ( visible ? 0 : -navigationBar.frame.height),
                    width: navigationBar.frame.width,
                    height: navigationBar.frame.height)
            })
    }
}

/// Interface
extension ImagePreviewController {
    
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    public override var prefersStatusBarHidden: Bool {
        return true
    }
}
