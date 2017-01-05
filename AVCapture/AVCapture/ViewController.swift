//
//  ViewController.swift
//  AVCapture
//
//  Created by Wing on 17/1/5.
//  Copyright © 2017年 Wing. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    //1.创建捕捉会话
    fileprivate lazy var _session: AVCaptureSession = AVCaptureSession()
    
    fileprivate lazy var _previewLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self._session)
    
    fileprivate  var _connection: AVCaptureConnection?
    fileprivate var _videoInput: AVCaptureDeviceInput?
    fileprivate var _fileOutput: AVCaptureMovieFileOutput?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    
    
}
extension ViewController{
    @IBAction func startClicked(_ sender: UIButton) {
        
        //1.视频输入 && 输出
        setupVideo()
        
        //2.音频输入 && 输出
        setupAudio()
        
        //创建音视频文件输出
        let fileOutput = AVCaptureMovieFileOutput()
        _session.addOutput(fileOutput)
        _fileOutput = fileOutput
        //设置输出稳定性
        guard let connect = fileOutput.connection(withMediaType: AVMediaTypeVideo) else {return}
        connect.preferredVideoStabilizationMode = .auto
        
        //3.给用户看到一个预览涂层
        _previewLayer.frame = view.bounds
        view.layer.insertSublayer(_previewLayer, at: 0)
        
        //4.开始采集
        _session.startRunning()
        
        //开始写入文件
        let filePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/abc.mp4"
        let url = URL(fileURLWithPath: filePath)
        fileOutput.startRecording(toOutputFileURL: url, recordingDelegate: self)
    }
    
    @IBAction func stopClicked(_ sender: UIButton) {
        //停止采集
        _session.stopRunning()
        //移除预览图层
        _previewLayer.removeFromSuperlayer()
        
        //停止写入文件
        _fileOutput?.stopRecording()
    }
    
    @IBAction func changeCamera(){
        //获取之前的摄像头
        guard var position = _videoInput?.device.position else {return}
        //获得当前应该显示的摄像头
        position = position == .front ? .back : .front;
        //根据当前的摄像头来创建新的device
        let newDevices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) as? [AVCaptureDevice]
        guard let device = newDevices?.filter({ $0.position == position }).first else {return}
        //更具device创建新的input
        guard let videoInput = try? AVCaptureDeviceInput(device: device) else {return}
        //切换input
        _session.beginConfiguration()
        _session.removeInput(_videoInput)
        _session.addInput(videoInput)
        _session.commitConfiguration()
        _videoInput = videoInput
    }
}
// MARK: --- 音视频输入输出
extension ViewController
{
    
    /// 视频
    fileprivate func setupVideo(){
        //1.给捕捉会话添加一个输入源(摄像头)
        
        //1.1 获取后置摄像头
        let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) as? [AVCaptureDevice]
        guard let device = devices?.filter({ $0.position == .front }).first else { return }
        guard let input = try? AVCaptureDeviceInput(device: device) else { return }
        if(_session.inputs.count > 0)
        {
            _session.removeInput(_session.inputs.first as! AVCaptureInput)
        }
        
        _session.addInput(input)
        
        _videoInput = input
        
        //2.给捕捉会话添加一个输出源
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global())
        if(_session.outputs.count > 0)
        {
            _session.removeOutput(_session.outputs.first as! AVCaptureVideoDataOutput)
        }
        
        _session.addOutput(videoOutput)
        
    }
    /// 音频
    fileprivate func setupAudio(){
        
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
        guard let input = try? AVCaptureDeviceInput(device: device) else { return }
        _session.addInput(input)
        
        let output = AVCaptureAudioDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue.global())
        _session.addOutput(output)
        
        _connection = output.connection(withMediaType: AVMediaTypeAudio)
        
        
    }
}
extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate{
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!)
    {
        if connection == _connection{
            //            print("音频数据")
        }else{
            //            print("视频画面")
        }
    }
}
extension ViewController:AVCaptureFileOutputRecordingDelegate
{
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        print("开始写入")
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        print("结束写入")
    }
}

