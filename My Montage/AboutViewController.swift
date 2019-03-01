//
//  AboutViewController.swift
//  My Montage
//
//  Created by nian chen on 2017/6/11.
//  Copyright © 2017年 nche75. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    @IBOutlet var AboutText: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        //disable the edir possibility
        AboutText.isEditable = false
        //AboutText.text = "test"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //back to last page
    @IBAction func Back(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)

    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
