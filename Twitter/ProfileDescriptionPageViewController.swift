//
//  ProfileDescriptionPageViewController.swift
//  Twitter
//
//  Created by Deepthy on 10/7/17.
//  Copyright © 2017 Deepthy. All rights reserved.
//

import UIKit

protocol ProfileDescriptionPageViewControllerDelegate: class {
    
    /**
     Called when the number of pages is updated.
     
     - parameter profileDescriptionPageViewController: the ProfileDescriptionPageViewController instance
     - parameter count: the total number of pages.
     */
    func profileDescriptionPageViewController(profileDescriptionPageViewController: ProfileDescriptionPageViewController,
                                    didUpdatePageCount count: Int)
    
    /**
     Called when the current index is updated.
     
     - parameter profileDescriptionPageViewController: the ProfileDescriptionPageViewController instance
     - parameter index: the index of the currently visible page.
     */
    func profileDescriptionPageViewController(profileDescriptionPageViewController: ProfileDescriptionPageViewController,
                                    didUpdatePageIndex index: Int)
    
}

class ProfileDescriptionPageViewController: UIPageViewController {

    fileprivate(set) lazy var orderedViewControllers: [UIViewController] = {
        return [
            self.newPageViewController("Left"),
            self.newPageViewController("Right")
        ]
    }()
    
    fileprivate func newPageViewController(_ side: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle:nil).instantiateViewController(withIdentifier: "ProfilePage\(side)VC")
    }
    
    weak var profileDelegate: ProfileDescriptionPageViewControllerDelegate?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        dataSource = self
        delegate = self

        if let firstViewController = orderedViewControllers.first {
            setViewControllers( [firstViewController],
                                direction: .forward,
                                animated: true,
                                completion: nil
            )
        }
        
        profileDelegate?.profileDescriptionPageViewController(profileDescriptionPageViewController: self, didUpdatePageCount: orderedViewControllers.count)
            
        
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor.darkGray
        appearance.currentPageIndicatorTintColor = UIColor.gray

    }
    
    /**
     Scrolls to the next view controller.
     */
    func scrollToNextViewController() {
        if let visibleViewController = viewControllers?.first,
            let nextViewController = pageViewController(self,
                                                        viewControllerAfter: visibleViewController) {
            scrollToViewController(nextViewController)
        }
    }
    
    /**
     Scrolls to the view controller at the given index. Automatically calculates
     the direction.
     
     - parameter newIndex: the new index to scroll to
     */
    func scrollToViewController(index newIndex: Int) {
        if let firstViewController = viewControllers?.first,
            let currentIndex = orderedViewControllers.index(of: firstViewController) {
            let direction: UIPageViewControllerNavigationDirection = newIndex >= currentIndex ? .forward : .reverse
            let nextViewController = orderedViewControllers[newIndex]
            scrollToViewController(nextViewController, direction: direction)
        }
    }
    
    /**
     Scrolls to the given 'viewController' page.
     
     - parameter viewController: the view controller to show.
     */
    fileprivate func scrollToViewController(_ viewController: UIViewController,
                                            direction: UIPageViewControllerNavigationDirection = .forward) {
        setViewControllers([viewController],
                           direction: direction,
                           animated: true,
                           completion: { (finished) -> Void in
                            // Setting the view controller programmatically does not fire
                            // any delegate methods, so we have to manually notify the
                            // 'Delegate' of the new index.
                            self.notifyTutorialDelegateOfNewIndex()
        })
    }
    
    /**
     Notifies 'Delegate' that the current page index was updated.
     */
    fileprivate func notifyTutorialDelegateOfNewIndex() {
        if let firstViewController = viewControllers?.first,
            let index = orderedViewControllers.index(of: firstViewController) {
            profileDelegate?.profileDescriptionPageViewController(profileDescriptionPageViewController: self, didUpdatePageIndex: index)
        }
    }


    
}


extension ProfileDescriptionPageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        if let firstViewController = viewControllers?.first,
            let index = orderedViewControllers.index(of: firstViewController) {
            profileDelegate?.profileDescriptionPageViewController(profileDescriptionPageViewController: self, didUpdatePageIndex: index)
            
        }
    }
    
}

// MARK: - UIPageViewControllerDataSource
extension ProfileDescriptionPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
}
