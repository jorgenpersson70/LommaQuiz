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

class ViewController: UIViewController, UITextFieldDelegate, AVAudioPlayerDelegate{
    @IBOutlet weak var startWalkButtonText: UILabel!
    @IBOutlet weak var mainPicture: UIImageView!
    @IBOutlet weak var choseWalkButton: UIButton!
    @IBOutlet weak var adminLoginText: UIButton!
    var chosenWalk = 1
    var fruits = [String]()
    var fruit2 = ""
    var Question = true
    let storage = Storage.storage()
    var player:AVPlayer!
 //   var scrOpt = 0.5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
   //     self.adminLoginText.frame = CGRect(x:self.adminLoginText.frame.origin.x, y:self.adminLoginText.frame.origin.y, width:self.adminLoginText.frame.size.width, height:self.adminLoginText.frame.size.height*scrOpt)
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
 //       let frontpic = storageRef.child("QuizFront.png")
        let frontpic = storageRef.child("lomma_front.png")
        frontpic.getData(maxSize: 2 * 1024 * 1024) { data, error in
          if let error = error {
            // Uh-oh, an error occurred!
          } else {
            // Data for "images/island.jpg" is returned
            let image = UIImage(data: data!)
              self.mainPicture.image = image
          }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (loggedInToWalkSombodysSpecial){
            choseWalkButton.isEnabled = false
            choseWalkButton.alpha = 0
            startWalkButtonText.text = "STARTA RUNDA"
        }
        else
        {
            choseWalkButton.isEnabled = true
            choseWalkButton.alpha = 1
            switch chosenWalk {
            case 2:
                startWalkButtonText.text = "STARTA RUNDA 2"
            case 3:
                startWalkButtonText.text = "STARTA RUNDA 3"
            case 4:
                startWalkButtonText.text = "STARTA RUNDA 4"
            case 5:
                startWalkButtonText.text = "STARTA RUNDA 5"
            default:
                startWalkButtonText.text = "STARTA RUNDA 1"
            }
        }
    }
    
   
    @IBAction func adminLogin(_ sender: Any) {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            self.view.endEditing(true)
            return false
        }
    
    @IBAction func StartWalk(_ sender: Any) {
        
        // because if they have not made a choice, then coords are not loaded
        if (chosenWalk == 1)
        {
            VCGPSMap().GetCoords(WalkNumberIn: String(chosenWalk))
        }
        performSegue(withIdentifier: "WalkNumber", sender: "12")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "WalkNumber"){
            let dest = segue.destination as! VCChoseKm
            dest.walkNumber = String(chosenWalk)
        }
    }
    
    @IBAction func introSpeach(_ sender: Any) {
        introTalk()
    }
    
    func introTalk() {
   
        let videoRef = storage.reference().child("introtal.mp3")

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

