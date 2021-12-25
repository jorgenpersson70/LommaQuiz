//
//  LommaQuiz
//
//  Created by jörgen persson on 2021-12-20.
//

import UIKit
import Firebase
import FirebaseAuth

var loggedInHighest = false
var loggedInToWrite = false
var loggedInToWalkSombodysSpecial = false
var questUser = ""
var questCreator = ""
var masterLoggedIn = false
var authPassedForUser = false

class VCLogin: UIViewController {
    @IBOutlet weak var writtenPassword: UITextField!
    @IBOutlet weak var showIfLoginLogout: UITextField!
    @IBOutlet weak var questionCreator: UITextField!
    @IBOutlet weak var questionUser: UITextField!
    @IBOutlet weak var saveNewQuestionWriter: UIButton!
    @IBOutlet weak var permissionToWrite: UITextField!
    @IBOutlet weak var textToExplain: UITextView!
    @IBOutlet weak var textViewText: UITextView!
    var ref: DatabaseReference!
    var quizCreatorList = [String]()
    var quizUserList = [String]()
    var permissionToWriteList = [String]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(VCWriteQuestion.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(VCWriteQuestion.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
     
        ref = Database.database().reference()
        
        getLogins()
        getLoginText()
        makeInvisable()
        
        showIfLoginLogout.text = "Du är inte inloggad"
        if (loggedInToWalkSombodysSpecial){
            showIfLoginLogout.text = "Du är inloggad på rundan"
        }
        if (loggedInToWrite){
            if (loggedInHighest){
                makeVisibleHigh()
                showIfLoginLogout.text = "Du är inloggad med skrivrättighet"
            }
            else{
                logOut("")
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
           // if keyboard size is not available for some reason, dont do anything
           return
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
      // move back the root view origin to zero
      self.view.frame.origin.y = 0
    }
    
    func makeInvisable(){
        questionCreator.isEnabled = false
        questionUser.isEnabled = false
        saveNewQuestionWriter.isEnabled = false
        permissionToWrite.isEnabled = false
        questionCreator.alpha = 0
        questionUser.alpha = 0
        saveNewQuestionWriter.alpha = 0
        permissionToWrite.alpha = 0
        textToExplain.isHidden = true
    }
    
    func makeVisibleHigh(){
        loggedInToWrite = true
        showIfLoginLogout.text = "Du är inloggad"
        questionCreator.isEnabled = true
        questionUser.isEnabled = true
        questionCreator.alpha = 1
        questionUser.alpha = 1
        saveNewQuestionWriter.isEnabled = true
        saveNewQuestionWriter.alpha = 1
        permissionToWrite.isEnabled = true
        permissionToWrite.alpha = 1
    }
    
    
    @IBAction func logIn(_ sender: Any) {
        var login = quizCreatorList.contains(where: writtenPassword.text!.contains)
        
        var isItHighestPriority = false
        var foundSomeoneToLogin = 0
        
        if (Auth.auth().currentUser?.email == "jorgen_raby@hotmail.com"){
            print("hej")
            masterLoggedIn = true
        }
        if (Auth.auth().currentUser?.email == "jorgen@icloud.com"){
            print("hej")
            authPassedForUser = true
        }
 
        if let FoundSomeOne = quizCreatorList.firstIndex(of: writtenPassword.text!){
            foundSomeoneToLogin = FoundSomeOne
            
            isItHighestPriority = (quizUserList[foundSomeoneToLogin] == "adminmaster")
            
            if (!isItHighestPriority){
                loggedInToWrite = (permissionToWriteList[foundSomeoneToLogin] == "Ja")
            }
            
            if (isItHighestPriority && (!masterLoggedIn)){
                isItHighestPriority = false
                showIfLoginLogout.text = "Logga in för skrivrättighet"
            }
            
            if (loggedInToWrite && (!authPassedForUser)){
                loggedInToWrite = false
                showIfLoginLogout.text = "Logga in för skrivrättighet"
            }
            
            // Only to make the keyboard disappear
            writtenPassword.isEnabled = false
            writtenPassword.isEnabled = true
        }
        
        if (isItHighestPriority){
            makeVisibleHigh()
            loggedInHighest = true
            self.view.frame.origin.y = 0 - 200
        }
        
        // om man kommer åter så bör jag ta hand om detta
        if (login){
            if (loggedInToWrite){
                showIfLoginLogout.text = "Du är inloggad med skrivrättighet"
                questUser = quizUserList[foundSomeoneToLogin]
                questCreator = quizCreatorList[foundSomeoneToLogin]
                if (!isItHighestPriority){
               //     textToExplain.text.append(" " + quizUserList[foundSomeoneToLogin])
                    textToExplain.text = "Användare av din runda loggar in med: " + quizUserList[foundSomeoneToLogin]
                    textToExplain.isHidden = false
                }
            }
            else{
                showIfLoginLogout.text = "Du är inloggad utan skrivrättighet"
                questUser = quizUserList[foundSomeoneToLogin]
                loggedInToWalkSombodysSpecial = true
            }
        }
       
    }
    
    
    @IBAction func logOut(_ sender: Any) {
        loggedInToWrite = false
        showIfLoginLogout.text = "Du är inte inloggad"
        writtenPassword.text = ""
        makeInvisable()
        questUser = ""
        loggedInToWalkSombodysSpecial = false
        loggedInHighest = false
        self.view.frame.origin.y = 0
    }
    
   
    
    @IBAction func SaveNewQuestionWriter(_ sender: Any) {
        self.ref.child("QuizWalks").child("Login").childByAutoId().setValue(["questionCreator" : questionCreator.text!, "questionUser" : questionUser.text!, "writePermission" : permissionToWrite.text!, "haveQuestions" : "Nej"])
        // I save a new User for this writer
        self.ref.child("QuizWalks").child("Login").childByAutoId().setValue(["questionCreator" : questionUser.text!, "questionUser" : questionUser.text!, "writePermission" : "Nej", "haveQuestions" : "Nej"])
        
        // I have to do this to get it to save correct in 
        questUser = questionUser.text!
        loggedInHighest = false
        var userType = VCSetCoords().CreateEmptySave()
        loggedInHighest = true
        questUser = ""
   //     var testa = "Någon eller några frågor missades tyvärr. Jag gissar att det handlar om att appen inte har tillåtits att köra i bakgrunden. När du inte är aktiv på telefonen under en viss tid, då går appen i bakgrundsläge. Gå in på inställningar, leta upp Frågerundan. Under Plats finner du TILLÅT ÅTKOMST TILL PLATSINFO. Där kan du markera Alltid. Om appen missade frågor trots att Alltid var ikryssad, då vill jag gärna veta det och skicka gärna ett meddelande till jorgen_raby@icloud.com. Du kan bara läsa frågor och svar nu på de frågor som missades. mvh Jörgen";
        
        getLogins()
        
  //      self.ref.child("QuizWalks").child("TestFlag").child("TestFlag").setValue("Hej")
   //     self.ref.child("QuizWalks").child("VidMissadeFrågorText").child("VidMissadeFrågorText").setValue(testa)
    }
    
    
    
    func getLogins() {
        self.ref.child("QuizWalks").child("Login").getData(completion:{ [self]error, snapshot in
                guard error == nil else
                {
                print(error!.localizedDescription)
                return;
            }

            if (snapshot != nil)
                {
                    for loginChild in snapshot.children
                    {
                        let loginChildSnap = loginChild as! DataSnapshot
                        let LoginInfo = loginChildSnap.value as! [String : String]
                        // jag kan inte göra append varje gång, rensa
                        self.quizCreatorList.append(LoginInfo["questionCreator"]!)
                        self.quizUserList.append(LoginInfo["questionUser"]!)
                        self.permissionToWriteList.append(LoginInfo["writePermission"]!)
                    }
                }
                else
                {
                    print("snapshot == nil")
                }
            
        })
    }
    func getLoginText() {
  
        self.ref.child("QuizWalks").child("LoginText").getData(completion:{ [self]error, snapshot in
                guard error == nil else
                {
                print(error!.localizedDescription)
                return;
            }
            print(snapshot)
         
            if (snapshot != nil)
                {
                    print(snapshot.children)
                    for loginChild in snapshot.children
                    {
                        let loginChildSnap = loginChild as! DataSnapshot
                        let LoginInfo = loginChildSnap.value as! String
                       
                        print(LoginInfo)
                        textViewText.text = LoginInfo
                    }
                }
                else
                {
                    print("snapshot == nil")
                }
            
        })
    }
    
}
