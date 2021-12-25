//
//  LommaQuiz
//
//  Created by jörgen persson on 2021-12-20.
//

import UIKit
import Firebase
import FirebaseStorage
import AVFoundation
import AVKit
import AVFAudio

var YourAnswer = Array(repeating: 0, count: 12)

class VCWalkKm: UIViewController {
    @IBOutlet weak var Answer1TextView: UITextView!
    @IBOutlet weak var Answer2TextView: UITextView!
    @IBOutlet weak var Answer3TextView: UITextView!
    @IBOutlet weak var MyTextView: UITextView!
    @IBOutlet weak var LabelQuestNbr: UILabel!
    @IBOutlet weak var ButtonAnswer1: UIButton!
    @IBOutlet weak var ButtonAnswer2: UIButton!
    @IBOutlet weak var ButtonAnswer3: UIButton!
    @IBOutlet weak var ButtonListen: UIButton!
    var quizname : String = ""
    var finiched = false
    var questionnumberInt : Int = 0
    var ref: DatabaseReference!
    var questions = [String]()
    var answers1 = [String]()
    var answers2 = [String]()
    var answers3 = [String]()
    var correctanswers = [String]()
    var URLs = [String]()
    var FoundQuestions = 0
    let storage = Storage.storage()
    var player:AVPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Otherwise it will show for a short time
        ButtonListen.isEnabled = false
        ButtonListen.alpha = 0
        
        ref = Database.database().reference()
                
        ref.child("QuizWalks").child("QuizNames").child(quizname).getData(completion:{error, snapshot in
                guard error == nil else
                {
                    print(error!.localizedDescription) // När jag inte har datum så trodde jag att vi skulle hamna här.
                    return;
                }
                 print(snapshot)
            if (snapshot != nil)
                {
                    for quizNameChild in snapshot.children
                    {
                        let quizNameChildSnap = quizNameChild as! DataSnapshot
                        let quizNameChildInfo = quizNameChildSnap.value as! [String : String]
                          
                        self.questions.append(quizNameChildInfo["Fråga"]!)
                        self.answers1.append(quizNameChildInfo["Answer 1"]!)
                        self.answers2.append(quizNameChildInfo["Answer 2"]!)
                        self.answers3.append(quizNameChildInfo["Answer 3"]!)
                        self.correctanswers.append(quizNameChildInfo["Correct Answer"]!)
                        self.URLs.append(quizNameChildInfo["URLString"]!)
                        self.FoundQuestions = 1
                    }
                    
                }
                else
                {
                    print("snapshot == nil")
                }
                DispatchQueue.main.async
                {
                    if (self.FoundQuestions == 1){
                        if (self.questionnumberInt != 99){
                            self.loadQuestionAndAnswers()
                        }
                    }
                    else{
 
                    }
                }
            })
        
        if (questionnumberInt == 99){
            performSegue(withIdentifier: "ToResult", sender: 1)
        }

        // Do any additional setup after loading the view.
    }
    
    
    
    func loadQuestionAndAnswers() {
        LabelQuestNbr.text = "Fråga " + String(questionnumberInt)
        
        MyTextView.text = questions[questionnumberInt-1]
    
        Answer1TextView.text = answers1[questionnumberInt-1]
        Answer2TextView.text = answers2[questionnumberInt-1]
        Answer3TextView.text = answers3[questionnumberInt-1]
        if (YourAnswer[questionnumberInt-1] == 1){
            ButtonAnswer1.backgroundColor = .systemGray2
            ButtonAnswer2.backgroundColor = .white
            ButtonAnswer3.backgroundColor = .white
        }
        if (YourAnswer[questionnumberInt-1] == 2){
            ButtonAnswer2.backgroundColor = .systemGray2
            ButtonAnswer1.backgroundColor = .white
            ButtonAnswer3.backgroundColor = .white
        }
        if (YourAnswer[questionnumberInt-1] == 3){
            ButtonAnswer3.backgroundColor = .systemGray2
            ButtonAnswer2.backgroundColor = .white
            ButtonAnswer1.backgroundColor = .white
        }
        if (URLs[questionnumberInt-1] != ""){
            ButtonListen.isEnabled = true
            ButtonListen.alpha = 1
        }
        else{
            ButtonListen.isEnabled = false
            ButtonListen.alpha = 0
        }
        
        ButtonAnswer1.layer.cornerRadius = 5
        ButtonAnswer2.layer.cornerRadius = 10
        ButtonAnswer3.layer.cornerRadius = 15
    }
    
    @IBAction func ButtonAnswer1(_ sender: Any) {
        ButtonAnswer1.backgroundColor = .systemGray2
        ButtonAnswer2.backgroundColor = .white
        ButtonAnswer3.backgroundColor = .white
        YourAnswer[questionnumberInt-1] = 1
        performSegue(withIdentifier: "backToMap", sender: 1)
    }
    
    @IBAction func ButtonAnswer2(_ sender: Any) {
        ButtonAnswer2.backgroundColor = .systemGray2
        ButtonAnswer1.backgroundColor = .white
        ButtonAnswer3.backgroundColor = .white
        YourAnswer[questionnumberInt-1] = 2
        performSegue(withIdentifier: "backToMap", sender: 1)
    }
    
    @IBAction func ButtonAnswer3(_ sender: Any) {
        ButtonAnswer3.backgroundColor = .systemGray2
        ButtonAnswer1.backgroundColor = .white
        ButtonAnswer2.backgroundColor = .white
        YourAnswer[questionnumberInt-1] = 3
        performSegue(withIdentifier: "backToMap", sender: 1)
    }
    
    
    @IBAction func ButtonListenClick(_ sender: Any) {
        Talk()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "backToMap"){
        
            let dest = segue.destination as! VCGPSMap
            questionnumberInt += 1
            dest.questionnumberInt = questionnumberInt
            dest.quizname = quizname
            dest.BlockRender = false
        }
        else{
            let dest = segue.destination as! VCResultat
            dest.quizname = quizname
            dest.YourAnswer = YourAnswer
        }
    }
    
    func Talk() {
        // Then it was the last jump though here and the LYSSNA must be blocked
        if (questionnumberInt == 99){
            return
        }
   //     let videoRef = storage.reference().child("introtal.mp3")
        print(questionnumberInt-1)
        
        var SoundName = URLs[questionnumberInt-1] + ".mp3"
        
        print(SoundName)
   //     let videoRef = storage.reference().child(URLs[questionnumberInt-1])
        let videoRef = storage.reference().child(SoundName)
        
        videoRef.getData(maxSize: 10 * 1024 * 1024) { data, error in

          if let error = error {

            print("ERROR: \(error)")
            print("Did not find video!")

          } else {

            let tmpFileURL = URL(fileURLWithPath:NSTemporaryDirectory()).appendingPathComponent("introtal").appendingPathExtension("mp3")
            do{
                try data!.write(to: tmpFileURL, options: [.atomic])
            }catch{
                print("error with video!")
            }
              
            self.player = AVPlayer(url: tmpFileURL)

            let controller = AVPlayerLayer(player: self.player)
            controller.player = self.player
            self.player!.isMuted = false

            do {
               try AVAudioSession.sharedInstance().setCategory(.playback)
            } catch(let error) {
                print(error.localizedDescription)
            }
            self.player!.play()

            controller.videoGravity = AVLayerVideoGravity.resizeAspectFill
     
              NotificationCenter.default.addObserver(forName: .AVPlayerItemPlaybackStalled, object: self.player?.currentItem, queue: .main) { _ in
                self.player!.seek(to: CMTime.zero)
                self.player!.play()
            }
          }
        }
    }

}
