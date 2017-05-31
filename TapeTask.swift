//
//  TapeTask.swift
//  EclipseSoundscapes
//
//  Created by Anonymous on 5/31/17.
//  Copyright © 2017 DevByArlindo. All rights reserved.
//

import Foundation

typealias TapeCallback = ((TapeTaskPiece) -> Void)



class TapeTask {
    
    init() {
        durationMaster = Dictionary<String, TapeCallback>()
        failureMaster = Dictionary<String, TapeCallback>()
        sucessMaster = Dictionary<String, TapeCallback>()
        masterMap = Dictionary<String, TapeTaskStatus>()
    }
    
    deinit {
        durationMaster = nil
        failureMaster = nil
        sucessMaster = nil
        masterMap = nil
    }
    
    fileprivate var durationMaster : Dictionary<String, TapeCallback>!
    fileprivate var failureMaster : Dictionary<String, TapeCallback>!
    fileprivate var sucessMaster : Dictionary<String, TapeCallback>!
    fileprivate var masterMap : Dictionary<String, TapeTaskStatus>!
    
    fileprivate var duration = 0.0
    fileprivate var error : Error?
    
    var taskPiece : TapeTaskPiece {
        return TapeTaskPiece(duration: self.duration, error: error)
    }
    
    
    
    enum TapeTaskStatus {
        case duration
        case success
        case failure
    }
    
    
    @discardableResult
    func observe(_ status: TapeTaskStatus, handler : @escaping TapeCallback)-> String{
        
        let callback = handler
        let key = UUID.init().uuidString
        
        
        switch status {
        case .duration:
            synced(self, closure: {
                durationMaster.updateValue(callback, forKey: key)
            })
            break
        case .failure:
            synced(self, closure: {
                failureMaster.updateValue(callback, forKey: key)
            })
            break
            
        case .success:
            synced(self, closure: {
                sucessMaster.updateValue(callback, forKey: key)
            })
            break
            
        }
        
        
        masterMap.updateValue(status, forKey: key)
        return key
    }
    
    
    func removeObserver(withKey key :String){
        var dictionary = getHandlers(fromMaster: key)
        
        synced(self) {
            dictionary?.removeValue(forKey: key)
            masterMap.removeValue(forKey: key)
        }
        
    }
    
    func removeObserver(withStatus status : TapeTaskStatus){
        var dictionary = getObserver(fromStatus: status)
        
        synced(self) {
            dictionary.removeAll()
            masterMap.forEach({ (key, value) in
                if value == status {
                    masterMap.removeValue(forKey: key)
                }
            })
        }
        
    }
    
    
    
    func removeAllObservers(){
        synced(self) {
            durationMaster.removeAll()
            failureMaster.removeAll()
            sucessMaster.removeAll()
            masterMap.removeAll()
        }
    }
    
    private func getHandlers(fromMaster key : String)-> Dictionary<String, TapeCallback>?{
        guard let status = masterMap[key] else {
            return nil
        }
        
        return getObserver(fromStatus: status)
        
    }
    
    private func getObserver(fromStatus status : TapeTaskStatus)-> Dictionary<String, TapeCallback> {
        switch status {
        case .duration:
            return durationMaster
        case .success:
            return sucessMaster
        case .failure:
            return failureMaster
        }
    }
    
    
}

fileprivate extension TapeTask {
    func fireWithStatus(_status : TapeTaskStatus, value : Any? = nil){
        switch _status {
        case .duration:
            
            self.duration = value as! Double
            self.fireWithHandler(durationMaster, self.taskPiece)
            break
        case .failure:
            
            self.error = value as? Error
            
            fireWithHandler(failureMaster, self.taskPiece)
            break
            
        case .success:
            
            
            fireWithHandler(sucessMaster, self.taskPiece)
            break
        }
        
    }
    
    func fireWithHandler(_ handler : Dictionary<String, TapeCallback>,_ taskPiece: TapeTaskPiece){
        
        synced(self) {
            handler.forEach { (key, value) in
                DispatchQueue.main.async {
                    value(taskPiece)
                }
            }
        }
        
    }
    
    fileprivate func synced(_ lock: Any, closure: () -> ()) {
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
    }
}


@objc public protocol TapeTaskType {
    func start()
    func updateTime()
    @objc optional func pause()
    @objc optional func stop(_ status: AudioStatus)
    @objc optional func resume()
}



class RecordTapeTask: TapeTask, TapeTaskType {
    
    unowned var tapeRecorder : TapeRecorder
    
    init(recorder: TapeRecorder) {
        self.tapeRecorder = recorder
        super.init()
    }
    
    func start() {
        self.fireWithStatus(_status: .duration, value: tapeRecorder.durationRecorded)
    }
    
    func updateTime() {
        self.fireWithStatus(_status: .duration, value: tapeRecorder.durationRecorded)
    }
    
    func stop(_ status: AudioStatus, error: Error? = nil) {
        guard error == nil else {
            self.fireWithStatus(_status: .failure, value: error)
            self.removeAllObservers()
            return
        }
        switch status {
        case .interruption:
            self.fireWithStatus(_status: .failure, value: AudioError.interruption)
            break
        case .sucess, .stop:
            self.fireWithStatus(_status: .success)
        default:
            break
        }
    }
    
    //TODO: Implement Pause
    func pause() {
        
    }
    
    //TODO: Implement Resume
    func resume() {
        
    }
    
    
    
    
}
