//
//  PlaylistCell.swift
//  OneAtOne
//
//  Created by Finlay, Kate on 4/2/17.
//  Copyright © 2017 1@1. All rights reserved.
//

import Foundation
import UIKit

class PlaylistCell : UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var thumbnail: UIImageView!
	@IBOutlet weak var checkButton: UIButton!
	
	var delegate: UITableViewDelegate?
	var videoID: String?
	
	override func awakeFromNib() {
		setup()
	}
	
	func setup() {
		let checkImg = UIImage(named: "check")
		checkButton.setImage(checkImg, for: .selected)
		
		let uncheckImg = UIImage(named: "uncheck")
		checkButton.setImage(uncheckImg, for: .normal)
	}
	
	@IBAction func checkButtonDidTapped(_ sender: Any) {
		if let button = sender as? UIButton {
			button.isSelected = !button.isSelected
		}
	}
}
