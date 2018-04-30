//
//  ProfileViewController.swift
//  SimpleApp
//
//  Created by Daniil Sargin on 22/02/2018.
//  Copyright © 2018 dsargin. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UINavigationControllerDelegate {

	@IBOutlet weak var avatarImageView: UIImageView!
	@IBOutlet weak var usernameTextField: UITextField!
	@IBOutlet weak var userInfoTextView: UITextView!
	@IBOutlet weak var editButton: UIButton!

	@IBAction func editButtonDidPress(_ sender: UIButton) {

	}

	override func viewDidLoad() {
		super.viewDidLoad()

		let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
		avatarImageView.addGestureRecognizer(tapGestureRecognizer)
	}

	@objc func imageViewTapped() {
		let imagePickerController = UIImagePickerController()
		imagePickerController.allowsEditing = true
		imagePickerController.sourceType = .photoLibrary
		imagePickerController.delegate = self
		self.present(imagePickerController, animated: true, completion: nil)
	}

}

// MARK: - UIImagePickerControllerDelegate

extension ProfileViewController: UIImagePickerControllerDelegate {

	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
			avatarImageView.image = image
			picker.dismiss(animated: true, completion: nil)
		}
	}

	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true, completion: nil)
	}

}
