//
//  PagesViewController.swift
//  Insight
//
//  Created by Josh Leikam on 7/14/17.
//  Copyright © 2017 Josh Leikam. All rights reserved.
//

import UIKit

class PagesViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    var pages = [UIViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.dataSource = self
        
        let p1: UIViewController! = storyboard?.instantiateViewController(withIdentifier: "vc1")
        let p2: UIViewController! = storyboard?.instantiateViewController(withIdentifier: "vc2")
        let p3: UIViewController! = storyboard?.instantiateViewController(withIdentifier: "vc3")
        let p4: UIViewController! = storyboard?.instantiateViewController(withIdentifier: "vc4")
        let p5: UIViewController! = storyboard?.instantiateViewController(withIdentifier: "vc5")
        let p6: UIViewController! = storyboard?.instantiateViewController(withIdentifier: "vc6")
        let p7: UIViewController! = storyboard?.instantiateViewController(withIdentifier: "vc7")
        
        pages.append(p1)
        pages.append(p2)
        pages.append(p3)
        pages.append(p4)
        pages.append(p5)
        pages.append(p6)
        pages.append(p7)
        
        
        setViewControllers([p7], direction: UIPageViewControllerNavigationDirection.reverse, animated: false, completion: nil)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController)-> UIViewController? {
        
        let currentIndex = pages.index(of: viewController)!
        if currentIndex == 0 { return nil }
        let previousIndex = abs((currentIndex - 1) % pages.count)
        return pages[previousIndex]
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController)-> UIViewController? {
        
        let currentIndex = pages.index(of: viewController)!
        if currentIndex == (pages.count - 1) { return nil }
        let nextIndex = abs((currentIndex + 1) % pages.count)
        return pages[nextIndex]

    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return pages.count-1
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pages.count
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
