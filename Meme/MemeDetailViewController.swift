//
//  MemeDetailViewController.swift
//  Meme
//
//  Created by Mandar U Jog on 2/2/17.
//  Copyright © 2017 Sheetal.com. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {

    @IBOutlet weak var MemeImage: UIImageView!

    var meme: Meme!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MemeImage.image = meme.memedImage
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
