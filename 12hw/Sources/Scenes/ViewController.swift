//
//  ViewController.swift
//  12hw
//
//  Created by Nikolai Kamenshchikov on 19/7/22.
//

import UIKit

class ViewController: UIViewController {
    
    
    // MARK: - Outlets
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var startPauseButton: UIButton!
    
    
    // MARK: - Variables
    var isWorkTime = true
    var isStarted = false
    
    var timer = Timer()
    var time = 10
    var animationTime = 10
    
    
    // MARK: - Actions
    @IBAction func startPauseButtonPressed(_ sender: Any) {
        if !isStarted {
            startTimer()
            isStarted = true
            
            changeStartPauseButtonText()
        } else {
            pauseTimer()
        }
    }
    
    
    @IBAction func segmentedControlValueChanged(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            isWorkTime = true
            isStarted = false
            pauseTimer()
            setTime()
            changeTimeLabelText()
            changeStartPauseButtonText()
            progressView.progress = 0.0
            progressView.progressColor = .red
            
        case 1:
            isWorkTime = false
            isStarted = false
            pauseTimer()
            setTime()
            changeTimeLabelText()
            changeStartPauseButtonText()
            progressView.progress = 0.0
            progressView.progressColor = .systemCyan
            
        default:
            break
        }
    }
    
    
    // MARK: - Functions
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
    }
    
    
    func pauseTimer() {
        timer.invalidate()
        isStarted = false
        changeStartPauseButtonText()
    }
    
    
    func changeTimeLabelText()  {
        timeLabel.text = formatTime()
    }
    
    
    func changeStartPauseButtonText() {
        if isStarted {
            startPauseButton.setTitle("Pause", for: .normal)
        } else {
            startPauseButton.setTitle("Start", for: .normal)
        }
    }
    
    
    func formatTime() -> String {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i", minutes, seconds)
    }
    
    
    func setTime() {
        if isWorkTime {
            time = 10
            animationTime = 10
        } else {
            time = 5
            animationTime = 5
        }
    }
    
    
    func changeWorkChillMode() {
        if isWorkTime {
            pauseTimer()
            isWorkTime = false
            segmentedControl.selectedSegmentIndex = 1
            progressView.progressColor = .systemCyan
        } else {
            pauseTimer()
            isWorkTime = true
            segmentedControl.selectedSegmentIndex = 0
            progressView.progressColor = .red
            
        }
    }
    
    
    @objc func updateTimer(){
        if time > 0 {
            time -= 1
            changeTimeLabelText()
            progressView.progress += 1 / Float(animationTime)
            print(progressView.progress)
        } else {
            pauseTimer()
            changeWorkChillMode()
            setTime()
            changeTimeLabelText()
            progressView.progress = 0.0
        }
        
        print(timer.isValid)
        print(time)
        print("")
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        changeTimeLabelText()
        updateProgressView()
    }
    
    
    // MARK: - Circular progress bar
    let progressView = CircularProgressView(frame: CGRect(x: 0, y: 0, width: 200, height: 100), lineWidth: 15, rounded: false)
    
    
    func updateProgressView() {
        progressView.progressColor = .red
        progressView.trackColor = .lightGray
        progressView.center = view.center
        view.addSubview(progressView)
        //progressView.progress = 0.0
    }
}


// MARK: - Circular progress view class
class CircularProgressView: UIView {
    fileprivate var progressLayer = CAShapeLayer()
    fileprivate var trackLayer = CAShapeLayer()
    fileprivate var didConfigureLabel = false
    fileprivate var rounded: Bool
    fileprivate var filled: Bool
    
    fileprivate let lineWidth: CGFloat?
    
    var timeToFill = 3.43
    
    var progressColor = UIColor.white {
        didSet{
            progressLayer.strokeColor = progressColor.cgColor
        }
    }
    
    var trackColor = UIColor.white {
        didSet{
            trackLayer.strokeColor = trackColor.cgColor
        }
    }
    
    var progress: Float {
        didSet{
            var pathMoved = progress - oldValue
            if pathMoved < 0{
                pathMoved = 0 - pathMoved
            }
            
            setProgress(duration: timeToFill * Double(pathMoved), to: progress)
        }
    }
    
    
    fileprivate func createProgressView(){
        
        self.backgroundColor = .clear
        self.layer.cornerRadius = frame.size.width / 2
        let circularPath = UIBezierPath(arcCenter: center, radius: frame.width / 2, startAngle: CGFloat(-0.5 * .pi), endAngle: CGFloat(1.5 * .pi), clockwise: true)
        trackLayer.fillColor = UIColor.blue.cgColor
        trackLayer.path = circularPath.cgPath
        trackLayer.fillColor = .none
        trackLayer.strokeColor = trackColor.cgColor
        
        if filled {
            trackLayer.lineCap = .butt
            trackLayer.lineWidth = frame.width
        }else{
            trackLayer.lineWidth = lineWidth!
        }
        trackLayer.strokeEnd = 1
        layer.addSublayer(trackLayer)
        
        progressLayer.path = circularPath.cgPath
        progressLayer.fillColor = .none
        progressLayer.strokeColor = progressColor.cgColor
        
        if filled {
            progressLayer.lineCap = .butt
            progressLayer.lineWidth = frame.width
        }else{
            progressLayer.lineWidth = lineWidth!
        }
        progressLayer.strokeEnd = 0
        if rounded{
            progressLayer.lineCap = .round
        }
        
        layer.addSublayer(progressLayer)
    }
    
    
    func trackColorToProgressColor() -> Void{
        trackColor = progressColor
        trackColor = UIColor(red: progressColor.cgColor.components![0], green: progressColor.cgColor.components![1], blue: progressColor.cgColor.components![2], alpha: 0.2)
    }
    
    
    func setProgress(duration: TimeInterval = 3, to newProgress: Float) -> Void{
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        
        animation.fromValue = progressLayer.strokeEnd
        animation.toValue = newProgress
        
        progressLayer.strokeEnd = CGFloat(newProgress)
        
        progressLayer.add(animation, forKey: "animationProgress")
        
    }
    
    
    override init(frame: CGRect){
        progress = 0
        rounded = true
        filled = false
        lineWidth = 15
        super.init(frame: frame)
        filled = false
        createProgressView()
    }
    
    
    required init?(coder: NSCoder) {
        progress = 0
        rounded = true
        filled = false
        lineWidth = 15
        super.init(coder: coder)
        createProgressView()
    }
    
    
    init(frame: CGRect, lineWidth: CGFloat?, rounded: Bool) {
        
        progress = 0
        
        if lineWidth == nil{
            self.filled = true
            self.rounded = false
        }else{
            if rounded{
                self.rounded = true
            }else{
                self.rounded = false
            }
            self.filled = false
        }
        self.lineWidth = lineWidth
        
        super.init(frame: frame)
        createProgressView()
    }
}
