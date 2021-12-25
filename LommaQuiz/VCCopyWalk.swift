//
//  LommaQuiz
//
//  Created by jörgen persson on 2021-12-20.
//

import UIKit
import Firebase

class VCCopyWalk: UIViewController {
    
    @IBOutlet weak var readFrom: UITextField!
    @IBOutlet weak var writeTo: UITextField!
    @IBOutlet weak var statusReadWrite: UITextField!
    
    var questionPosition : Int = 1
    var cordsRead = false
    var ref: DatabaseReference!
    var QuestCoordLongitudeCopy : [Double] = [13.076251074659215,13.076603173915528,13.07686334818293,13.077120840246137,13.077356874635825,13.07767337530735,13.074486910948394,13.074299156312744,13.07408457958629,13.07498580183741,13.075833379906916,13.07599967686992]

    var QuestCoordLatitudeCopy : [Double] = [55.67786646547556,55.678472026112516,55.67898016471325,55.67951400559161,55.68006598638061,55.680705669424434,55.67819753778474,55.67775593269402,55.67709351571015,55.6770360452147,55.6770057975516,55.677341545300955]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func copyButton(_ sender: Any) {
        GetCoords()
    }
    
    func SaveCoords() {
        var string = ""
        let quizWalkName = writeTo.text
    
        for i in 0...11{
            string = String(Character(UnicodeScalar(65+i)!))
            self.ref.child("QuizWalks").child("maps").child(quizWalkName!).child(string).child("posLongitude").setValue(QuestCoordLongitudeCopy[i])
            self.ref.child("QuizWalks").child("maps").child(quizWalkName!).child(string).child("posLatitude").setValue(QuestCoordLatitudeCopy[i])
        }
        statusReadWrite.text = "\(readFrom.text!) Kopierad till \(writeTo.text!)"
    }
    
    func GetCoords() {
        var quizWalkName = "Walk1"
        self.cordsRead = false
        var i = 0
 
        if (readFrom.text != ""){
            quizWalkName = readFrom.text!
        }
 
        print(quizWalkName)
        ref.child("QuizWalks").child("maps").child(quizWalkName).getData(completion:{ [self]error, snapshot in
                guard error == nil else
                {
                    print(error!.localizedDescription) // När jag inte har datum så trodde jag att vi skulle hamna här.
                    return;
                }
                 print(snapshot)
            if (snapshot != nil)
                {
                    for QuizWalkMapChild in snapshot.children
                    {
                        let QuizWalkMapChildSnap = QuizWalkMapChild as! DataSnapshot
                        let QuizWalkMapChildInfo = QuizWalkMapChildSnap.value as! [String : Double]
                        
                        QuestCoordLongitudeCopy[i] = QuizWalkMapChildInfo["posLongitude"]!
                        QuestCoordLatitudeCopy[i] = QuizWalkMapChildInfo["posLatitude"]!
                        i += 1  // Could use QuizWalkMapChild
                        self.cordsRead = true
                    }
                    if (self.cordsRead){
                        SaveCoords()
                    }
                    else{
                        statusReadWrite.text = "Namnet på rundan finns inte"
                    }
                }
                else
                {
                    print("snapshot == nil")
                    statusReadWrite.text = "Namnet på rundan finns inte"
                }
            })
    }

}
