//
//  LommaQuiz
//
//  Created by jörgen persson on 2021-12-20.
//

import UIKit
import FirebaseAuth

class VCAuth: UIViewController {

    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var showStatusText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (Auth.auth().currentUser?.email == "jorgen_raby@hotmail.com"){
            showStatusText.text = "Inloggad"
        }
        if (Auth.auth().currentUser?.email == "jorgen@icloud.com"){
            showStatusText.text = "Inloggad"
        }
    }
    
    @IBAction func logoutButton(_ sender: Any) {
       
        let firebaseAuth = Auth.auth()
            do {
              try firebaseAuth.signOut()
                showStatusText.text = "Utloggad"
                masterLoggedIn = false
                authPassedForUser = false
                loggedInHighest = false
                loggedInToWrite = false
            } catch
                let signOutError as NSError
            {
              print("Error signing out: %@", signOutError)
                showStatusText.text = "Fel vid utloggning"
            }
    }
        
    @IBAction func loginButton(_ sender: Any) {
        Auth.auth().signIn(withEmail: emailText.text!, password: passwordText.text!) { [weak self] authResult, error in
          guard let strongSelf = self else { return }
            if error == nil{
                // hurra
                self!.showStatusText.text = "Inloggad. Tryck Back och logga in där också."
                print("login ok")
                print(Auth.auth().currentUser?.uid)
                print(Auth.auth().currentUser?.displayName)
                print(Auth.auth().currentUser?.email)
                if (Auth.auth().currentUser?.email == "jorgen_raby@hotmail.com"){
                    print("jorgen hotmail")
                }
                if (Auth.auth().currentUser?.email == "jorgen@icloud.com"){
                    print("jorgen icloud")
                }
                
                self!.dismiss(animated: false, completion: nil)
            }
            else{
                // ajdå
                print("login fel")
                self!.showStatusText.text = "Fel vid inloggning"
            }
        }
    }
    
    // I keep it here but I dont use it
    @IBAction func registerUser(_ sender: Any) {
        Auth.auth().createUser(withEmail: emailText.text!, password: passwordText.text!) { authResult, error in
            if error == nil{
                // hurra
                print("reg ok")
                self.showStatusText.text = "Registrering OK"
                self.dismiss(animated: false, completion: nil)
            }
            else{
                // ajdå
                print("reg ej ok")
                self.showStatusText.text = "Registrering ej OK"
            }
        }
    }
}
