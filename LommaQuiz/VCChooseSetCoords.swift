//
//  LommaQuiz
//
//  Created by jörgen persson on 2021-12-20.
//

import UIKit
import Firebase

var ToggleSetWalk : Bool = false // har jag denna för återhopp från ??

class VCChooseSetCoords: UIViewController {

    @IBOutlet weak var SetWalkCoords: UIButton!
    @IBOutlet weak var CreateQuestions: UIButton!
    @IBOutlet weak var walk1Button: UIButton!
    @IBOutlet weak var walk2Button: UIButton!
    @IBOutlet weak var walk3Button: UIButton!
    @IBOutlet weak var walk4Button: UIButton!
    @IBOutlet weak var walk5Button: UIButton!
    @IBOutlet weak var walkButton: UIButton!
    @IBOutlet weak var copyWalkButton: UIButton!
    
    var enableSeRunda = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // global variabel checked in VCGPSMap
        readNewCoordinates = true
        
        if (loggedInToWrite){
            SetWalkCoords.isEnabled = true
            CreateQuestions.isEnabled = true
            SetWalkCoords.alpha = 1
            CreateQuestions.alpha = 1
        }
        else{
            SetWalkCoords.isEnabled = false
            CreateQuestions.isEnabled = false
            SetWalkCoords.alpha = 0
            CreateQuestions.alpha = 0
        }
        walkButton.isEnabled = false
        walkButton.alpha = 0
        copyWalkButton.isEnabled = false
        copyWalkButton.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        makeButtonsInvisable()
    }
    
    func makeButtonsInvisable()
    {
        if (loggedInToWrite)
        {
            if (!loggedInHighest)
            {
                walk1Button.isEnabled = false
                walk1Button.alpha = 0
                walk2Button.isEnabled = false
                walk2Button.alpha = 0
                walk3Button.isEnabled = false
                walk3Button.alpha = 0
                walk4Button.isEnabled = false
                walk4Button.alpha = 0
                walk5Button.isEnabled = false
                walk5Button.alpha = 0
                walkButton.isEnabled = true
                walkButton.alpha = 1
            }
            else{  // Special for Admin to copy one walk to another
                copyWalkButton.isEnabled = true
                copyWalkButton.alpha = 1
            }
        }
    }
    
    @IBAction func walk1(_ sender: Any) {
        if (!ToggleSetWalk){
            performSegue(withIdentifier: "showWalks2", sender: 1)
        }else{
            performSegue(withIdentifier: "chosenRound", sender: 1)
        }
    }
    
    @IBAction func walk2(_ sender: Any) {
        if (!ToggleSetWalk){
            performSegue(withIdentifier: "showWalks2", sender: 2)
        }else{
            performSegue(withIdentifier: "chosenRound", sender: 2)
        }
    }
    
    @IBAction func walk3(_ sender: Any) {
        if (!ToggleSetWalk){
            performSegue(withIdentifier: "showWalks2", sender: 3)
        }else{
            performSegue(withIdentifier: "chosenRound", sender: 3)
        }
    }
    
    @IBAction func walk4(_ sender: Any) {
        if (!ToggleSetWalk){
            performSegue(withIdentifier: "showWalks2", sender: 4)
        }else{
            performSegue(withIdentifier: "chosenRound", sender: 4)
        }
    }
    
    @IBAction func walk5(_ sender: Any) {
        if (!ToggleSetWalk){
            performSegue(withIdentifier: "showWalks2", sender: 5)
        }else{
            performSegue(withIdentifier: "chosenRound", sender: 5)
        }
    }
    
    @IBAction func walk(_ sender: Any) {
        performSegue(withIdentifier: "showWalks2", sender: 6)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "chosenRound"){
            let dest = segue.destination as! VCSetCoords
        
            dest.walkNumber = sender as! Int
        }
        if (segue.identifier == "showWalks2"){
            let dest = segue.destination as! VCShowWalk2
            dest.walkNumber = sender as! Int
        }
    }
    
    @IBAction func SetWalkCoordsButton(_ sender: Any) {
        if (loggedInHighest)
        {
            if (!ToggleSetWalk){
                SetWalkCoords.backgroundColor = .red
                ToggleSetWalk = true
            }
            else{
                SetWalkCoords.backgroundColor = .white
                ToggleSetWalk = false
            }
        }
        else
        {
            performSegue(withIdentifier: "chosenRound", sender: 6)
        }
    }
}
